import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class AddFarmPage extends StatefulWidget {
  @override
  _AddFarmPageState createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final _formKey = GlobalKey<FormState>();

  // Farm controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Motors and Valves
  List<Map<String, dynamic>> _motors = [];

  bool _isLoading = false;
  String? _errorMessage;

  void _addMotor() {
    setState(() {
      _motors.add({
        'id': null, // Will be assigned by backend
        'motor_type': '',
        'valve_count': 1,
        // Removed 'farm': null
        'valves': [_createValve(1)]
      });
    });
  }

  Map<String, dynamic> _createValve(int index) {
    return {
      'id': null, // Will be assigned by backend
      'name': 'Valve $index',
      'is_active': 0
    };
  }

  void _addValve(int motorIndex) {
    setState(() {
      int newValveIndex = _motors[motorIndex]['valves'].length + 1;
      _motors[motorIndex]['valves'].add(_createValve(newValveIndex));
      _motors[motorIndex]['valve_count'] = _motors[motorIndex]['valves'].length;
    });
  }

  void _removeValve(int motorIndex, int valveIndex) {
    setState(() {
      _motors[motorIndex]['valves'].removeAt(valveIndex);
      _motors[motorIndex]['valve_count'] = _motors[motorIndex]['valves'].length;
    });
  }

  void _removeMotor(int motorIndex) {
    setState(() {
      _motors.removeAt(motorIndex);
    });
  }

  Future<void> _submitFarm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate motors
    for (var motor in _motors) {
      if (motor['motor_type'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please specify motor type for all motors'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Start loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      // Get current user from UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (token == null || user == null) {
        throw Exception("Authentication required");
      }

      // Prepare request headers
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      };

      // Prepare request body
      var requestBody = {
        "name": _nameController.text.trim(),
        "location": _locationController.text.trim(),
        "owner": int.tryParse(user.id) ?? 0, // Ensures it's an integer

        "motors": _motors
      };
      print('Request Body: ${json.encode(requestBody)}');

      // Send POST request
      var response = await http.post(
        Uri.parse('https://fahadrahman122.pythonanywhere.com/farm/farms/'),
        headers: headers,
        body: json.encode(requestBody),
      );

      // Handle response
      if (response.statusCode == 201) {
        // Parse the response to get the created farm details
        var responseBody = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form and pop page
        Navigator.pop(context, responseBody);
      } else {
        // Handle error response
        var errorBody = json.decode(response.body);
        setState(() {
          _errorMessage = errorBody['detail'] ?? 'Failed to add farm';
        });
      }
    } catch (e) {
      // Handle any exceptions
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Stop loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Farm'),
        backgroundColor: Colors.amberAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Message Display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              // Farm Details
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Farm Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter farm name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter farm location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Motors Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Motors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addMotor,
                    icon: Icon(Icons.add),
                    label: Text('Add Motor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Dynamic Motors List
              if (_motors.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _motors.length,
                  itemBuilder: (context, motorIndex) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Motor ${motorIndex + 1}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeMotor(motorIndex),
                                )
                              ],
                            ),
                            SizedBox(height: 16),
                            // Motor Type Dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Motor Type',
                                border: OutlineInputBorder(),
                              ),
                              value: _motors[motorIndex]['motor_type'] == ''
                                  ? null
                                  : _motors[motorIndex]['motor_type'],
                              items: [
                                'single_phase',
                                'double_phase',
                                'triple_phase'
                              ].map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.replaceAll('_', ' ')),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _motors[motorIndex]['motor_type'] = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select motor type';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Valves Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Valves',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _addValve(motorIndex),
                                  icon: Icon(Icons.add),
                                  label: Text('Add Valve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amberAccent,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Valves List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _motors[motorIndex]['valves'].length,
                              itemBuilder: (context, valveIndex) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _motors[motorIndex]
                                            ['valves'][valveIndex]['name'],
                                        decoration: InputDecoration(
                                          labelText: 'Valve Name',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          _motors[motorIndex]['valves']
                                              [valveIndex]['name'] = value;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    // Changed to use 0/1 instead of boolean
                                    Checkbox(
                                      value: _motors[motorIndex]['valves']
                                              [valveIndex]['is_active'] ==
                                          1,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _motors[motorIndex]['valves']
                                                  [valveIndex]['is_active'] =
                                              value! ? 1 : 0;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () =>
                                          _removeValve(motorIndex, valveIndex),
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitFarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add Farm',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
