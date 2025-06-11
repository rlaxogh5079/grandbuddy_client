import 'dart:convert';
import 'package:grandbuddy_client/utils/res/application.dart';
import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/request.dart';

const String host = "http://3.27.71.121:8000/request";

// 요청 둘러보기(조회)
Future<RequestListResponse> getRequestExplore() async {
  http.Response response = await http.get(
    Uri.parse("$host/explore/all"),
    headers: {"Content-Type": "application/json"},
  );
  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestListResponse.fromJson(json.decode(responseBody));
}

// 요청 생성 (추가 필드 포함)
Future<RequestResponse> createRequest(
  String accessToken,
  String title,
  String description,
  String date, // '2024-06-15' 등 ISO형태
  String availableStartTime, // '14:00:00' 등 ISO형태
  String availableEndTime, // '16:00:00' 등 ISO형태
) async {
  Map<String, dynamic> data = {
    "title": title,
    "description": description,
    "date": date,
    "available_start_time": availableStartTime,
    "available_end_time": availableEndTime,
  };

  http.Response response = await http.post(
    Uri.parse(host),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode(data),
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestResponse.fromJson(json.decode(responseBody));
}

// 단건 상세 조회
Future<RequestResponse> getRequestByUuid(String requestUuid) async {
  http.Response response = await http.get(
    Uri.parse("$host/$requestUuid"),
    headers: {"Content-Type": "application/json"},
  );
  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestResponse.fromJson(json.decode(responseBody));
}

// 신청 API
Future<ApplicationResponse> applyToRequest(
  String accessToken,
  String requestUuid,
) async {
  final response = await http.post(
    Uri.parse("$host/$requestUuid/apply"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  return ApplicationResponse.fromJson(
    json.decode(utf8.decoder.convert(response.bodyBytes)),
  );
}

Future<RequestListResponse> getRequestsBySenior(String accessToken) async {
  final response = await http.get(
    Uri.parse(host),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestListResponse.fromJson(json.decode(responseBody));
}

Future<RequestListResponse> getRequestsByApplicant(String accessToken) async {
  final response = await http.get(
    Uri.parse("$host/applied/me"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestListResponse.fromJson(json.decode(responseBody));
}

Future<RequestResponse> cancelApplication(
  String accessToken,
  String requestUuid,
) async {
  final response = await http.delete(
    Uri.parse("http://3.27.71.121:8000/request/$requestUuid/application"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );
  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestResponse.fromJson(json.decode(responseBody));
}

Future<RequestResponse> cancelRequest(
  String accessToken,
  String requestUuid,
) async {
  final response = await http.delete(
    Uri.parse("http://3.27.71.121:8000/request/$requestUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );
  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestResponse.fromJson(json.decode(responseBody));
}
