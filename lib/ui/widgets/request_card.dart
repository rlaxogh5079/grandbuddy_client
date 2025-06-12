import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/profile_detail_page.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final User? senior;
  final VoidCallback? onTap;
  final Widget? child; // << 추가! 하단에 표시할 custom 위젯
  final bool isShowSenior;

  const RequestCard({
    Key? key,
    required this.request,
    this.senior,
    this.onTap,
    this.child,
    this.isShowSenior = true,
  }) : super(key: key);

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목, 상태
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
                    padding: EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(request.status).withOpacity(0.12),
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
                        ? request.description!.substring(0, 36) + '...'
                        : request.description!)
                    : '',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade800),
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
              // senior 정보
              if (senior != null)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.7.h),
                      child: Divider(color: Colors.grey[400], thickness: 1),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailPage(user: senior!),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7BAFD4), // 테두리 강조
                                width: 2.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7BAFD4,
                                  ).withOpacity(0.18),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 15.sp,
                              backgroundColor: const Color(0xFF7BAFD4),
                              backgroundImage:
                                  senior!.profile != null
                                      ? NetworkImage(
                                        "http://3.27.71.121:8000${senior!.profile}",
                                      )
                                      : null,
                              child:
                                  senior!.profile == null
                                      ? FaIcon(
                                        FontAwesomeIcons.solidUser,
                                        size: 15.sp,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        senior!.nickname,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF222222),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: const Color(0xFF7BAFD4),
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.4.h),
                                Text(
                                  senior!.address,
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
                    ),
                  ],
                ),

              if (child != null) ...[SizedBox(height: 2.h), child!],
            ],
          ),
        ),
      ),
    );
  }
}
