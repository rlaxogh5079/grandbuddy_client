class TokenModel {
  final String accessToken;
  final String tokenType;

  TokenModel({required this.accessToken, required this.tokenType});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json["access_token"] as String,
      tokenType: json["token_type"] as String,
    );
  }
}

class ResponseWithAccessToken {
  final String message;
  final int statusCode;
  String? detail;
  TokenModel? token;

  ResponseWithAccessToken({
    required this.message,
    required this.statusCode,
    this.token = null,
    this.detail = null,
  });

  factory ResponseWithAccessToken.fromJson(Map<String, dynamic> json) {
    if (json["status_code"] as int == 200) {
      return ResponseWithAccessToken(
        message: json["message"] as String,
        statusCode: json["status_code"] as int,
        token: TokenModel.fromJson(json["token"] as Map<String, dynamic>),
      );
    } else {
      return ResponseWithAccessToken(
        message: json["message"] as String,
        statusCode: json["status_code"] as int,
        detail: json["detail"] as String,
      );
    }
  }
}

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

class User {
  final String userUuid;
  final String userID;
  final String email;
  final String phone;
  final String nickname;
  final String birthDay;
  final String role;
  final String created;
  final String updated;
  final String address;
  final String profile;

  User({
    required this.userUuid,
    required this.userID,
    required this.email,
    required this.phone,
    required this.nickname,
    required this.birthDay,
    required this.role,
    required this.created,
    required this.updated,
    required this.address,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userUuid: json["user_uuid"],
      userID: json["user_id"],
      email: json["email"],
      phone: json["phone"],
      nickname: json["nickname"],
      birthDay: json["birthday"],
      role: json["role"],
      created: json["created"],
      updated: json["updated"],
      address: json["address"],
      profile: json["profile"],
    );
  }
}

class ProfileResponse {
  final String message;
  final int statusCode;
  String? detail;
  User? user;

  ProfileResponse({
    required this.message,
    required this.statusCode,
    this.detail = null,
    this.user = null,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    if (json["status_code"] as int == 200) {
      return ProfileResponse(
        message: json["message"] as String,
        statusCode: json["status_code"] as int,
        user: User.fromJson(json["user"] as Map<String, dynamic>),
      );
    } else {
      return ProfileResponse(
        message: json["message"] as String,
        statusCode: json["status_code"] as int,
        detail: json["detail"] as String,
      );
    }
  }
}

class Request {
  final String requestUuid;
  final String seniorUuid;
  final String title;
  final String? description;
  final String status;
  final String created;
  String? completed;

  Request({
    required this.requestUuid,
    required this.seniorUuid,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    this.completed = null,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestUuid: json["request_uuid"] as String,
      seniorUuid: json["senior_uuid"] as String,
      title: json["title"] as String,
      description: json["description"] as String,
      status: json["status"] as String,
      created: json["created"] as String,
      completed: json["completed"] != null ? json["completed"] as String : null,
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
