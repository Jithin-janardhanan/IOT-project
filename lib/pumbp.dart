// import 'package:flutter/material.dart';

// class PumpDetailView extends StatefulWidget {
//   final String pumpName;

//   const PumpDetailView({Key? key, required this.pumpName}) : super(key: key);

//   @override
//   _PumpDetailViewState createState() => _PumpDetailViewState();
// }

// class _PumpDetailViewState extends State<PumpDetailView> {
//   // Mock valve data - replace with actual API data later
//   List<Map<String, dynamic>> valves = [
//     {'id': '1', 'name': 'Main Field', 'status': false},
//     {'id': '2', 'name': 'Vegetable Garden', 'status': false},
//     {'id': '3', 'name': 'Orchard', 'status': false},
//     {'id': '4', 'name': 'Greenhouse', 'status': false},
//   ];

//   bool isPumpRunning = false;

//   void _togglePump() {
//     setState(() {
//       isPumpRunning = !isPumpRunning;
//       // TODO: Add API call to actually turn pump on/off
//     });
//   }

//   void _toggleValve(int index) {
//     setState(() {
//       valves[index]['status'] = !valves[index]['status'];
//       // TODO: Add API call to toggle specific valve
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.pumpName} Control'),
//         backgroundColor: Colors.green[600],
//       ),
//       body: Column(
//         children: [
//           // Pump Status Card
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Pump Status',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Switch(
//                       value: isPumpRunning,
//                       onChanged: (value) => _togglePump(),
//                       activeColor: Colors.green,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Valve Control Section
//           Expanded(
//             child: GridView.builder(
//               padding: EdgeInsets.all(16.0),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16.0,
//                 mainAxisSpacing: 16.0,
//                 childAspectRatio: 0.8,
//               ),
//               itemCount: valves.length,
//               itemBuilder: (context, index) {
//                 final valve = valves[index];
//                 return Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.water_drop,
//                         size: 50,
//                         color: valve['status'] ? Colors.blue : Colors.grey,
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         valve['name'],
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Switch(
//                         value: valve['status'],
//                         onChanged: isPumpRunning
//                           ? (value) => _toggleValve(index)
//                           : null,
//                         activeColor: Colors.blue,
//                       ),
//                       Text(
//                         valve['status'] ? 'Open' : 'Closed',
//                         style: TextStyle(
//                           color: valve['status'] ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

  const PumpDetailView({
    Key? key,
    required this.pumpName,
    required this.farmName,
    required this.farmId
  }) : super(key: key);

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
        setState(() => isLoading = false);
        return;
      }

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/farm/motors/?farm=${widget.farmId}'),
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
        print("Error fetching pumps: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Failed to load pumps: $e");
      setState(() => isLoading = false);
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
                              builder: (context) => ValveListView(
                                pumpId: pump['id'],
                                pumpName: 'Pump ${index + 1}',
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