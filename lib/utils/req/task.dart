import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grandbuddy_client/utils/res/task.dart';

const String baseUrl = "http://3.27.71.121:8000";

// ✅ GET /task/senior/{user_uuid}
Future<TaskListResponse> getTasksBySenior(String userUuid) async {
  final res = await http.get(Uri.parse('$baseUrl/task/senior/$userUuid'));
  print(res.body);
  if (res.statusCode == 200) {
    return TaskListResponse.fromJson(jsonDecode(res.body));
  }
  return TaskListResponse(tasks: []);
}

Future<Task?> createTask(
  String accessToken,
  String userUuid,
  String title,
  String description,
  DateTime dueDate,
) async {
  final res = await http.post(
    Uri.parse('$baseUrl/task'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode({
      'user_uuid': userUuid,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
    }),
  );
  if (res.statusCode == 201) {
    return Task.fromJson(jsonDecode(res.body)['task']);
  }
  return null;
}

// ✅ DELETE /task/{task_uuid}
Future<bool> deleteTask(String uuid) async {
  final res = await http.delete(Uri.parse('$baseUrl/task/$uuid'));
  return res.statusCode == 200;
}

// ✅ PATCH /task/{task_uuid}/complete
Future<bool> completeTask(String accessToken, String uuid) async {
  final res = await http.patch(
    Uri.parse('$baseUrl/task/$uuid/complete'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  return res.statusCode == 200;
}

// ✅ PATCH /task/{task_uuid} - 수정
Future<bool> updateTask(
  String uuid,
  String title,
  String description,
  DateTime dueDate,
) async {
  final res = await http.patch(
    Uri.parse('$baseUrl/task/$uuid'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
    }),
  );
  return res.statusCode == 200;
}
