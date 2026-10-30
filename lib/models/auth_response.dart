class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? code;

  AuthResponse(this.success, this.message, [this.data, this.code]);
}
