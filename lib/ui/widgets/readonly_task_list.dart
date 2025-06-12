import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/res/task.dart';
import 'package:grandbuddy_client/utils/req/task.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/res/match.dart';

class ReadOnlyTaskList extends StatefulWidget {
  final Match match;

  const ReadOnlyTaskList({super.key, required this.match});

  @override
  State<ReadOnlyTaskList> createState() => _ReadOnlyTaskListState();
}

class _ReadOnlyTaskListState extends State<ReadOnlyTaskList> {
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchedTasks();
  }

  Future<void> _loadMatchedTasks() async {
    final reqRes = await getRequestByUuid(widget.match.requestUuid);
    final seniorUuid = reqRes.request?.seniorUuid;

    if (seniorUuid == null) {
      setState(() => isLoading = false);
      return;
    }

    final taskRes = await getTasksBySenior(seniorUuid);
    setState(() {
      tasks = taskRes.tasks ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: const Text("체크리스트", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? const Center(child: Text("체크리스트가 비어 있습니다."))
              : Padding(
                padding: EdgeInsets.all(4.w),
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: task.isDone ? Colors.grey[200] : Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 1.5.h,
                          horizontal: 4.w,
                        ),
                        leading: Icon(
                          task.isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          color: task.isDone ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  task.description,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                    decoration:
                                        task.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                              ),
                            Text(
                              "마감일: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                                decoration:
                                    task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
