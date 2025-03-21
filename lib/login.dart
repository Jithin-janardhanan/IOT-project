// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:iot/dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Login extends StatefulWidget {
//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _formkey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String _statusMessage = '';
//   bool _isSuccess = false;

//   Future<void> _login() async {
//     if (!_formkey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _statusMessage = '';
//       _isSuccess = false;
//     });

//     try {
//       var headers = {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json'
//       };

//       var uri = Uri.parse('http://192.168.20.10:8000/login/');

//       // If you're on a physical device:
//       // var uri = Uri.parse('http://YOUR_MACHINE_IP:8000/login/');

//       var body = json.encode({
//         "username": _usernameController.text.trim(),
//         "password": _passwordController.text
//       });

//       print('Attempting to connect to: $uri');

//       var response = await http
//           .post(uri, headers: headers, body: body)
//           .timeout(Duration(seconds: 10));

//       setState(() {
//         _isLoading = false;
//       });

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String token = data["token"]; // Assuming API returns a token

//         // Save token to SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString("token", token);
//         setState(() {
//           _statusMessage = 'Login successful!';
//           _isSuccess = true;
//         });

//         // Navigate to dashboard
//         Future.delayed(const Duration(milliseconds: 500), () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//           );
//         });
//       } else if (response.statusCode == 400) {
//         _statusMessage = 'check password and email';
//         _isSuccess = false;
//       } else {
//         setState(() {
//           _statusMessage =
//               'Login failed: ${response.statusCode} - ${response.reasonPhrase ?? 'Unknown error'}';
//           _isSuccess = false;
//         });
//       }
//     } catch (e) {
//       print('Exception during login: ${e.toString()}');
//       setState(() {
//         _isLoading = false;
//         _statusMessage =
//             'Connection error: Unable to reach the server. Please check your network connection and server status.';
//         _isSuccess = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//               image: AssetImage("assets/agri.jpg"), fit: BoxFit.cover),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color.fromARGB(255, 250, 92, 92),
//               const Color.fromARGB(255, 89, 6, 6)
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Card(
//                 color: const Color.fromARGB(255, 214, 226, 123)
//                     .withValues(alpha: .9),
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Form(
//                     key: _formkey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           'Welcome Back',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Log in to continue',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         TextFormField(
//                           controller: _usernameController,
//                           decoration: InputDecoration(
//                             labelText: 'Username',
//                             prefixIcon: const Icon(Icons.person),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your username';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 20),
//                         TextFormField(
//                           controller: _passwordController,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             prefixIcon: const Icon(Icons.lock),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your password';
//                             }
//                             return null;
//                           },
//                         ),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               // Implement forgot password logic
//                             },
//                             child: const Text('Forgot Password?'),
//                           ),
//                         ),

//                         // Toggle between mock and API authentication (for development)

//                         const SizedBox(height: 8),

//                         if (_statusMessage.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 16),
//                             child: Text(
//                               _statusMessage,
//                               style: TextStyle(
//                                 color: _isSuccess ? Colors.green : Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _login,
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white)
//                                 : const Text(
//                                     'Log In',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Don't have an account?"),
//                             TextButton(
//                               onPressed: () {
//                                 // Navigate to signup page
//                               },
//                               child: const Text('Sign Up'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// // Dashboard page
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome, Jithin!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text('You have successfully logged in.'),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Log Out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
