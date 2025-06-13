import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserRequestListPage extends StatelessWidget {
  final List<Request> requests;
  final User user;
  const UserRequestListPage({
    super.key,
    required this.requests,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Text(
          "${user.nickname}님의 등록 요청글",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body:
          requests.isEmpty
              ? Center(
                child: Text(
                  "등록된 요청글이 없습니다.",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, idx) {
                  final r = requests[idx];
                  return Padding(
                    padding: EdgeInsets.only(
                      top: idx == 0 ? 2.h : 0,
                      bottom: 2.h,
                    ),
                    child: RequestCard(
                      request: r,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RequestDetailPage(
                                  requestUuid: r.requestUuid,
                                  userRole: user.role,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
