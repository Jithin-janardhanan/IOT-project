 
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
        Uri.parse('http://127.0.0.1:8000/farm/my-farms/'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: _refreshFarms,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : farms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No farms found'),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _refreshFarms,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: farms.length,
                      itemBuilder: (context, index) {
                        final farm = farms[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PumpDetailView(
                                  pumpName: farm['name'],
                                  farmId: farm['id'],
                                  farmName: farm['name'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: farm['color'].withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    farm['icon'],
                                    size: 50,
                                    color: farm['color'],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  farm['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Location: ${farm['location']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Motors: ${farm['motor_count']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                    },
                  ),
    );
  }
}