import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/profile_detail_page.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/req/application.dart';
import 'package:grandbuddy_client/utils/res/application.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReceivedApplicationsPage extends StatefulWidget {
  const ReceivedApplicationsPage({Key? key}) : super(key: key);

  @override
  State<ReceivedApplicationsPage> createState() =>
      _ReceivedApplicationsPageState();
}

class _ReceivedApplicationsPageState extends State<ReceivedApplicationsPage> {
  List<Request> myRequests = [];
  Map<String, List<Application>> appMap = {};
  Map<String, User> youthMap = {};
  User? myUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllApplications();
  }

  Future<void> _fetchAllApplications() async {
    setState(() {
      isLoading = true;
      myRequests = [];
      appMap = {};
      youthMap = {};
    });

    final accessToken =
        await SecureStorage().storage.read(key: "access_token") ?? "";
    final myRes = await getProfile(accessToken);
    myUser = myRes.user;
    final myReqRes = await getRequestsBySenior(accessToken);
    final requests = myReqRes.requests ?? [];
    for (final req in requests) {
      final appsRes = await getApplicationsByRequest(req.requestUuid);
      appMap[req.requestUuid] = appsRes.applications;
      for (final app in appsRes.applications) {
        if (!youthMap.containsKey(app.youthUuid)) {
          final youthRes = await getUserByUuid(app.youthUuid);
          youthMap[app.youthUuid] = youthRes.user!;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      myRequests = requests;
      isLoading = false;
    });
  }

  // 상태 뱃지 위젯
  Widget statusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case "accepted":
        color = Colors.green.shade100;
        text = "매칭됨";
        break;
      case "pending":
        color = Colors.blue.shade100;
        text = "대기중";
        break;
      case "rejected":
        color = Colors.red.shade100;
        text = "거절됨";
        break;
      default:
        color = Colors.grey.shade200;
        text = status;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Text(
          "받은 신청 목록",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : myRequests.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.folderOpen,
                      size: 42,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "받은 신청이 없습니다.",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: myRequests.length,
                itemBuilder: (context, idx) {
                  final req = myRequests[idx];
                  List<Application> apps = appMap[req.requestUuid] ?? [];

                  // ✅ match 성사 상태면 accepted된 사용자만 보여줌
                  if (apps.any((a) => a.status == "accepted")) {
                    apps = apps.where((a) => a.status == "accepted").toList();
                  }

                  return RequestCard(
                    request: req,
                    senior: myUser,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RequestDetailPage(
                                requestUuid: req.requestUuid,
                                userRole: "senior",
                              ),
                        ),
                      );
                    },
                    child:
                        apps.isEmpty
                            ? Padding(
                              padding: EdgeInsets.all(2.w),
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.userFriends,
                                    size: 20,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    "신청한 청년이 없습니다.",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  apps.map((app) {
                                    final youth = youthMap[app.youthUuid];
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 0.7.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 1.5.h,
                                          horizontal: 3.w,
                                        ),
                                        leading: GestureDetector(
                                          onTap: () {
                                            if (youth != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) => ProfileDetailPage(
                                                        user: youth,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(1.2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF7BAFD4),
                                                width: 2.0,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 17.sp,
                                              backgroundImage:
                                                  youth?.profile != null
                                                      ? NetworkImage(
                                                        "http://3.27.71.121:8000${youth!.profile}",
                                                      )
                                                      : null,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              child:
                                                  youth?.profile == null
                                                      ? FaIcon(
                                                        FontAwesomeIcons
                                                            .solidUser,
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                        size: 20,
                                                      )
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              youth?.nickname ?? "청년",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            statusBadge(app.status),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3.0,
                                          ),
                                          child: Text(
                                            "신청일: ${app.created}",
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        trailing: Wrap(
                                          spacing: 0,
                                          children: [
                                            Tooltip(
                                              message: "신청 수락",
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                                onPressed:
                                                    app.status == "pending"
                                                        ? () async {
                                                          final accessToken =
                                                              await SecureStorage()
                                                                  .storage
                                                                  .read(
                                                                    key:
                                                                        "access_token",
                                                                  ) ??
                                                              "";
                                                          final result =
                                                              await acceptApplication(
                                                                accessToken:
                                                                    accessToken,
                                                                requestUuid:
                                                                    req.requestUuid,
                                                                youthUuid:
                                                                    app.youthUuid,
                                                              );
                                                          if (result) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "신청을 수락했습니다.",
                                                                ),
                                                              ),
                                                            );
                                                            _fetchAllApplications();
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "수락에 실패했습니다.",
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                        : null,
                                              ),
                                            ),
                                            Tooltip(
                                              message: "신청 거절",
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    app.status == "pending"
                                                        ? () async {
                                                          final accessToken =
                                                              await SecureStorage()
                                                                  .storage
                                                                  .read(
                                                                    key:
                                                                        "access_token",
                                                                  ) ??
                                                              "";
                                                          final result =
                                                              await rejectApplication(
                                                                accessToken:
                                                                    accessToken,
                                                                requestUuid:
                                                                    req.requestUuid,
                                                                youthUuid:
                                                                    app.youthUuid,
                                                              );
                                                          if (result) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "신청을 거절했습니다.",
                                                                ),
                                                              ),
                                                            );
                                                            _fetchAllApplications();
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "거절에 실패했습니다.",
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                        : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                  );
                },
              ),
    );
  }
}
