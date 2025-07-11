import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/pages/user_match.dart';
import 'package:grandbuddy_client/ui/pages/user_request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class ProfileDetailPage extends StatefulWidget {
  final User user;
  const ProfileDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late Future<List<Match>> matchesFuture;
  late Future<List<Request>> requestsFuture;

  @override
  void initState() {
    super.initState();
    // (1) 매칭 불러오기 (본인이 청년/노인 모두 포함)
    matchesFuture = fetchUserAllMatches(widget.user.userUuid);
    // (2) 등록 요청글 불러오기 (노인)
    requestsFuture = fetchUserRequests(widget.user.userUuid);
  }

  String getRoleKor(String? role) {
    if (role == "senior") return "노인";
    if (role == "youth") return "청년";
    return role ?? "미상";
  }

  String? getBaseAddress(String? address) {
    if (address == null) return null;
    if (!address.contains('(')) return address;
    return address.split('(')[0].trim();
  }

  String? getDetailAddress(String? address) {
    if (address == null) return null;
    if (!address.contains('(')) return null;
    return address.split('(').length > 1
        ? address.split('(')[1].replaceAll(')', '').trim()
        : null;
  }

  String? formatDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      return DateFormat('yyyy년 M월 d일').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Future<List<Request>> fetchUserRequests(String userUuid) async {
    final res = await getRequestByUserUuid(userUuid);
    return res.requests ?? [];
  }

  Future<List<Match>> fetchUserAllMatches(String userUuid) async {
    final res = await getMatchByUserUuid(userUuid); // 직접 구현 필요
    return res.matches ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7BAFD4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          '${widget.user.nickname}님의 프로필',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF9F8F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 32.sp,
                          backgroundColor: themeColor.withOpacity(0.08),
                          backgroundImage:
                              widget.user.profile != null
                                  ? NetworkImage(
                                    "http://3.27.71.121:8000${widget.user.profile}",
                                  )
                                  : null,
                          child:
                              widget.user.profile == null
                                  ? Icon(
                                    Icons.person,
                                    size: 44.sp,
                                    color: themeColor,
                                  )
                                  : null,
                        ),
                      ),
                      SizedBox(height: 1.7.h),
                      Center(
                        child: Text(
                          widget.user.nickname,
                          style: TextStyle(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Center(
                        child: Text(
                          getRoleKor(widget.user.role),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Divider(),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.email, color: themeColor),
                        title: Text(
                          widget.user.email,
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.location_on, color: themeColor),
                        title: Text(
                          getBaseAddress(widget.user.address) ?? "-",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                        subtitle:
                            getDetailAddress(widget.user.address) != null
                                ? Text(
                                  getDetailAddress(widget.user.address)!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                  ),
                                )
                                : null,
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.cake, color: themeColor),
                        title: Text(
                          "생일: ${formatDate(widget.user.birthDay)}",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.calendar_today, color: themeColor),
                        title: Text(
                          "가입일: ${formatDate(widget.user.created)}",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // 매칭/게시글 정보 카드
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 매칭 횟수 카드
                  Container(
                    width: 40.w,
                    child: FutureBuilder<List<Match>>(
                      future: matchesFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return GestureDetector(
                          onTap:
                              snapshot.hasData
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => UserMatchListPage(
                                              matches: snapshot.data!,
                                              user: widget.user,
                                            ),
                                      ),
                                    );
                                  }
                                  : null,
                          child: Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.2.h),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    size: 26.sp,
                                    color: themeColor,
                                  ),
                                  SizedBox(height: 0.7.h),
                                  Text(
                                    '매칭 횟수',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // 게시글 수 카드
                  if (widget.user.role == "senior")
                    Container(
                      width: 40.w,
                      child: FutureBuilder<List<Request>>(
                        future: requestsFuture,
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return GestureDetector(
                            onTap:
                                snapshot.hasData
                                    ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => UserRequestListPage(
                                                requests: snapshot.data!,
                                                user: widget.user,
                                              ),
                                        ),
                                      );
                                    }
                                    : null,
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.2.h),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.list_alt_rounded,
                                      size: 26.sp,
                                      color: themeColor,
                                    ),
                                    SizedBox(height: 0.7.h),
                                    Text(
                                      '등록 게시글',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      '$count',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- API 통신부 (예시, 실제 서버/파라미터에 맞게 수정) ----
