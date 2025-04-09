import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import 'view/pump_operation.dart';
// New file we'll create

class PumpListView extends StatefulWidget {
  final String farmName;
  final int farmId;

  const PumpListView({
    Key? key,
    required this.farmName,
    required this.farmId,
  }) : super(key: key);

  @override
  _PumpListViewState createState() => _PumpListViewState();
}

class _PumpListViewState extends State<PumpListView> {
  List<Map<String, dynamic>> pumps = [];
  bool isLoading = true;

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
        });
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      var response = await http.get(
        Uri.parse(
            'https://fahadrahman122.pythonanywhere.com/farm/farms/${widget.farmId}/motors/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convert pump data
        List<Map<String, dynamic>> pumpList = [];

        for (var pump in data) {
          List<dynamic> valves = pump['valves'] ?? [];

          pumpList.add({
            'id': pump['id'],
            'motor_type': pump['motor_type'] ?? 'Unknown',
            'valve_count': valves.length,
            'UIN': pump['UIN'] ?? 'N/A',
            'is_active': pump['is_active'] ?? 0,
            'valves': valves,
          });
        }

        // Update UserProvider with pump data
        Provider.of<UserProvider>(context, listen: false)
            .updateFarmPumps(widget.farmId, pumpList);

        setState(() {
          pumps = pumpList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            "Error fetching pumps: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Failed to load pumps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farmName} - Motors'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pumps.isEmpty
              ? Center(child: Text('No motors found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: pumps.length,
                  itemBuilder: (context, index) {
                    final pump = pumps[index];
                    final pumpId = pump['id'];
                    final isActive = pump['is_active'] == 1;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          Icons.settings,
                          color: Colors.blue,
                          size: 36,
                        ),
                        title: Text(
                          'Motor ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${pump['motor_type']}'),
                            Text('UIN: ${pump['UIN']}'),
                            Text('Valves: ${pump['valve_count']}'),
                            Row(
                              children: [
                                Text(
                                  'Status: ',
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Running' : 'Stopped',
                                    style: TextStyle(
                                      color:
                                          isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          child: Text('Operate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PumpOperationView(
                                  pumpId: pumpId,
                                  pumpName: 'Motor ${index + 1}',
                                  farmId: widget.farmId,
                                  farmName: widget.farmName,
                                  pump: pump,
                                ),
                              ),
                            ).then((_) {
                              // Refresh data when returning from operation page
                              fetchFarmPumps();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          fetchFarmPumps();
        },
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }
}
