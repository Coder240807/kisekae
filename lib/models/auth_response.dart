class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? errorCode;
  final Map<String, dynamic>? errorDetails;

  AuthResponse(
    this.success,
    this.message, [
    this.data,
    this.errorCode,
    this.errorDetails,
  ]);
}
