import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/pages/chat_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatListPage extends StatelessWidget {
  final List<Map<String, String>> chats;

  const ChatListPage({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          "채팅 목록",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body:
          chats.isEmpty
              ? Center(
                child: Text(
                  "채팅 내역이 없습니다.",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                itemCount: chats.length,
                separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final name = chat["name"] ?? "";
                  final lastMessage = chat["lastMessage"] ?? "";
                  final profile = chat["profile"];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatPage(
                                matchUuid: chat["matchUuid"]!,
                                senderUuid: chat["senderUuid"]!,
                                receiverUuid: chat["receiverUuid"]!,
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h, // ✅ 더 넓은 수직 패딩
                        horizontal: 5.w, // ✅ 더 넓은 좌우 패딩
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.2), // 테두리 두께
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7BAFD4), // 테두리 색
                                width: 2.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  profile != null && profile.isNotEmpty
                                      ? NetworkImage(
                                        "http://3.27.71.121:8000$profile",
                                      )
                                      : null,
                              backgroundColor: const Color(0xFF7BAFD4),
                              child:
                                  profile == null || profile.isEmpty
                                      ? Text(
                                        name.isNotEmpty ? name[0] : "?",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.sp, // ✅ 이름 크게
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                                SizedBox(height: 0.6.h),
                                Text(
                                  lastMessage,
                                  style: TextStyle(
                                    fontSize: 15.sp, // ✅ 메시지도 키움
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            FontAwesomeIcons.chevronRight,
                            size: 18, // ✅ 더 큰 화살표
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
