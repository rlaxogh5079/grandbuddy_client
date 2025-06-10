import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/res/general.dart';

const String host = "http://13.211.30.171:8000/match";

Future<MatchCreateResponse> createMatch(
  String accessToken,
  String requestUuid,
) async {
  http.Response response = await http.post(
    Uri.parse("$host/$requestUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return MatchCreateResponse.fromJson(json.decode(responseBody));
}

Future<MatchResponse> searchMatch(
  String accessToken,
  String requestUuid,
) async {
  http.Response response = await http.get(
    Uri.parse("$host?request_uuid=$requestUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return MatchResponse.fromJson(json.decode(responseBody));
}

Future<MatchesResponse> getMyMatch(String accessToken) async {
  http.Response response = await http.get(
    Uri.parse("$host/me"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return MatchesResponse.fromJson(json.decode(responseBody));
}

Future<GeneralResponse> deleteMatch(
  String accessToken,
  String requestUuid,
) async {
  http.Response response = await http.delete(
    Uri.parse("$host/$requestUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return GeneralResponse.fromJson(json.decode(responseBody));
}

Future<GeneralResponse> completeMatch(
  String accessToken,
  String matchUuid,
) async {
  http.Response response = await http.patch(
    Uri.parse("$host/complete/$matchUuid"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return GeneralResponse.fromJson(json.decode(responseBody));
}
