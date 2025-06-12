import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getLastMessage(String matchUuid) async {
  final res = await http.get(
    Uri.parse("http://3.27.71.121:8000/message/last/$matchUuid"),
  );
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }
  return null;
}

Future<List<Map<String, dynamic>>> fetchChatHistory(String matchUuid) async {
  final res = await http.get(
    Uri.parse("http://3.27.71.121:8000/message/list/$matchUuid"),
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["messages"] ?? []);
  }
  return [];
}
