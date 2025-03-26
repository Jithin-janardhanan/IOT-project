
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iot/pumbp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmListView extends StatefulWidget {
  @override
  _FarmListViewState createState() => _FarmListViewState();
}

class _FarmListViewState extends State<FarmListView> {
  List<Map<String, dynamic>> farms = [];

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
        print("No token found, please login first");
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
        setState(() {
          farms = data
              .map((farm) => {
                    'id': farm['id'],
                    'name': farm['name'] ?? 'Unknown',
                    'location': farm['location'] ?? 'Unknown',
                    'icon': Icons.landscape,
                    'color': Colors.green,
                    'motor_count':
                        farm['motors'].length, // Add motor count if needed
                  })
              .toList();
        });
      } else {
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Failed to load farms: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return farms.isEmpty
        ? Center(child: CircularProgressIndicator())
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
                            color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Location: ${farm['location']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Motors: ${farm['motor_count']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
