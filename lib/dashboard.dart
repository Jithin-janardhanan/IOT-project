import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/farms_list.dart';
import 'package:iot/view/profile_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import 'view/farm_add.dart';
import 'view/login_ui.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      Uri.parse('http://127.0.0.1:8000/logout/'),
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
        backgroundColor: Colors.amberAccent,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        }),
        title: Text("IOT "),
        actions: [
          // Profile icon
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const profileView()),
              );
            },
            tooltip: 'View Profile',
          ),
        ],
      ),
      drawer: Drawer(
        // width: 250,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 60, 61, 62),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Lottie.asset('assets/water circle.json'),
            ),
            Card(
              child: ListTile(
                title: const Text('Add Farms'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFarmPage(),
                      ));
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text(
                  'logout',
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.w800),
                ),
                trailing: Icon(
                  Icons.logout,
                  color: Colors.deepOrange,
                ),
                onTap: () => _showMyDialog(),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Welcome to Home",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (user != null)
                  Text(
                    "Hello, ${user.firstName}!",
                    style: TextStyle(fontSize: 18),
                  ),
                SizedBox(height: 20),
                Text(
                  "Your Farms",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Farm list takes the rest of the available space
          Expanded(
            child: FarmListView(),
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Enter ok to logout'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => logout(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
