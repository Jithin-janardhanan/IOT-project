// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'view/login_ui.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to show profile information
  void _showProfileInfo(BuildContext context) {
    // Get the user data from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profile Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileItem('Username', user.username),
              _buildProfileItem('Name', '${user.firstName} ${user.lastName}'),
              _buildProfileItem('Email', user.email),
              _buildProfileItem('Phone', user.phoneNumber),
              _buildProfileItem('Address', user.address),
              _buildProfileItem('Role', user.role),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build profile item
  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(fontSize: 16),
          ),
          Divider(),
        ],
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token"); // Retrieve stored token

    if (token == null) {
      print("No token found, already logged out.");
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Token $token' // Send token in the header
    };

    var request = http.Request(
      'POST',
      Uri.parse('http://192.168.20.14:8000/logout/'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("Logout successful");

      // Remove token from storage
      await prefs.remove("token");

      // Clear user data in provider
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
        (route) => false,
      );
    } else {
      print("Logout failed: ${response.reasonPhrase}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from provider to access throughout the page
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          // Profile icon
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _showProfileInfo(context),
            tooltip: 'View Profile',
          ),
          // Logout icon
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Home",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (user != null)
              Text(
                "Hello, ${user.firstName}!",
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
