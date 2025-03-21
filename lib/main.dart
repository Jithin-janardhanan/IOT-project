
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/login_controller.dart';
import 'provider/user_provider.dart';
import 'view/login_ui.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'IoT App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}