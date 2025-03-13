
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool status = true;
  String responseMessage = "";

  Future<void> sendData() async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      var request =
          http.Request('POST', Uri.parse('http://192.168.20.12:8000/create'));
      request.body = json.encode({
        "id": 1,
        "username": usernameController.text.trim(),
        "phone": phoneController.text.trim(),
        "Status": status
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody =
          await response.stream.bytesToString(); // ✅ Read response body

      setState(() {
        responseMessage = response.statusCode == 200
            ? "Success: $responseBody"
            : "Error: $responseBody";
      });
    } catch (e) {
      setState(() => responseMessage = "Exception: $e");
      print("Error in sendData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Form")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text("Status"),
              value: status,
              onChanged: (bool value) {
                setState(() {
                  status = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              child: Text("Submit"),
            ),
            SizedBox(height: 20),
            Text(responseMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
