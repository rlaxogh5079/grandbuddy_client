import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/request.dart';

const String host = "http://172.17.162.46:8000/request";

Future<RequestListResponse> getRequestExplore() async {
  http.Response response = await http.get(
    Uri.parse("$host/explore/all"),
    headers: {"Content-Type": "application/json"},
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return RequestListResponse.fromJson(json.decode(responseBody));
}

Future<RequestResponse> createRequest(
  String accessToken,
  String title,
  String description,
) async {
  Map data = {"title": title, "description": description};
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
