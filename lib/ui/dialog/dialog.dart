import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/request.dart';

// 다이얼로그 함수
void createSmoothDialog(
  dynamic context,
  String title,
  Widget content,
  Widget actions, [
  dynamic leadingIcon,
  bool allowBackgroundDismiss = true,
]) {
  showDialog(
    context: context,
    barrierDismissible: allowBackgroundDismiss,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return _DynamicDialog(
            actions: actions,
            title: title,
            content: content,
            leadingIcon: leadingIcon,
          );
        },
      );
    },
  );
}

// 다이얼로그 화면 구성
// ignore: must_be_immutable
class _DynamicDialog extends StatefulWidget {
  var leadingIcon;
  var title;
  var content;
  var actions;

  _DynamicDialog({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  State<_DynamicDialog> createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<_DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              widget.leadingIcon is Icon
                  ? <Widget>[
                    widget.leadingIcon,
                    Text(
                      " ${widget.title}",
                    ), // For space between icon and title
                  ]
                  : <Widget>[
                    Text(widget.title), // For space between icon and title
                  ],
        ),
        content: Container(child: widget.content),
        actions: [widget.actions],
      ),
    );
  }
}

// + 버튼 눌렀을 때 나타나는 요청 폼 다이얼로그
void showAddRequestDialog(
  BuildContext context,
  String accessToken,
  Function refreshState,
) {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  createSmoothDialog(
    context,
    "할 일 요청",
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: '설명',
            border: OutlineInputBorder(),
            floatingLabelAlignment: FloatingLabelAlignment.start,
            labelStyle: TextStyle(),
          ),
          maxLines: 4,
        ),
        SizedBox(height: 16.0),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            String title = titleController.text;
            String description = descriptionController.text;

            if (title.isEmpty || description.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('두 가지 항목 다 입력해주세요.')));
            } else {
              RequestResponse response = await createRequest(
                accessToken,
                title,
                description,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message),
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.of(context).pop();
              refreshState();
            }
          },
          child: Text('요청하기'),
        ),
      ],
    ),
  );
}
