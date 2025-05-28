import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/match.dart';

const String host = "http://172.17.162.46:8000/match";

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
