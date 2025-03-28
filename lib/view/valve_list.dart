import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ValveListView extends StatefulWidget {
  final int pumpId;
  final String pumpName;

  const ValveListView({
    Key? key,
    required this.pumpId,
    required this.pumpName,
  }) : super(key: key);

  @override
  _ValveListViewState createState() => _ValveListViewState();
}

class _ValveListViewState extends State<ValveListView> {
  List<Map<String, dynamic>> valves = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMotorValves();
  }

  Future<void> fetchMotorValves() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        setState(() {
          errorMessage = "No authentication token found. Please login.";
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
        Uri.parse('http://127.0.0.1:8000/farm/valves/?motor=${widget.pumpId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          valves = data
              .map((valve) => {
                    'id': valve['id'],
                    'name': valve['name'] ?? 'Unnamed Valve',
                    'status': valve['status'] ?? 'Unknown',
                    'flow_rate': valve['flow_rate'] ?? 0.0,
                    'last_updated': valve['last_updated'] ?? 'N/A',
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to fetch valves. Error: ${response.statusCode}";
          isLoading = false;
        });
        print(
            "Error fetching valves: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching valves";
        isLoading = false;
      });
      print("Failed to load valves: $e");
    }
  }

  // Method to toggle valve status
  Future<void> toggleValveStatus(int valveId, String currentStatus) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication failed. Please login.")),
        );
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      // Determine the new status
      String newStatus = currentStatus == 'open' ? 'closed' : 'open';

      var response = await http.patch(
        Uri.parse('http://127.0.0.1:8000/farm/valves/$valveId/'),
        headers: headers,
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        // Update local state
        setState(() {
          int index = valves.indexWhere((valve) => valve['id'] == valveId);
          if (index != -1) {
            valves[index]['status'] = newStatus;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Valve status updated to $newStatus")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update valve status")),
        );
      }
    } catch (e) {
      print("Error toggling valve status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pumpName} - Valves'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMotorValves,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchMotorValves,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : valves.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No valves found for this motor'),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: fetchMotorValves,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: valves.length,
                      itemBuilder: (context, index) {
                        final valve = valves[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(
                              valve['status'] == 'open'
                                  ? Icons.water_drop_outlined
                                  : Icons.water_drop_sharp,
                              color: valve['status'] == 'open'
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 40,
                            ),
                            title: Text(
                              valve['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${valve['status']}'),
                                Text('Flow Rate: ${valve['flow_rate']} L/min'),
                                Text('Last Updated: ${valve['last_updated']}'),
                              ],
                            ),
                            trailing: Switch(
                              value: valve['status'] == 'open',
                              onChanged: (bool value) {
                                toggleValveStatus(valve['id'], valve['status']);
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
