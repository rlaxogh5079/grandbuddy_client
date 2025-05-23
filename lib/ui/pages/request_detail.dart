import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/model/response.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

class RequestDetailPage extends StatelessWidget {
  final Request request;
  final User? senior;

  const RequestDetailPage({Key? key, required this.request, this.senior})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Text(
          "요청 상세",
          style: TextStyle(fontSize: 17.sp, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 노인 정보 표시 (senior)
            if (senior != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.sp,
                    backgroundImage: NetworkImage(senior!.profile),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senior!.nickname,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        senior!.address,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 2.h),

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
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Divider로 구역을 나누기
            Divider(thickness: 1, color: Colors.grey.shade300),
            SizedBox(height: 2.h),

            // 제목
            Text(
              request.title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),

            // 설명
            Text(request.description ?? '', style: TextStyle(fontSize: 16.sp)),

            SizedBox(height: 3.h), // 여백 추가
            // 요청 수락 버튼
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 100, // Width 100으로 설정
                child: ElevatedButton(
                  onPressed: () {
                    // 수락 버튼 클릭 시 동작 정의 (예: 요청 수락)
                    print("요청 수락");
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.h), // 버튼의 높이 조정
                  ),
                  child: Text(
                    "요청 수락",
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
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
