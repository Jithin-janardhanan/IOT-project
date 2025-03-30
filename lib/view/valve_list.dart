import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ValveScreen extends StatefulWidget {
  final int pumpId;
  final String pumpName;
  final int farmId;

  const ValveScreen({
    Key? key,
    required this.pumpId,
    required this.pumpName,
    required this.farmId,
  }) : super(key: key);

  @override
  _ValveScreenState createState() => _ValveScreenState();
}

class _ValveScreenState extends State<ValveScreen> {
  List<Map<String, dynamic>> valves = [];
  bool isLoading = true;
  bool isPumpActive = false;

  @override
  void initState() {
    super.initState();
    fetchValves();
  }

  Future<void> fetchValves() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')),
        );
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/farm/farms/${widget.farmId}/motors/${widget.pumpId}/valves/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convert valve data
        List<Map<String, dynamic>> valveList = data
            .map((valve) => {
                  'id': valve['id'],
                  'name': valve['name'] ?? 'Unknown Valve',
                  'is_active': valve['is_active'] == 1,
                })
            .toList();

        // Check if any valve is active to determine pump status
        bool anyValveActive =
            valveList.any((valve) => valve['is_active'] == true);

        setState(() {
          valves = valveList;
          isPumpActive = anyValveActive;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load valves: ${response.statusCode}')),
        );
        print(
            "Error fetching valves: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print("Failed to load valves: $e");
    }
  }

  Future<void> toggleValveStatus(int valveId, bool currentStatus) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')),
        );
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      final response = await http.patch(
        Uri.parse(
            'http://127.0.0.1:8000/farm/farms/${widget.farmId}/motors/${widget.pumpId}/valves/$valveId/'),
        headers: headers,
        body: json.encode({
          'is_active': !currentStatus ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        // Update local state
        setState(() {
          for (var i = 0; i < valves.length; i++) {
            if (valves[i]['id'] == valveId) {
              valves[i]['is_active'] = !currentStatus;
            }
          }

          // Update pump status based on valves
          isPumpActive = valves.any((valve) => valve['is_active'] == true);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentStatus
                ? 'Valve turned OFF successfully'
                : 'Valve turned ON successfully'),
            backgroundColor: !currentStatus ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to toggle valve status: ${response.statusCode}')),
        );
        print(
            "Error toggling valve: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print("Failed to toggle valve: $e");
    }
  }

  Future<void> toggleAllValves(bool turnOn) async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')),
        );
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      // Update each valve
      List<Future> futures = [];
      for (var valve in valves) {
        futures.add(http.patch(
          Uri.parse(
              'http://127.0.0.1:8000/farm/farms/${widget.farmId}/motors/${widget.pumpId}/valves/${valve['id']}/'),
          headers: headers,
          body: json.encode({
            'is_active': turnOn ? 1 : 0,
          }),
        ));
      }

      // Wait for all requests to complete
      await Future.wait(futures);

      // Update local state
      setState(() {
        for (var i = 0; i < valves.length; i++) {
          valves[i]['is_active'] = turnOn;
        }
        isPumpActive = turnOn;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(turnOn
              ? 'All valves turned ON successfully'
              : 'All valves turned OFF successfully'),
          backgroundColor: turnOn ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print("Failed to toggle all valves: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pumpName} - Valves'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Pump status card
                Card(
                  margin: EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color:
                      isPumpActive ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.pumpName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  isPumpActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: isPumpActive
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPumpActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.power_settings_new),
                              label: Text('Turn All ON'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => toggleAllValves(true),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.power_off),
                              label: Text('Turn All OFF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => toggleAllValves(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Valves heading
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valves (${valves.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: fetchValves,
                        child: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Valves list
                Expanded(
                  child: valves.isEmpty
                      ? Center(child: Text('No valves found'))
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: valves.length,
                          itemBuilder: (context, index) {
                            final valve = valves[index];
                            final isActive = valve['is_active'] as bool;

                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: isActive
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Icon(
                                  Icons.water_drop,
                                  color: isActive ? Colors.green : Colors.red,
                                  size: 40,
                                ),
                                title: Text(
                                  valve['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Switch(
                                  value: isActive,
                                  activeColor: Colors.green,
                                  inactiveTrackColor: Colors.red.shade200,
                                  onChanged: (value) =>
                                      toggleValveStatus(valve['id'], isActive),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
