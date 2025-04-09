import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iot/model/user_model_Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  String statusMessage = '';
  bool isSuccess = false;
  UserModel? _user;

  UserModel? get user => _user;

  // Get login status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Login method
  Future<AuthResponse> login(String phone, String password) async {
    isLoading = true;
    statusMessage = '';
    isSuccess = false;
    notifyListeners();

    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      var uri = Uri.parse('https://fahadrahman122.pythonanywhere.com/login/');
      var body = json.encode({"phone_number": phone, "password": password});

      var response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String token = data["token"] ?? '';

        // Extract user data from response
        String id = (data["id"] ?? '').toString();
        String email = data["email"] ?? '';
        String firstName = data["first_name"] ?? '';
        String lastName = data["last_name"] ?? '';
        String role = data["role"] ?? '';

        String address = data["address"] ?? '';
        bool success = data["Status"] ?? false;
        String phoneNumber = data["phone_number"] ?? '';
        String username = data["username"] ?? '';

        // Save token to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("phone_number:", phoneNumber);

        // Create user model with response data
        _user = UserModel(
          phoneNumber: phoneNumber,
          token: token,
          id: id,
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          address: address,
          success: success,
        );

        statusMessage = 'Login successful!';
        isSuccess = true;
        notifyListeners();

        return AuthResponse(
          success: true,
          message: 'Login successful!',
          token: token,
          id: int.tryParse(id),
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          phoneNumber: phoneNumber,
          address: address,
        );
      } else if (response.statusCode == 400) {
        statusMessage = 'Check password and Phone';
        isSuccess = false;
        notifyListeners();
        return AuthResponse(
          success: false,
          message: 'Check password and phone',
          id: null,
          username: null,
          email: null,
          firstName: null,
          lastName: null,
          role: null,
          phoneNumber: null,
          address: null,
        );
      } else {
        statusMessage =
            'Login failed: ${response.statusCode} - ${response.reasonPhrase ?? 'Unknown error'}';
        isSuccess = false;
        notifyListeners();
        return AuthResponse(
          success: false,
          message: statusMessage,
          id: null,
          username: null,
          email: null,
          firstName: null,
          lastName: null,
          role: null,
          phoneNumber: null,
          address: null,
        );
      }
    } catch (e) {
      isLoading = false;
      print("Specific error: $e");
      statusMessage =
          'Connection error: Unable to reach the server. Please check your network connection and server status.';
      isSuccess = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: statusMessage,
        id: null,
        username: null,
        email: null,
        firstName: null,
        lastName: null,
        role: null,
        phoneNumber: null,
        address: null,
      );
    }
  }

  // Logout method
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone_number');
    _user = null;
    notifyListeners();
  }
}
