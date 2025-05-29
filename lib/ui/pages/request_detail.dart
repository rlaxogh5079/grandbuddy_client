import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/general.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/ui/dialog/dialog.dart';

Color getStatusColor(String status) {
  switch (status) {
    case "pending":
      return Colors.grey;
    case "accepted":
      return Colors.green;
    case "completed":
      return Colors.blue;
    case "canceld":
      return Colors.red;
    default:
      return Colors.white;
  }
}

class RequestDetailPage extends StatefulWidget {
  final Request request;
  final bool isAccepted;
  final String matchUuid;

  const RequestDetailPage({
    Key? key,
    required this.request,
    this.isAccepted = false,
    this.matchUuid = '',
  }) : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool? buttonAble = null;
  late User? senior = null;
  late String baseAddress;
  late String specificAddress;

  Future<void> _fetchButtonAble() async {
    String accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? '';
    MatchResponse response = await searchMatch(
      accessToken,
      widget.request.requestUuid,
    );

    setState(() {
      if (response.statusCode == 200) {
        buttonAble = false;
      } else {
        buttonAble = true;
      }
    });
  }

  Future<void> _fetchUser() async {
    ProfileResponse result = await getUserByUuid(widget.request.seniorUuid);
    if (result.statusCode == 200) {
      setState(() {
        senior = result.user;
        baseAddress = senior!.address.split("(")[0];
        specificAddress = senior!.address.split("(")[1].replaceAll(")", "");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchButtonAble();
    _fetchUser();
  }

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
        leading: BackButton(color: Colors.white),
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
                    radius: 24.sp,
                    backgroundImage: NetworkImage(
                      "http://192.168.219.102:8000${senior!.profile}",
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senior!.nickname,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        baseAddress,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        specificAddress,
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

            Row(
              children: [
                SizedBox(width: 10.w),
                Container(
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: getStatusColor(widget.request.status),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  "상태: ${widget.request.status}",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            Divider(thickness: 1, color: Colors.grey.shade300),
            SizedBox(height: 2.h),

            Text(
              widget.request.title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),

            SizedBox(
              height: 40.h,
              child: SingleChildScrollView(
                child: Text(
                  widget.request.description ?? '',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 3.h),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    widget.isAccepted == false
                        ? SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed:
                                buttonAble != true
                                    ? null
                                    : () async {
                                      final accessToken =
                                          await SecureStorage().storage.read(
                                            key: "access_token",
                                          ) ??
                                          "";

                                      MatchCreateResponse result =
                                          await createMatch(
                                            accessToken,
                                            widget.request.requestUuid,
                                          );
                                      String resultTitle = "";
                                      String resultContent = "";
                                      bool success = false;
                                      switch (result.statusCode) {
                                        case 201:
                                          success = true;
                                          break;
                                        case 422:
                                          resultTitle = "데이터 전송 오류";
                                          resultContent = result.message;
                                          break;
                                        case 500:
                                          resultTitle = "서버 내부 오류";
                                          resultContent = result.message;
                                          break;
                                      }
                                      if (success) {
                                        setState(() {
                                          buttonAble = false;
                                        });

                                        Navigator.pop(context, true);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("요청을 수락하였습니다"),
                                            backgroundColor: const Color(
                                              0xFF7BAFD4,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        createSmoothDialog(
                                          context,
                                          resultTitle,
                                          Text(resultContent),
                                          TextButton(
                                            child: Text(
                                              "닫기",
                                              style: TextStyle(
                                                color: const Color(0xFF5B8FB4),
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              backgroundColor: const Color(0xFF7BAFD4),
                            ),
                            child:
                                buttonAble == null
                                    ? CircularProgressIndicator()
                                    : Text(
                                      "요청 수락",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                String accessToken =
                                    await SecureStorage().storage.read(
                                      key: "access_token",
                                    ) ??
                                    "";
                                GeneralResponse result = await completeMatch(
                                  accessToken,
                                  widget.matchUuid,
                                );

                                if (result.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("요청을 성공적으로 완료하였습니다!"),
                                      backgroundColor: const Color(0xFF7BAFD4),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.green,
                              ),
                              child: Text(
                                "요청 완료",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String accessToken =
                                    await SecureStorage().storage.read(
                                      key: "access_token",
                                    ) ??
                                    "";
                                GeneralResponse result = await deleteMatch(
                                  accessToken,
                                  widget.matchUuid,
                                );

                                if (result.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("성공적으로 취소하였습니다!"),
                                      backgroundColor: const Color(0xFF7BAFD4),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                "수락 취소",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
