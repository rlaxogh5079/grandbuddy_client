class GeneralResponse {
  final String message;
  final int statusCode;
  String? detail;

  GeneralResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
  });

  factory GeneralResponse.fromJson(Map<String, dynamic> json) {
    return GeneralResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
    );
  }
}
