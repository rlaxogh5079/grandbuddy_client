import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/model/response.dart';
import 'package:grandbuddy_client/utils/requester.dart';
import 'package:grandbuddy_client/utils/extensions/role_extension.dart';

// 상태별 색상 매핑 함수
Color getStatusColor(String status) {
  switch (status) {
    case "pending":
      return Colors.orange;
    case "accepted":
      return Colors.blue;
    case "completed":
      return Colors.green;
    case "canceld":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// 홈 페이지 위젯
class GBHomePage extends StatefulWidget {
  const GBHomePage({Key? key}) : super(key: key);

  @override
  State<GBHomePage> createState() => _GBHomePageState();
}

class _GBHomePageState extends State<GBHomePage> {
  String userID = "";
  String role = "";
  List<Request> requests = [];
  Map<String, User> seniorMap = {}; // seniorUuid → User 매핑

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRequestList();
  }

  Future<void> _loadProfile() async {
    final token = await SecureStorage().storage.read(key: "access_token") ?? "";
    final profile = await getProfile(token);
    setState(() {
      userID = profile.user!.userID;
      role = profile.user!.role;
    });
  }

  Future<void> _loadRequestList() async {
    final response = await getRequestExplore();
    final fetchedRequests = response.requests ?? [];

    // 중복 제거된 seniorUuid만 추출
    final seniorUuids = fetchedRequests.map((e) => e.seniorUuid).toSet();

    // 각 UUID별로 User 정보 요청
    for (String uuid in seniorUuids) {
      try {
        final response = await getUserByUuid(uuid);
        seniorMap[uuid] = response.user!;
      } catch (e) {
        print("유저 정보 불러오기 실패: $e");
      }
    }

    setState(() {
      requests = fetchedRequests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Center(
          child: Text(
            "Home Page",
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.bars),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.comments, color: Colors.white),
            onPressed: () {},
          ),
          SizedBox(width: 5.w),
        ],
      ),
      body:
          requests.isEmpty
              ? Center(child: Text("요청 목록이 없습니다."))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final senior = seniorMap[request.seniorUuid];

                  return Card(
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
                            request.title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),

                          // 설명
                          Text(
                            request.description ?? '',
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
                                  color: getStatusColor(request.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "상태: ${request.status}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),

                          // 노인 정보 표시
                          if (senior != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16.sp,
                                  backgroundImage: NetworkImage(senior.profile),
                                ),
                                SizedBox(width: 3.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      senior.nickname,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      senior.address,
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
                  );
                },
              ),
    );
  }
}
