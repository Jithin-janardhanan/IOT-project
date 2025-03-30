

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
                })
            .toList();

        // Update UserProvider with pump data for the specific farm
        Provider.of<UserProvider>(context, listen: false)
            .updateFarmPumps(widget.farmId, pumpList);

        setState(() {
          pumps = pumpList;
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
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
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
                    );
                  },
                ),
    );
  }
}
