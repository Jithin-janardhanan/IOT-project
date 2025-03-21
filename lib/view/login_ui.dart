// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controller/login_controller.dart';
// import '../dashboard.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   _LoginViewState createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _PhoneController = TextEditingController();
//   final TextEditingController _Controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     final authController = Provider.of<UserProvider>(context);

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//               image: AssetImage("assets/agri.jpg"), fit: BoxFit.cover),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromARGB(255, 250, 92, 92),
//               Color.fromARGB(255, 89, 6, 6)
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Card(
//                 color:
//                     const Color.fromARGB(255, 214, 226, 123).withOpacity(0.9),
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Form(
//                     key: _formKey,
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
//                           controller: _PhoneController,
//                           decoration: InputDecoration(
//                             labelText: 'Phone NO  ',
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
//                           controller: _Controller,
//                           decoration: InputDecoration(
//                             labelText: '',
//                             prefixIcon: const Icon(Icons.lock),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your ';
//                             }
//                             return null;
//                           },
//                         ),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               // Implement forgot  logic
//                             },
//                             child: const Text('Forgot ?'),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         if (authController.statusMessage.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 16),
//                             child: Text(
//                               authController.statusMessage,
//                               style: TextStyle(
//                                 color: authController.isSuccess
//                                     ? Colors.green
//                                     : Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: authController.isLoading
//                                 ? null
//                                 : () async {
//                                     if (_formKey.currentState!.validate()) {
//                                       final isSuccess =
//                                           await authController.login(
//                                         _PhoneController.text,
//                                         _Controller.text,
//                                       );

//                                       if (isSuccess) {
//                                         Future.delayed(
//                                             const Duration(milliseconds: 500),
//                                             () {
//                                           Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => HomePage(),
//                                             ),
//                                           );
//                                         });
//                                       }
//                                     }
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: authController.isLoading
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
//     _PhoneController.dispose();
//     _Controller.dispose();
//     super.dispose();
//   }
// }

// lib/view/login_view.dart
import 'package:flutter/material.dart';
import 'package:iot/dashboard.dart';
import 'package:provider/provider.dart';

import '../controller/login_controller.dart';
import '../provider/user_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/agri.jpg"), fit: BoxFit.cover),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 250, 92, 92),
              Color.fromARGB(255, 89, 6, 6)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                color:
                    const Color.fromARGB(255, 214, 226, 123).withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'number',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _Controller,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Password';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot  logic
                            },
                            child: const Text('Forgot ?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (authController.statusMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              authController.statusMessage,
                              style: TextStyle(
                                color: authController.isSuccess
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authController.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final response =
                                          await authController.login(
                                        _phoneController.text,
                                        _Controller.text,
                                      );

                                      if (response.success &&
                                          authController.user != null) {
                                        // Update the UserProvider with the logged-in user
                                        userProvider
                                            .setUser(authController.user!);

                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomePage(),
                                            ),
                                          );
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authController.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                // Navigate to signup page
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _Controller.dispose();
    super.dispose();
  }
}
