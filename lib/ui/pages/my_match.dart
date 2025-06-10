import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GBMyMatchPage extends StatefulWidget {
  @override
  State<GBMyMatchPage> createState() => _GBMyMatchPageState();
}

class _GBMyMatchPageState extends State<GBMyMatchPage> {
  List<Match> matches = [];
  List<Request> data = [];
  List<User> users = [];

  void _fetchData() async {
    String accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    MatchesResponse matchResult = await getMyMatch(accessToken);
    if (matchResult.statusCode == 200) {
      matches = matchResult.matches as List<Match>;
      for (int i = 0; i < matchResult.matches!.length; i++) {
        RequestResponse result = await getRequestByUuid(
          matchResult.matches![i].requestUuid,
        );
        if (result.statusCode == 200) {
          data.add(result.request as Request);
          ProfileResponse userResult = await getUserByUuid(
            result.request!.seniorUuid,
          );
          if (userResult.statusCode == 200) {
            users.add(userResult.user as User);
          }
        }
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Center(
          child: Text(
            "My Matches",
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body:
          data.isEmpty
              ? Center(child: Text("요청을 수락한 매칭이 없습니다!"))
              : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      // Card 클릭 시 상세 페이지로 이동
                      bool? shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestDetailPage(
                                request: data[index],
                                isAccepted: true,
                                matchUuid: matches[index].matchUuid,
                              ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        matches = [];
                        users = [];
                        data = [];
                        _fetchData();
                        setState(() {});
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목
                            Text(
                              data[index].title,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 0.5.h),

                            // 설명
                            Text(
                              data[index].description!.length > 40
                                  ? data[index].description!.substring(0, 40) +
                                      '...'
                                  : data[index].description ?? '',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            SizedBox(height: 1.h),

                            // 상태 표시 (색상 원)
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(data[index].status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  "상태: ${data[index].status}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            // 노인 정보 표시
                            if (users.isNotEmpty)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16.sp,
                                    backgroundImage: NetworkImage(
                                      "http://13.211.30.171:8000${users[index].profile}",
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        users[index].nickname,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        users[index].address,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
