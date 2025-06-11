import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GBMyMatchPage extends StatefulWidget {
  @override
  State<GBMyMatchPage> createState() => _GBMyMatchPageState();
}

class _GBMyMatchPageState extends State<GBMyMatchPage> {
  List<Match> matches = [];
  List<Request> data = [];
  List<User> users = [];
  List<User> others = [];
  bool isLoadingMatch = true;
  String? myUuid;
  String? myRole;

  void _fetchData() async {
    String accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final profile = await getProfile(accessToken);
    myUuid = profile.user!.userUuid;
    myRole = profile.user!.role;

    MatchesResponse matchResult = await getMyMatch(accessToken);
    if (matchResult.statusCode == 200) {
      matches = matchResult.matches as List<Match>;
      for (int i = 0; i < matchResult.matches!.length; i++) {
        RequestResponse result = await getRequestByUuid(
          matchResult.matches![i].requestUuid,
        );
        if (result.statusCode == 200) {
          data.add(result.request as Request);

          // 노인 정보
          ProfileResponse userResult = await getUserByUuid(
            result.request!.seniorUuid,
          );
          if (userResult.statusCode == 200) {
            users.add(userResult.user as User);
          }

          // 상대방 정보 (내가 노인이면 청년, 내가 청년이면 노인)
          if (myRole == "senior") {
            // 상대는 매칭된 youth
            ProfileResponse otherResult = await getUserByUuid(
              matchResult.matches![i].youthUuid,
            );
            if (otherResult.statusCode == 200) {
              others.add(otherResult.user as User);
            }
          } else {
            // 상대는 senior(이미 users에 들어감)
            others.add(userResult.user as User);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoadingMatch = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
          isLoadingMatch
              ? Center(child: CircularProgressIndicator())
              : data.isEmpty
              ? Center(child: Text("요청을 수락한 매칭이 없습니다!"))
              : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final other = others.isNotEmpty ? others[index] : null;
                  return RequestCard(
                    request: data[index],
                    senior: users.isNotEmpty ? users[index] : null,
                    onTap: () async {
                      bool? shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestDetailPage(
                                requestUuid: data[index].requestUuid,
                                userRole: users[index].role,
                              ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        matches = [];
                        users = [];
                        data = [];
                        others = [];
                        _fetchData();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {});
                        });
                      }
                    },
                    // 여기 child에 상대방 정보
                    child:
                        other != null
                            ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 19.sp,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      other.profile != null
                                          ? NetworkImage(
                                            "http://3.27.71.121:8000${other.profile}",
                                          )
                                          : null,
                                  child:
                                      other.profile == null
                                          ? const FaIcon(
                                            FontAwesomeIcons.solidUser,
                                          )
                                          : null,
                                ),
                                SizedBox(width: 3.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      other.nickname,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      other.phone ?? "-",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      other.email ?? "-",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : null,
                  );
                },
              ),
    );
  }
}
