import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/view/valve_list.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

class PumpDetailView extends StatefulWidget {
  final String pumpName;
  final String farmName;
  final int farmId;

  const PumpDetailView(
      {Key? key,
      required this.pumpName,
      required this.farmName,
      required this.farmId})
      : super(key: key);

  @override
  _PumpDetailViewState createState() => _PumpDetailViewState();
}

class _PumpDetailViewState extends State<PumpDetailView> {
  List<Map<String, dynamic>> pumps = [];
  bool isLoading = true;
  Map<int, bool> pumpActiveStatus = {};

  @override
  void initState() {
    super.initState();
    fetchFarmPumps();
  }

  Future<void> fetchFarmPumps() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        setState(() {
          isLoading = false;
          // You might want to add an error message here
        });
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      // Use the farmId from the widget to fetch only pumps for this specific farm
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/farm/farms/${widget.farmId}/motors/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convert pump data
        List<Map<String, dynamic>> pumpList = data
            .map((pump) => {
                  'id': pump['id'],
                  'motor_type': pump['motor_type'] ?? 'Unknown',
                  'valve_count': pump['valves']?.length ?? 0,
                  'UIN': pump['UIN'] ?? 'N/A',
                  'is_active': pump['is_active'] ?? 0,
                })
            .toList();

        // Initialize pump active status
        Map<int, bool> statusMap = {};
        for (var pump in pumpList) {
          statusMap[pump['id']] = pump['is_active'] == 1;
        }

        // Update UserProvider with pump data for the specific farm
        Provider.of<UserProvider>(context, listen: false)
            .updateFarmPumps(widget.farmId, pumpList);

        setState(() {
          pumps = pumpList;
          pumpActiveStatus = statusMap;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          // Add error handling here
        });
        print(
            "Error fetching pumps: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Add error handling here
      });
      print("Failed to load pumps: $e");
    }
  }

  Future<void> togglePumpStatus(int pumpId, bool currentStatus) async {
    try {
      setState(() {
        // Optimistic update
        pumpActiveStatus[pumpId] = !currentStatus;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        // Revert status if token not available
        setState(() {
          pumpActiveStatus[pumpId] = currentStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please login again.')),
        );
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      var request = http.Request(
        'PUT',
        Uri.parse(
            'http://127.0.0.1:8000/farm/farms/${widget.farmId}/motors/$pumpId/updation/'),
      );
      print(request);
      request.body = json.encode({
        "id": pumpId,
        "name": "Pump $pumpId",
        "is_active": currentStatus ? 0 : 1, // Toggle the status
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Pump status updated: $responseBody");

        // Refresh pump list to get updated data
        fetchFarmPumps();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Pump ${currentStatus ? 'stopped' : 'started'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Revert status on error
        setState(() {
          pumpActiveStatus[pumpId] = currentStatus;
        });

        print(
            "Error updating pump status: ${response.statusCode} - $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update pump status: ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Revert status on error
      setState(() {
        pumpActiveStatus[pumpId] = currentStatus;
      });

      print("Exception toggling pump status: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating pump status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farmName} - Pumps'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pumps.isEmpty
              ? Center(child: Text('No pumps found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: pumps.length,
                  itemBuilder: (context, index) {
                    final pump = pumps[index];
                    final pumpId = pump['id'];
                    final isActive = pumpActiveStatus[pumpId] ?? false;

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: Colors.blue,
                              size: 40,
                            ),
                            title: Text(
                              'Pump ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${pump['motor_type']}'),
                                Text('UIN: ${pump['UIN']}'),
                                Text('Valves: ${pump['valve_count']}'),
                                Text(
                                  'Status: ${isActive ? 'Running' : 'Stopped'}',
                                  style: TextStyle(
                                    color: isActive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ValveScreen(
                                    pumpId: pump['id'],
                                    pumpName: 'Pump ${index + 1}',
                                    farmId: widget.farmId,
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(
                                    isActive ? Icons.power_off : Icons.power,
                                    color: isActive ? Colors.red : Colors.green,
                                  ),
                                  label: Text(
                                      isActive ? 'Stop Pump' : 'Start Pump'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.green.withOpacity(0.2),
                                    foregroundColor:
                                        isActive ? Colors.red : Colors.green,
                                  ),
                                  onPressed: () {
                                    togglePumpStatus(pumpId, isActive);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
