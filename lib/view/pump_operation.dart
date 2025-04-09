import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PumpOperationView extends StatefulWidget {
  final int pumpId;
  final String pumpName;
  final int farmId;
  final String farmName;
  final Map<String, dynamic> pump;

  const PumpOperationView({
    Key? key,
    required this.pumpId,
    required this.pumpName,
    required this.farmId,
    required this.farmName,
    required this.pump,
  }) : super(key: key);

  @override
  _PumpOperationViewState createState() => _PumpOperationViewState();
}

class _PumpOperationViewState extends State<PumpOperationView> {
  bool isLoading = true;
  Map<String, dynamic> pumpData = {};
  bool isPumpActive = false;
  List<Map<String, dynamic>> valves = [];

  @override
  void initState() {
    super.initState();
    loadPumpData();
  }

  Future<void> loadPumpData() async {
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

      // Fetch specific pump data
      var response = await http.get(
        Uri.parse(
            'https://fahadrahman122.pythonanywhere.com/farm/farms/${widget.farmId}/motors/${widget.pumpId}/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<Map<String, dynamic>> valvesList = [];
        if (data['valves'] != null) {
          for (var valve in data['valves']) {
            valvesList.add({
              'id': valve['id'],
              'name': valve['name'] ?? 'Valve',
              'is_active': valve['is_active'] ?? 0,
            });
          }
        }

        setState(() {
          pumpData = data;
          isPumpActive = data['is_active'] == 1;
          valves = valvesList;
          isLoading = false;
        });
      } else {
        // If specific endpoint fails, use the data passed from previous screen
        setState(() {
          pumpData = widget.pump;
          isPumpActive = widget.pump['is_active'] == 1;

          List<Map<String, dynamic>> valvesList = [];
          if (widget.pump['valves'] != null) {
            for (var valve in widget.pump['valves']) {
              valvesList.add({
                'id': valve['id'],
                'name': valve['name'] ?? 'Valve',
                'is_active': valve['is_active'] ?? 0,
              });
            }
          }

          valves = valvesList;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading pump data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> togglePumpStatus() async {
    // If trying to turn on pump, verify at least one valve is active
    if (!isPumpActive) {
      bool atLeastOneValveActive =
          valves.any((valve) => valve['is_active'] == 1);
      if (!atLeastOneValveActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'At least one valve must be open before starting the pump'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    try {
      // Show loading indicator
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        setState(() {
          isLoading = false;
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

      var url =
          'https://fahadrahman122.pythonanywhere.com/farm/farms/${widget.farmId}/motors/${widget.pumpId}/updation/';

      var requestBody = {
        "id": widget.pumpId,
        "name": widget.pumpName,
        "is_active": isPumpActive ? 0 : 1, // Toggle the status
      };

      var request = http.Request(
        'PUT',
        Uri.parse(url),
      );
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          isPumpActive = !isPumpActive;
          isLoading = false;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Pump ${isPumpActive ? 'started' : 'stopped'} successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update pump status: ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating pump status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> toggleValveStatus(int valveId, bool currentStatus) async {
    try {
      // Optimistic update
      setState(() {
        for (var i = 0; i < valves.length; i++) {
          if (valves[i]['id'] == valveId) {
            valves[i]['is_active'] = currentStatus ? 0 : 1;
            break;
          }
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        // Revert status if token not available
        setState(() {
          // Revert the change
          for (var i = 0; i < valves.length; i++) {
            if (valves[i]['id'] == valveId) {
              valves[i]['is_active'] = currentStatus ? 1 : 0;
              break;
            }
          }
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

      var url =
          'https://fahadrahman122.pythonanywhere.com/farm/farms/${widget.farmId}/motors/${widget.pumpId}/valves/$valveId/update/';

      var requestBody = {
        "id": valveId,
        "name": "Valve $valveId", // You might want to get the actual valve name
        "is_active": currentStatus ? 0 : 1, // Toggle the status
      };

      var request = http.Request(
        'PUT',
        Uri.parse(url),
      );
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // If we're closing a valve and the pump is on, we need to turn it off
        if (currentStatus && isPumpActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checking if pump needs to be stopped...'),
              duration: Duration(seconds: 1),
            ),
          );

          // Check if any valves are still open
          bool anyValveOpen = false;
          for (var valve in valves) {
            if (valve['id'] != valveId && valve['is_active'] == 1) {
              anyValveOpen = true;
              break;
            }
          }

          if (!anyValveOpen) {
            // No valves open, turn off pump
            await togglePumpStatus();
          }
        }

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         'Valve ${currentStatus ? 'closed' : 'opened'} successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      } else {
        // Revert status on error
        setState(() {
          // Revert the change
          for (var i = 0; i < valves.length; i++) {
            if (valves[i]['id'] == valveId) {
              valves[i]['is_active'] = currentStatus ? 1 : 0;
              break;
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update valve status: ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Revert status on error
      setState(() {
        // Revert the change
        for (var i = 0; i < valves.length; i++) {
          if (valves[i]['id'] == valveId) {
            valves[i]['is_active'] = currentStatus ? 1 : 0;
            break;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating valve status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Operate ${widget.pumpName}'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Motor Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.blue,
                                size: 40,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pumpName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Type: ${pumpData['motor_type'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'UIN: ${pumpData['UIN'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Motor Status Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Motor Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPumpActive
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      isPumpActive ? 'RUNNING' : 'STOPPED',
                                      style: TextStyle(
                                        color: isPumpActive
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Motor Control Button
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                isPumpActive ? Icons.power_off : Icons.power,
                                color: Colors.white,
                                size: 24,
                              ),
                              label: Text(
                                isPumpActive ? 'STOP MOTOR' : 'START MOTOR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isPumpActive ? Colors.red : Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                minimumSize: Size(200, 50),
                              ),
                              onPressed: togglePumpStatus,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Valves Section Title
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Valve Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Valves List
                  valves.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No valves associated with this motor',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: valves.length,
                          itemBuilder: (context, index) {
                            final valve = valves[index];
                            final valveId = valve['id'];
                            final valveIsActive = valve['is_active'] == 1;

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Valve Icon
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: valveIsActive
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.water_drop,
                                        color: valveIsActive
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 30,
                                      ),
                                    ),

                                    SizedBox(width: 16),

                                    // Valve Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            valve['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Status: ${valveIsActive ? 'Open' : 'Closed'}',
                                            style: TextStyle(
                                              color: valveIsActive
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Valve Control
                                    Column(
                                      children: [
                                        Text(
                                          valveIsActive ? 'ON' : 'OFF',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: valveIsActive
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ),
                                        Switch(
                                          value: valveIsActive,
                                          activeColor: Colors.blue,
                                          onChanged: (value) {
                                            toggleValveStatus(
                                                valveId, valveIsActive);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadPumpData,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }
} 
