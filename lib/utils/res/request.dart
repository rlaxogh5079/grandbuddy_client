class Request {
  final String requestUuid;
  final String seniorUuid;
  final String title;
  final String? description;
  final String status;
  final String created;
  String? completed;
  String? availableDate;
  String? availableStartTime;
  String? availableEndTime;
  int? views;
  int? applications;

  Request({
    required this.requestUuid,
    required this.seniorUuid,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    this.completed,
    this.availableDate,
    this.availableStartTime,
    this.availableEndTime,
    this.views,
    this.applications,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestUuid: json["request_uuid"] as String,
      seniorUuid: json["senior_uuid"] as String,
      title: json["title"] as String,
      description: json["description"] as String?,
      status: json["status"] as String,
      created: json["created"] as String,
      completed: json["completed"] != null ? json["completed"] as String : null,
      availableDate: json["available_date"] as String?,
      availableStartTime: json["available_start_time"] as String?,
      availableEndTime: json["available_end_time"] as String?,
      views: json["views"] != null ? json["views"] as int : null,
      applications:
          json["applications"] != null ? json["applications"] as int : null,
    );
  }
}

class RequestResponse {
  final String message;
  final int statusCode;
  String? detail;
  Request? request;

  RequestResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
    this.request = null,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
      request:
          json["request"] != null
              ? Request.fromJson(json["request"] as Map<String, dynamic>)
              : null,
    );
  }
}

class RequestListResponse {
  final String message;
  final int statusCode;
  String? detail;
  List<Request>? requests;

  RequestListResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
    this.requests = null,
  });

  factory RequestListResponse.fromJson(Map<String, dynamic> json) {
    return RequestListResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
      requests:
          (json["requests"] as List<dynamic>)
              .map((e) => Request.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
