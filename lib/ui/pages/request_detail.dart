import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/ui/dialog/dialog.dart';
import 'package:grandbuddy_client/utils/req/request.dart'; // applyToRequest 함수 포함 가정

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
  final Request request;
  final bool hasApplied;
  final String userRole; // "senior" 또는 "youth"

  const RequestDetailPage({
    Key? key,
    required this.request,
    required this.userRole,
    this.hasApplied = false,
  }) : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  User? senior;
  late String baseAddress;
  late String specificAddress;
  bool isUserLoading = true;
  bool isProcessing = false;
  bool applied = false;

  @override
  void initState() {
    super.initState();
    applied = widget.hasApplied;
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final result = await getUserByUuid(widget.request.seniorUuid);
    if (result.statusCode == 200 && mounted) {
      setState(() {
        senior = result.user;
        baseAddress = senior!.address.split("(")[0];
        specificAddress = senior!.address.split("(")[1].replaceAll(")", "");
        isUserLoading = false;
      });
    }
  }

  Future<void> _onApplyPressed() async {
    setState(() => isProcessing = true);
    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final result = await applyToRequest(
      accessToken,
      widget.request.requestUuid,
    );
    setState(() => isProcessing = false);

    if (result.statusCode == 200) {
      if (mounted) {
        setState(() => applied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: const Color(0xFF7BAFD4),
          ),
        );
      }
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
      body:
          isUserLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
                                        "http://13.211.30.171:8000${senior!.profile}",
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
                            // 상태 및 날짜
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                      widget.request.status,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    getStatusText(widget.request.status),
                                    style: TextStyle(
                                      color: getStatusColor(
                                        widget.request.status,
                                      ),
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
                                  widget.request.availableDate ?? '-',
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
                              widget.request.title,
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 1.h),

                            // 설명
                            Text(
                              widget.request.description ?? '',
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
                                  "${widget.request.availableStartTime ?? '-'} ~ ${widget.request.availableEndTime ?? '-'}",
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
                                  "${widget.request.views ?? 0}",
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
                                  "${widget.request.applications ?? 0}",
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

                    // 신청 버튼 or 상태
                    if (widget.userRole == "youth")
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 6.3.h,
                          child: ElevatedButton(
                            onPressed:
                                (!applied && !isProcessing)
                                    ? _onApplyPressed
                                    : null,
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
                                      applied ? "신청 완료" : "신청하기",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
