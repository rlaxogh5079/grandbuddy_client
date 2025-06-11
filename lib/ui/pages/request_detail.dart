import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/application.dart';
import 'package:grandbuddy_client/utils/res/application.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/ui/dialog/dialog.dart';
import 'package:grandbuddy_client/utils/req/request.dart';

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

class RequestDetailPage extends StatefulWidget {
  final String requestUuid;
  final String userRole; // "senior" 또는 "youth"

  const RequestDetailPage({
    Key? key,
    required this.requestUuid,
    required this.userRole,
  }) : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  late Future<RequestResponse> _futureRequest;
  User? senior;
  late String baseAddress;
  late String specificAddress;
  bool isUserLoading = true;
  bool isProcessing = false;
  String myUserUuid = "";

  // 신청 관련
  bool hasApplied = false; // 내가 이 글에 신청했는지
  List<Application> applications = [];
  Map<String, User> youthMap = {};
  Application? myApplication;
  Application? acceptedApplication;
  User? matchedYouth;

  @override
  void initState() {
    super.initState();
    _futureRequest = getRequestByUuid(widget.requestUuid);
    _loadMyProfileAndCheck();
  }

  Future<void> _loadMyProfileAndCheck() async {
    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final profile = await getProfile(accessToken);
    myUserUuid = profile.user?.userUuid ?? "";
    await _fetchApplicationsAndStatus();
    if (mounted) setState(() {});
  }

  Future<void> _fetchApplicationsAndStatus() async {
    String? token = await SecureStorage().storage.read(key: "access_token");
    final res = await getApplicationsByRequest(token ?? "", widget.requestUuid);
    applications = res.applications ?? [];
    print("applications: ${applications.map((e) => e.toJson()).toList()}");

    hasApplied = false;
    myApplication = null;
    acceptedApplication = null;
    matchedYouth = null;

    for (final app in applications) {
      print(app.toString());
      if (app.youthUuid == myUserUuid) {
        print("detected");
        myApplication = app;
        if (app.status == "pending" || app.status == "accepted") {
          hasApplied = true;
        }
      }
      if (app.status == "accepted") {
        acceptedApplication = app;
        final userRes = await getUserByUuid(app.youthUuid);
        if (userRes.statusCode == 200) matchedYouth = userRes.user;
      }
    }

    if (!mounted) return;
  }

  Future<void> _fetchUser(String seniorUuid) async {
    final result = await getUserByUuid(seniorUuid);
    if (result.statusCode == 200 && mounted) {
      setState(() {
        senior = result.user;
        baseAddress = senior!.address.split("(")[0];
        specificAddress = senior!.address.split("(")[1].replaceAll(")", "");
        isUserLoading = false;
      });
    }
  }

  // 노인일 때 신청자 목록+매칭자
  Future<void> _fetchApplications(String requestUuid) async {
    await _fetchApplicationsAndStatus();
    // 유스 정보 세팅
    final map = <String, User>{};
    for (final app in applications) {
      final userRes = await getUserByUuid(app.youthUuid);
      if (userRes.statusCode == 200) {
        map[app.youthUuid] = userRes.user!;
      }
    }
    if (!mounted) return;
    setState(() {
      youthMap = map;
    });
  }

