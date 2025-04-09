// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:iot/pumbp.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
// import '../../provider/user_provider.dart';

// class FarmListView extends StatefulWidget {
//   @override
//   _FarmListViewState createState() => _FarmListViewState();
// }

// class _FarmListViewState extends State<FarmListView> {
//   List<Map<String, dynamic>> farms = [];
//   bool isLoading = true;

//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchUserFarms();
//   }

//   Future<void> fetchUserFarms() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString("token");

//       if (token == null) {
//         setState(() {
//           errorMessage = "No authentication token found. Please login.";
//           isLoading = false;
//         });
//         return;
//       }

//       var headers = {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'Authorization': 'Token $token',
//       };

//       var response = await http.get(
//         Uri.parse('https://fahadrahman122.pythonanywhere.com/farm/my-farms/'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         // Convert farm data
//         List<Map<String, dynamic>> farmList = data
//             .map((farm) => {
//                   'id': farm['id'],
//                   'name': farm['name'] ?? 'Unnamed Farm',
//                   'location': farm['location'] ?? 'Unknown Location',
//                   'motor_count': farm['motors']?.length ?? 0,
//                   'icon': Icons.landscape,
//                   'color': Colors.green,
//                 })
//             .toList();

//         // Update UserProvider with farm data
//         Provider.of<UserProvider>(context, listen: false).setFarms(farmList);

//         setState(() {
//           farms = farmList;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = "Failed to fetch farms. Error: ${response.statusCode}";
//           isLoading = false;
//         });
//         print(
//             "Error fetching farms: ${response.statusCode} - ${response.body}");
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "An error occurred while fetching farms";
//         isLoading = false;
//       });
//       print("Failed to load farms: $e");
//     }
//   }

//   void _refreshFarms() {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });
//     fetchUserFarms();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         errorMessage,
//                         style: TextStyle(color: Colors.red),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _refreshFarms,
//                         child: Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : farms.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text('No farms found'),
//                           SizedBox(height: 20),
//                           ElevatedButton(
//                             onPressed: _refreshFarms,
//                             child: Text('Refresh'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : GridView.builder(
//                       padding: EdgeInsets.all(16.0),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 16.0,
//                         mainAxisSpacing: 16.0,
//                         childAspectRatio: 0.8,
//                       ),
//                       itemCount: farms.length,
//                       itemBuilder: (context, index) {
//                         final farm = farms[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => PumpListView(
//                                   farmId: farm['id'],
//                                   farmName: farm['name'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(15.0),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.3),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 80,
//                                   height: 80,
//                                   decoration: BoxDecoration(
//                                     color: farm['color'].withOpacity(0.2),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     farm['icon'],
//                                     size: 50,
//                                     color: farm['color'],
//                                   ),
//                                 ),
//                                 SizedBox(height: 12),
//                                 Text(
//                                   farm['name'],
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Location: ${farm['location']}',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   'Motors: ${farm['motor_count']}',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/pumbp.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

class FarmListView extends StatefulWidget {
  @override
  _FarmListViewState createState() => _FarmListViewState();
}

class _FarmListViewState extends State<FarmListView> {
  List<Map<String, dynamic>> farms = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserFarms();
  }

  Future<void> fetchUserFarms() async {
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
        Uri.parse('https://fahadrahman122.pythonanywhere.com/farm/my-farms/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Convert farm data
        List<Map<String, dynamic>> farmList = data
            .map((farm) => {
                  'id': farm['id'],
                  'name': farm['name'] ?? 'Unnamed Farm',
                  'location': farm['location'] ?? 'Unknown Location',
                  'motor_count': farm['motors']?.length ?? 0,
                  'icon': Icons.landscape,
                  'color': Colors.green,
                })
            .toList();

        // Update UserProvider with farm data
        Provider.of<UserProvider>(context, listen: false).setFarms(farmList);

        setState(() {
          farms = farmList;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch farms. Error: ${response.statusCode}";
          isLoading = false;
        });
        print(
            "Error fetching farms: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching farms";
        isLoading = false;
      });
      print("Failed to load farms: $e");
    }
  }

  void _refreshFarms() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    fetchUserFarms();
  }

  List<Color> _getGradientColors(int index) {
    final colorSets = [
      [Colors.green.shade300, Colors.green.shade700],
      [Colors.blue.shade300, Colors.blue.shade700],
      [Colors.orange.shade300, Colors.orange.shade700],
      [Colors.purple.shade300, Colors.purple.shade700],
      [Colors.teal.shade300, Colors.teal.shade700],
    ];

    return colorSets[index % colorSets.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading farms...',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refreshFarms,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : farms.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/empty_farm.png',
                                height: 120,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.landscape,
                                  size: 80,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Farms Found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your first farm to start monitoring',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _refreshFarms,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Refresh'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Navigate to add farm page
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Farm'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side:
                                          const BorderSide(color: Colors.green),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => fetchUserFarms(),
                        color: Colors.green,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: farms.length,
                          itemBuilder: (context, index) {
                            final farm = farms[index];
                            final gradientColors = _getGradientColors(index);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PumpListView(
                                      farmId: farm['id'],
                                      farmName: farm['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          farm['icon'],
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              farm['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    farm['location'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.water_drop,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${farm['motor_count']} Motors',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
      floatingActionButton: !isLoading && errorMessage.isEmpty
          ? FloatingActionButton(
              onPressed: _refreshFarms,
              backgroundColor: Colors.green,
              child: const Icon(Icons.refresh),
              tooltip: 'Refresh Farms',
            )
          : null,
    );
  }
}
