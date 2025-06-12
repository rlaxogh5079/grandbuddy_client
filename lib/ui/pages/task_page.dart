import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/widgets/matched_user_list.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/widgets/my_task_editor.dart';
import 'package:grandbuddy_client/ui/widgets/readonly_task_list.dart';

class TasksPage extends StatelessWidget {
  final User user;

  const TasksPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.role == 'senior') {
      return MyTaskEditor(seniorUuid: user.userUuid);
    } else if (user.role == 'youth') {
      return MatchedUserListPage(); // 매칭된 노인 정보 내부에서 처리
    } else {
      return const Center(child: Text("권한이 없습니다."));
    }
  }
}
