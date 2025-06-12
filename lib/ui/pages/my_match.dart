import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/profile_detail_page.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GBMyMatchPage extends StatefulWidget {
  @override
  State<GBMyMatchPage> createState() => _GBMyMatchPageState();
}

class _GBMyMatchPageState extends State<GBMyMatchPage> {
  List<Match> matches = [];
  List<Request> requests = [];
  List<User> seniors = [];
  List<User> others = [];
  bool isLoading = true;
  User? myUser;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
      matches = [];
      requests = [];
      seniors = [];
      others = [];
    });

    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final profile = await getProfile(accessToken);
    myUser = profile.user;

    final matchRes = await getMyMatch(accessToken);
    if (matchRes.statusCode == 200 && matchRes.matches != null) {
      matches = matchRes.matches!;
      for (final m in matches) {
        final reqRes = await getRequestByUuid(m.requestUuid);
        if (reqRes.statusCode == 200 && reqRes.request != null) {
          final req = reqRes.request!;
          requests.add(req);

          // 등록자 (항상 요청 등록자 = 어르신)
          final seniorRes = await getUserByUuid(req.seniorUuid);
          seniors.add(seniorRes.user!);

          // ✅ 역할에 따라 매칭 상대 유저 UUID 선택
          final otherUuid =
              myUser?.role == "senior" ? m.youthUuid : req.seniorUuid;

          final otherRes = await getUserByUuid(otherUuid);
          others.add(otherRes.user!);
        }
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  Widget statusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case "completed":
        color = Colors.blue.shade100;
        text = "완료";
        break;
      case "accepted":
        color = Colors.green.shade100;
        text = "매칭";
        break;
      case "canceled":
        color = Colors.red.shade100;
        text = "취소";
        break;
      default:
        color = Colors.grey.shade200;
        text = status;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget buildUserSection(User user, String label, {Color? iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: iconColor ?? Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.6.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileDetailPage(user: user)),
            );
          },
          child: Container(
            padding: EdgeInsets.all(2.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7BAFD4), width: 2.0),
            ),
            child: CircleAvatar(
              radius: 15.sp,
              backgroundColor: Colors.blueGrey[100],
              backgroundImage:
                  user.profile != null
                      ? NetworkImage("http://3.27.71.121:8000${user.profile}")
                      : null,
              child:
                  user.profile == null
                      ? FaIcon(
                        FontAwesomeIcons.user,
                        color: Colors.grey.shade400,
                        size: 20,
                      )
                      : null,
            ),
          ),
        ),
        SizedBox(height: 0.7.h),
        Text(
          user.nickname,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 0.3.h),
        Text(
          user.email,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Text(
          "매칭 목록",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : matches.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.handshake,
                      size: 44,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 14),
                    Text(
                      "매칭 내역이 없습니다.",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, idx) {
                  final m = matches[idx];
                  final req = requests[idx];
                  final other = others[idx];
                  final senior = seniors[idx];

                  return RequestCard(
                    request: req,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RequestDetailPage(
                                requestUuid: req.requestUuid,
                                userRole: myUser?.role ?? "",
                                match: m,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Column(
                        children: [
                          Divider(thickness: 0.7),
                          Row(
                            children: [
                              // 등록자(노인)
                              Expanded(
                                child: buildUserSection(
                                  senior,
                                  "등록자",
                                  iconColor: Colors.blueGrey,
                                ),
                              ),
                              // 구분선
                              Container(
                                width: 1.3,
                                height: 5.6.h,
                                margin: EdgeInsets.symmetric(horizontal: 1.8.w),
                                color: Colors.grey.shade300,
                              ),
                              // 매칭 상대
                              Expanded(
                                child: buildUserSection(
                                  (myUser!.role == "youth") ? myUser! : other,
                                  "매칭 청년",
                                  iconColor: Colors.green[700],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.2.w),
                                child: statusBadge(req.status),
                              ),
                            ],
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
