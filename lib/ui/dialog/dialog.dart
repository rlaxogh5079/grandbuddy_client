import 'dart:ui';

import 'package:flutter/material.dart';

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
