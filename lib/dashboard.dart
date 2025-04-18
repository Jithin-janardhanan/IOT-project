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
import 'package:url_launcher/url_launcher.dart';

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
      Uri.parse('https://fahadrahman122.pythonanywhere.com/logout/'),
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
        elevation: 2,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
            tooltip: 'Open menu',
          );
        }),
        title: const Text("IOT Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
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
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 60, 61, 62),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Center(
                child: Lottie.asset('assets/water circle.json'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Card(
                  //   margin:
                  //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   elevation: 2,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: ListTile(
                  //     contentPadding: const EdgeInsets.symmetric(
                  //         horizontal: 16, vertical: 4),
                  //     leading:
                  //         const Icon(Icons.add_business, color: Colors.green),
                  //     title: const Text('Add Farms',
                  //         style: TextStyle(fontWeight: FontWeight.w500)),
                  //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  //     onTap: () {
                  //       Navigator.pushReplacement(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => AddFarmPage(),
                  //           ));
                      
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading:
                          const Icon(Icons.logout, color: Colors.deepOrange),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                            launchUrl(Uri.parse(
                                "https://www.freeprivacypolicy.com/live/f2379df2-bc9a-444b-9b35-a71f2d885496"));
                          },
                    ),
                  ),
                   const SizedBox(height: 8),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading:
                          const Icon(Icons.logout, color: Colors.deepOrange),
                      title: const Text(
                        'Privacy and pollicy',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () =>(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to Your Farm Dashboard",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (user != null)
                    Text(
                      "Hello, ${user.firstName}!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Farms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Add functionality to refresh or view all farms
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Refresh"),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFarmPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        tooltip: 'Add New Farm',
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
