import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/add_request.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/ui/widgets/drawer.dart';

Color getStatusColor(String status) {
  switch (status) {
    case "pending":
      return const Color(0xFF7BAFD4);
    case "accepted":
      return Colors.green;
    case "completed":
      return Colors.blue;
    case "canceled":
    case "canceld":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String getStatusText(String status) {
  switch (status) {
    case "pending":
      return "대기 중";
    case "accepted":
      return "매칭됨";
    case "completed":
      return "완료됨";
    case "canceled":
    case "canceld":
      return "취소됨";
    default:
      return "알 수 없음";
  }
}

class GBHomePage extends StatefulWidget {
  const GBHomePage({Key? key}) : super(key: key);

  @override
  State<GBHomePage> createState() => _GBHomePageState();
}

class _GBHomePageState extends State<GBHomePage> {
  String userID = "";
  String role = "";
  String userUuid = "";
  List<Request> requests = [];
  Map<String, User> seniorMap = {};
  String accessToken = '';
  bool isLoadingProfile = true;
  bool isLoadingRequest = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRequestList();
  }

  void _refreshRequestList() {
    _loadRequestList();
  }

  Future<void> _loadProfile() async {
    String token =
        await SecureStorage().storage.read(key: "access_token") ?? '';
    final profile = await getProfile(token);
    setState(() {
      userID = profile.user!.userID;
      role = profile.user!.role;
      userUuid = profile.user!.userUuid;
      accessToken = token;
    });
  }

  Future<void> _loadRequestList() async {
    final response = await getRequestExplore();
    final fetchedRequests = response.requests ?? [];
    final seniorUuids = fetchedRequests.map((e) => e.seniorUuid).toSet();

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
      isLoadingRequest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      key: _scaffoldKey,
      drawer: CustomDrawer(userID: userID),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Center(
          child: Text(
            "Home Page",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.bars),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
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
          isLoadingRequest
              ? const Center(child: CircularProgressIndicator())
              : requests.isEmpty
              ? const Center(child: Text("요청 목록이 없습니다."))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final senior = seniorMap[request.seniorUuid];
                  return GestureDetector(
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestDetailPage(
                                request: request,
                                userRole: role,
                              ),
                        ),
                      );
                      if (result == true) {
                        requests = [];
                        _loadRequestList();
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.2.h,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 2.2.h,
                          horizontal: 3.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    request.title,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF222222),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                      request.status,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    getStatusText(request.status),
                                    style: TextStyle(
                                      color: getStatusColor(request.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            // 설명
                            Text(
                              request.description != null
                                  ? (request.description!.length > 36
                                      ? request.description!.substring(0, 36) +
                                          '...'
                                      : request.description!)
                                  : '',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 1.2.h),

                            // 시간, 날짜, 조회수, 신청수 한줄
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 15.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  request.availableDate ?? '-',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.access_time,
                                  size: 15.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(width: 0.7.w),
                                Text(
                                  "${request.availableStartTime ?? '-'}~${request.availableEndTime ?? '-'}",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.visibility,
                                  size: 15.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(width: 0.7.w),
                                Text(
                                  "${request.views ?? 0}",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.person_add,
                                  size: 15.sp,
                                  color: Colors.orangeAccent,
                                ),
                                SizedBox(width: 0.7.w),
                                Text(
                                  "${request.applications ?? 0}",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.4.h),

                            // senior 정보
                            if (senior != null)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15.sp,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        senior.profile != null
                                            ? NetworkImage(
                                              "http://13.211.30.171:8000${senior.profile}",
                                            )
                                            : null,
                                    child:
                                        senior.profile == null
                                            ? FaIcon(
                                              FontAwesomeIcons.solidUser,
                                              size: 15.sp,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          senior.nickname,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF222222),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 0.4.h),
                                        Text(
                                          senior.address,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
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
      floatingActionButton:
          role == 'senior' && userUuid.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: FloatingActionButton(
                  onPressed: () async {
                    // showAddRequestDialog → 페이지로 이동
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddRequestPage(
                              accessToken: accessToken,
                              onRequestCreated: _refreshRequestList,
                            ),
                      ),
                    );
                    if (result == true) {
                      _refreshRequestList();
                    }
                  },
                  child: Icon(FontAwesomeIcons.plus, color: Colors.white),
                  backgroundColor: const Color(0xFF7BAFD4),
                  shape: const CircleBorder(),
                ),
              )
              : null,
    );
  }
}
