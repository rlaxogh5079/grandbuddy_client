import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/application.dart'; // response 모델

Future<ApplicationListResponse> getApplicationsByRequest(
  String accessToken,
  String requestUuid,
) async {
  final response = await http.get(
    Uri.parse("http://3.27.71.121:8000/request/$requestUuid/applications"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );
  return ApplicationListResponse.fromJson(
    json.decode(utf8.decode(response.bodyBytes)),
  );
}

Future<bool> acceptApplication({
  required String accessToken,
  required String requestUuid,
  required String youthUuid,
}) async {
  final response = await http.post(
    Uri.parse("http://3.27.71.121:8000/request/$requestUuid/accept/$youthUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  return response.statusCode == 200 || response.statusCode == 201;
}

Future<bool> rejectApplication({
  required String accessToken,
  required String requestUuid,
  required String youthUuid,
}) async {
  final response = await http.post(
    Uri.parse(
      "http://3.27.71.121:8000/application/$requestUuid/reject/$youthUuid",
    ),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

Future<ApplicationListResponse> getMyApplications(String accessToken) async {
  final response = await http.get(
    Uri.parse("http://3.27.71.121:8000/request/applied/me"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return ApplicationListResponse.fromJson(json.decode(responseBody));
}
