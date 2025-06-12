class Task {
  final String taskUuid;
  final String userUuid; // owner
  final String title;
  final String description;
  final DateTime created;
  final DateTime dueDate;
  String status; // 예: 'pending', 'completed'
  bool isDone;

  Task({
    required this.taskUuid,
    required this.userUuid,
    required this.title,
    required this.description,
    required this.status,
    required this.created,
    required this.dueDate,
  }) : isDone = status == 'completed';

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskUuid: json['task_uuid'],
      userUuid: json['user_uuid'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      created: DateTime.parse(json['created']),
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}

class TaskListResponse {
  final List<Task>? tasks;

  TaskListResponse({this.tasks});

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['tasks'] as List?)?.map((e) => Task.fromJson(e)).toList();
    return TaskListResponse(tasks: list);
  }
}
