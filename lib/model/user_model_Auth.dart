class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? phoneNumber;
  final String? address;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.phoneNumber,
    this.address,
  });
}
