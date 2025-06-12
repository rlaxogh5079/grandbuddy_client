import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/req/task.dart';
import 'package:grandbuddy_client/utils/res/task.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/ui/dialog/dialog.dart';

class MyTaskEditor extends StatefulWidget {
  final String seniorUuid;
  const MyTaskEditor({super.key, required this.seniorUuid});

  @override
  State<MyTaskEditor> createState() => _MyTaskEditorState();
}

class _MyTaskEditorState extends State<MyTaskEditor> {
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final res = await getTasksBySenior(widget.seniorUuid);
    final list = res.tasks ?? [];
    list.sort(
      (a, b) =>
          a.isDone != b.isDone
              ? (a.isDone ? 1 : -1)
              : a.dueDate.compareTo(b.dueDate),
    );
    setState(() {
      tasks = list;
      isLoading = false;
    });
  }

  Future<void> _addTaskDialog() async {
    final _titleController = TextEditingController();
    final _descController = TextEditingController();
    DateTime? _selectedDate;

    createSmoothDialog(
      context,
      "할 일 추가",
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "제목",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "설명",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDate == null
                            ? "마감 날짜 선택"
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "취소",
              style: TextStyle(color: const Color(0xFF7BAFD4)),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final token =
                  await SecureStorage().storage.read(key: "access_token") ?? "";
              final created = await createTask(
                token,
                widget.seniorUuid,
                _titleController.text.trim(),
                _descController.text.trim(),
                _selectedDate!,
              );
              if (created != null) {
                Navigator.pop(context);
                _loadTasks();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("할 일이 추가되었습니다.")));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BAFD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text("추가"),
          ),
        ],
      ),
      const Icon(Icons.task_alt_rounded, color: Colors.blue),
    );
  }

  Future<void> _confirmDeleteDialog(String taskUuid) async {
    createSmoothDialog(
      context,
      "할 일을 삭제할까요?",
      const Text(
        "삭제된 할 일은 복구할 수 없습니다.",
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await deleteTask(taskUuid);
              if (success) {
                await _loadTasks();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("할 일이 삭제되었습니다.")));
              }
            },
            child: const Text("삭제", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      const Icon(Icons.delete_forever, color: Colors.redAccent, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: const Color(0xFF7BAFD4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(4.w),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final dueText = DateFormat(
                      'yyyy-MM-dd',
                    ).format(task.dueDate);
                    return Card(
                      color: task.isDone ? Colors.grey[200] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 0.8.h),
                      child: ListTile(
                        enabled: !task.isDone,
                        contentPadding: EdgeInsets.all(3.w),
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (val) async {
                            if (!task.isDone) {
                              setState(() {
                                task.isDone = true;
                                task.status = "completed";
                              });
                              final token = await SecureStorage().storage.read(
                                key: "access_token",
                              );
                              await completeTask(token ?? "", task.taskUuid);
                              await _loadTasks();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("완료 처리되었습니다.")),
                              );
                            }
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                task.description,
                                style: TextStyle(
                                  decoration:
                                      task.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                            ],
                            SizedBox(height: 0.5.h),
                            Text(
                              "마감일: $dueText",
                              style: TextStyle(
                                color: Colors.grey[600],
                                decoration:
                                    task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteDialog(task.taskUuid),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
