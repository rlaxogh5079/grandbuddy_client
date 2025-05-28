class Match {
  final String matchUuid;
  final String requestUuid;
  final String youthUuid;
  final String status;
  final String created;

  Match({
    required this.matchUuid,
    required this.requestUuid,
    required this.youthUuid,
    required this.status,
    required this.created,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchUuid: json["match_uuid"],
      requestUuid: json["request_uuid"],
      youthUuid: json["youth_uuid"],
      status: json["status"],
      created: json["created"],
    );
  }
}

class MatchCreateResponse {
  final String message;
  final int statusCode;
  String? detail;
  String? matchUuid;

  MatchCreateResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
    this.matchUuid = null,
  });

  factory MatchCreateResponse.fromJson(Map<String, dynamic> json) {
    return MatchCreateResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
      matchUuid:
          json["match_uuid"] != null ? json["match_uuid"] as String : null,
    );
  }
}

class MatchResponse {
  final String message;
  final int statusCode;
  String? detail;
  Match? match;

  MatchResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
    this.match = null,
  });

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    return MatchResponse(
      message: json["message"] as String,
      statusCode: json["status_code"] as int,
      detail: json["detail"] != null ? json["detail"] as String : null,
      match:
          json["match"] != null
              ? Match.fromJson(json["match"] as Map<String, dynamic>)
              : null,
    );
  }
}
