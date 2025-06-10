class Application {
  final String applicationUuid;
  final String requestUuid;
  final String applicantUuid;
  final String status;
  final String created;

  Application({
    required this.applicationUuid,
    required this.requestUuid,
    required this.applicantUuid,
    required this.status,
    required this.created,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationUuid: json["application_uuid"] as String,
      requestUuid: json["request_uuid"] as String,
      applicantUuid: json["applicant_uuid"] as String,
      status: json["status"] as String,
      created: json["created"] as String,
    );
  }
}

class ApplicationResponse {
  final String message;
  final int statusCode;
  Application? application;
  String? detail;

  ApplicationResponse({
    required this.message,
    required this.statusCode,
    this.application,
    this.detail,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
      application:
          json["application"] != null
              ? Application.fromJson(
                json["application"] as Map<String, dynamic>,
              )
              : null,
    );
  }
}
