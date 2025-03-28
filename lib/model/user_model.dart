
class UserModel {
  final bool success;
  
  final String token;
  String id;
  String username;
  String email;
  String firstName;
  String lastName;
  String role;
  String phoneNumber;
  String address;
  

  UserModel({
    
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phoneNumber,
    required this.address,
    required this.success,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      
      token: json['token'] ?? '',
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      success: json['Status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone_number': phoneNumber,
      'address': address,
    };
  }
}