  // 신청하기
  Future<void> _onApplyPressed(String requestUuid) async {
    setState(() => isProcessing = true);
    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final result = await applyToRequest(accessToken, requestUuid);
    setState(() => isProcessing = false);

    if (result.statusCode == 200) {
      await _loadMyProfileAndCheck();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: const Color(0xFF7BAFD4),
        ),
      );
    } else {
      createSmoothDialog(
        context,
        "오류",
        Text(result.message),
        TextButton(
          child: const Text("닫기", style: TextStyle(color: Color(0xFF7BAFD4))),
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  // 신청 취소하기
  Future<void> _onCancelApplicationPressed(String requestUuid) async {
    setState(() => isProcessing = true);
    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final result = await cancelApplication(accessToken, requestUuid);
    setState(() => isProcessing = false);

    if (result.statusCode == 200) {
      await _loadMyProfileAndCheck();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("신청이 취소되었습니다."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      createSmoothDialog(
        context,
        "오류",
        Text(result.message ?? "취소 실패"),
        TextButton(
          child: const Text("닫기", style: TextStyle(color: Color(0xFF7BAFD4))),
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  // 내 게시글인지
  bool get isMyRequest =>
      senior != null && myUserUuid != "" && senior!.userUuid == myUserUuid;

  // accepted 상태인지(내가 매칭된 경우)
  bool get isMatchedMine =>
      acceptedApplication != null &&
      acceptedApplication!.youthUuid == myUserUuid;

  // 남이 매칭한 글인지
  bool get isMatchedByOther =>
      acceptedApplication != null &&
      acceptedApplication!.youthUuid != myUserUuid;

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7BAFD4);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          "요청 상세",
          style: TextStyle(
            fontSize: 17.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: FutureBuilder<RequestResponse>(
        future: _futureRequest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.request == null) {
            return const Center(child: Text("요청 정보를 불러올 수 없습니다."));
          }
          final request = snapshot.data!.request!;

          if (senior == null) _fetchUser(request.seniorUuid);
          if (widget.userRole == "senior" && applications.isEmpty)
            _fetchApplications(request.requestUuid);

          if (senior == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 카드
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.h,
                      horizontal: 3.w,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.sp,
                          backgroundColor: themeColor.withOpacity(0.18),
                          backgroundImage:
                              senior?.profile != null
                                  ? NetworkImage(
                                    "http://3.27.71.121:8000${senior!.profile}",
                                  )
                                  : null,
                          child:
                              senior?.profile == null
                                  ? FaIcon(
                                    FontAwesomeIcons.solidUser,
                                    color: themeColor,
                                    size: 30.sp,
                                  )
                                  : null,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                senior?.nickname ?? "",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                              SizedBox(height: 0.7.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: themeColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Flexible(
                                    child: Text(
                                      baseAddress,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                specificAddress,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),

                // 요청 정보 카드
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          child: Text("asd"),
                          onPressed: () {
                            print(
                              'isMyRequest: $isMyRequest, hasApplied: $hasApplied, isMatchedMine: $isMatchedMine, isMatchedByOther: $isMatchedByOther',
                            );
                          },
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
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
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today,
                              color: themeColor,
                              size: 15.sp,
                            ),
                            SizedBox(width: 0.5.w),
                            Text(
                              request.availableDate ?? '-',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // 제목
                        Text(
                          request.title,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // 설명
                        Text(
                          request.description ?? '',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 1.8.h),

                        // 시간/조회수/신청수
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: themeColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${request.availableStartTime ?? '-'} ~ ${request.availableEndTime ?? '-'}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.visibility,
                              color: Colors.grey.shade400,
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${request.views ?? 0}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.person_add,
                              color: Colors.orangeAccent,
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "${request.applications ?? 0}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // ----
                // 1. 신청/취소/매칭 상태 버튼 (청년만)
                if (widget.userRole == "youth")
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 6.3.h,
                      child:
                          (isMatchedByOther
                              ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  "다른 사람과 이미 매칭된 요청입니다.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : (hasApplied
                                  ? isMatchedMine
                                      ? ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "매칭된 상태에서는 취소 불가",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      : ElevatedButton(
                                        onPressed:
                                            isProcessing
                                                ? null
                                                : () =>
                                                    _onCancelApplicationPressed(
                                                      request.requestUuid,
                                                    ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child:
                                            isProcessing
                                                ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                                : Text(
                                                  "신청 취소",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      )
                                  : ElevatedButton(
                                    onPressed:
                                        isProcessing
                                            ? null
                                            : () => _onApplyPressed(
                                              request.requestUuid,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColor,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child:
                                        isProcessing
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(
                                              "신청하기",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ))),
                    ),
                  ),
                // 2. 노인일 때: 신청 목록 표시
                if (widget.userRole == "senior" && applications.isNotEmpty)
                  isMyRequest
                      ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          "내가 등록한 요청입니다.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: ListView(
                            children: [
                              // 매칭된 신청자(accepted)가 있다면 최상단에 강조 표시
                              if (acceptedApplication != null &&
                                  matchedYouth != null)
                                Card(
                                  color: Colors.green[50],
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.only(bottom: 1.5.h),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          matchedYouth!.profile != null
                                              ? NetworkImage(
                                                "http://3.27.71.121:8000${matchedYouth!.profile}",
                                              )
                                              : null,
                                      child:
                                          matchedYouth!.profile == null
                                              ? const Icon(Icons.person)
                                              : null,
                                    ),
                                    title: Text(
                                      matchedYouth!.nickname,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    subtitle: Text(
                                      "매칭된 청년 • ${acceptedApplication!.created}",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ),
                              // 나머지 신청자(accepted는 위에서 보여주므로 제외)
                              ...applications
                                  .where((app) => app.status != "accepted")
                                  .map((app) {
                                    final youth = youthMap[app.youthUuid];
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 0.7.h,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              youth?.profile != null
                                                  ? NetworkImage(
                                                    "http://3.27.71.121:8000${youth!.profile}",
                                                  )
                                                  : null,
                                          child:
                                              youth?.profile == null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                        ),
                                        title: Text(youth?.nickname ?? "청년"),
                                        subtitle: Text(
                                          "${app.status} • ${app.created}",
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
