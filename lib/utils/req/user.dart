import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:grandbuddy_client/utils/res/user.dart';

const String host = "http://172.17.162.46:8000/user";

Future<ResponseWithAccessToken> login(String userID, String password) async {
  Map data = {"user_id": userID, "password": password};

  http.Response response = await http.post(
    Uri.parse("$host/auth/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return ResponseWithAccessToken.fromJson(json.decode(responseBody));
}

Future<GeneralResponse> register(
  String userID,
  String password,
  String nickname,
  String email,
  String phone,
  String birthDay,
  int role,
  String address,
  String profile,
) async {
  Map data = {
    "user_id": userID,
    "password": password,
    "nickname": nickname,
    "email": email,
    "phone": phone,
    "birthday": "$birthDay",
    "role": role,
    "address": address,
    "profile": profile,
  };

  http.Response response = await http.post(
    Uri.parse("$host/"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return GeneralResponse.fromJson(json.decode(responseBody));
}

Future<ProfileResponse> getProfile(String accessToken) async {
  http.Response response = await http.get(
    Uri.parse("$host/"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return ProfileResponse.fromJson(json.decode(responseBody));
}

Future<ProfileResponse> getUserByUuid(String uuid) async {
  final response = await http.get(
    Uri.parse("$host/$uuid"),
    headers: {"Content-Type": "application/json"},
  );

  String responseBody = utf8.decoder.convert(response.bodyBytes);
  return ProfileResponse.fromJson(json.decode(responseBody));
}
