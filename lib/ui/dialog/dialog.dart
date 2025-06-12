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

class _DynamicDialog extends StatelessWidget {
  final Widget? leadingIcon;
  final String title;
  final Widget content;
  final Widget actions;

  const _DynamicDialog({
    Key? key,
    this.leadingIcon,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        backgroundColor: const Color(0xFFFDFDFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
        title: Column(
          children: [
            if (leadingIcon != null) ...[
              Center(child: leadingIcon),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: content,
        actions: [actions],
      ),
    );
  }
}
