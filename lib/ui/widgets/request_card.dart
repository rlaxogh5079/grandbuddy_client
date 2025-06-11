import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final User? senior;
  final VoidCallback? onTap;
  final Widget? child; // << 추가! 하단에 표시할 custom 위젯

  const RequestCard({
    Key? key,
    required this.request,
    this.senior,
    this.onTap,
    this.child,
  }) : super(key: key);

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
              SizedBox(height: 1.4.h),
              // senior 정보
              if (senior != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15.sp,
                      backgroundColor: Colors.grey[300],
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
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            senior!.nickname,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF222222),
                            ),
                            overflow: TextOverflow.ellipsis,
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
              // 하단 커스텀 영역 (예: 신청자 리스트, 버튼 등)
              if (child != null) ...[SizedBox(height: 2.h), child!],
            ],
          ),
        ),
      ),
    );
  }
}
