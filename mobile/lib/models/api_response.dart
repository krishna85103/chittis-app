class ApiResponse {
  final bool success;
  final String message;
  final String? email;
  final String? role;

  ApiResponse({
    required this.success,
    required this.message,
    this.email,
    this.role,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: json['email'],
      role: json['role'],
    );
  }

  bool get isAdmin =>
      role != null && role!.toUpperCase() == 'ADMIN';
}
