import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/date.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/message.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatPage extends StatefulWidget {
  final String matchUuid;
  final String senderUuid;
  final String receiverUuid;

  const ChatPage({
    super.key,
    required this.matchUuid,
    required this.senderUuid,
    required this.receiverUuid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ChatSocket _chatSocket;
  User? _otherUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();

    _chatSocket = ChatSocket(
      matchUuid: widget.matchUuid,
      senderUuid: widget.senderUuid,
      receiverUuid: widget.receiverUuid,
    );

    _chatSocket.onMessageReceived = (raw) {
      final data = jsonDecode(raw);
      setState(() => _messages.add(data));
    };

    _loadChatHistory();
    _fetchOtherUser();
  }

  Future<void> _fetchOtherUser() async {
    final res = await getUserByUuid(widget.receiverUuid);
    setState(() {
      _otherUser = res.user;
      _isLoadingUser = false;
    });
  }

  Future<void> _loadChatHistory() async {
    final url = 'http://3.27.71.121:8000/message/list/${widget.matchUuid}';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final messages = List<Map<String, dynamic>>.from(data["messages"] ?? []);
      setState(() => _messages.addAll(messages));
    }
  }

  void _send() {
    final msg = _controller.text.trim();
    if (msg.isNotEmpty) {
      _chatSocket.send(msg);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _chatSocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title:
            _isLoadingUser
                ? const Text("채팅")
                : Row(
                  children: [
                    if (_otherUser?.profile != null)
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(
                          "http://3.27.71.121:8000${_otherUser!.profile!}",
                        ),
                      )
                    else
                      const CircleAvatar(
                        radius: 15,
                        child: Icon(Icons.person, color: Colors.white),
                        backgroundColor: Color(0xFF95BFD8),
                      ),
                    const SizedBox(width: 10),
                    Text(
                      _otherUser?.nickname ?? "상대방",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["sender_uuid"] == widget.senderUuid;
                final text = msg["message"];
                final created = msg["created"] ?? "";
                final timeText = formatKoreanTime(created);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              _otherUser?.profile != null
                                  ? NetworkImage(
                                    "http://3.27.71.121:8000${_otherUser!.profile!}",
                                  )
                                  : null,
                          child:
                              _otherUser?.profile == null
                                  ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 0.7.h),
                          constraints: BoxConstraints(maxWidth: 65.w),
                          decoration: BoxDecoration(
                            color:
                                isMe
                                    ? const Color(0xFF7BAFD4)
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          timeText,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "메시지 입력",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                  color: const Color(0xFF7BAFD4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
