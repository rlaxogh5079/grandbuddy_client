import 'package:flutter/material.dart';
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
  Map<String, List<Application>> appMap = {}; // 요청uuid → 신청들
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
      final appsRes = await getApplicationsByRequest(
        accessToken,
        req.requestUuid,
      );
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
              ? const Center(child: Text("받은 신청이 없습니다."))
              : ListView.builder(
                itemCount: myRequests.length,
                itemBuilder: (context, idx) {
                  final req = myRequests[idx];
                  final apps = appMap[req.requestUuid] ?? [];
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
                              child: Text(
                                "신청한 청년이 없습니다.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                ),
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
                                        borderRadius: BorderRadius.circular(12),
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
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.green.shade50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final accessToken =
                                                    await SecureStorage()
                                                        .storage
                                                        .read(
                                                          key: "access_token",
                                                        ) ??
                                                    "";
                                                final result =
                                                    await acceptApplication(
                                                      accessToken: accessToken,
                                                      requestUuid:
                                                          req.requestUuid,
                                                      youthUuid: app.youthUuid,
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
                                                  _fetchAllApplications(); // 목록 다시 불러오기(갱신)
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
                                              },
                                              child: const Text(
                                                "수락",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 8),
                                            // 거절 버튼
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red.shade50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () async {
                                                final accessToken =
                                                    await SecureStorage()
                                                        .storage
                                                        .read(
                                                          key: "access_token",
                                                        ) ??
                                                    "";
                                                final result =
                                                    await rejectApplication(
                                                      accessToken: accessToken,
                                                      requestUuid:
                                                          req.requestUuid,
                                                      youthUuid: app.youthUuid,
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
                                                  _fetchAllApplications(); // 목록 갱신
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
                                              },
                                              child: const Text(
                                                "거절",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
