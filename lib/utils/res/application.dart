class Application {
  final String applicationUuid;
  final String requestUuid;
  final String youthUuid;
  final String status;
  final String created;

  Application({
    required this.applicationUuid,
    required this.requestUuid,
    required this.youthUuid,
    required this.status,
    required this.created,
  });

  @override
  Map toJson() {
    return {
      "applicationUuid": applicationUuid,
      "requestUuid": requestUuid,
      "youthUuid": youthUuid,
      "status": status,
      "created": created,
    };
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationUuid: json["application_uuid"] as String,
      requestUuid: json["request_uuid"] as String,
      youthUuid: json["youth_uuid"] as String,
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

class ApplicationListResponse {
  final String message;
  final int statusCode;
  List<Application> applications;

  ApplicationListResponse({
    required this.message,
    required this.statusCode,
    required this.applications,
  });

  factory ApplicationListResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationListResponse(
      message: json['message'],
      statusCode: json['status_code'],
      applications:
          (json['applications'] as List<dynamic>)
              .map((e) => Application.fromJson(e))
              .toList(),
    );
  }
}
