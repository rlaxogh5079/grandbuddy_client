import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({Key? key}) : super(key: key);

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<Request> appliedRequests = [];
  Map<String, User> seniorMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyApplications();
  }

  Future<void> _fetchMyApplications() async {
    final accessToken = await SecureStorage().storage.read(key: "access_token");
    final response = await getRequestsByApplicant(accessToken ?? "");
    List<Request> reqs = response.requests ?? [];

    // 요청 상태에 따라 정렬 (매칭됨 > 대기중 > 거절됨 순)
    reqs.sort((a, b) {
      int statusA = _getRequestStatusPriority(a.status);
      int statusB = _getRequestStatusPriority(b.status);
      return statusA.compareTo(statusB);
    });

    final seniorUuids = reqs.map((e) => e.seniorUuid).toSet();

    for (String uuid in seniorUuids) {
      try {
        final seniorRes = await getUserByUuid(uuid);
        seniorMap[uuid] = seniorRes.user!;
      } catch (e) {}
    }

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        appliedRequests = reqs;
        isLoading = false;
      });
    });
  }

  // 요청 상태를 우선순위에 맞게 반환하는 함수
  int _getRequestStatusPriority(String status) {
    switch (status) {
      case "accepted":
        return 1; // 매칭됨
      case "pending":
        return 2; // 대기중
      case "rejected":
        return 3; // 거절됨
      default:
        return 4; // 기타 상태는 마지막에
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Text(
          "내가 신청한 요청",
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
              : appliedRequests.isEmpty
              ? const Center(child: Text("신청한 요청이 없습니다."))
              : ListView.builder(
                itemCount: appliedRequests.length,
                itemBuilder: (context, index) {
                  final request = appliedRequests[index];
                  final senior = seniorMap[request.seniorUuid];
                  return RequestCard(
                    request: request,
                    senior: senior,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RequestDetailPage(
                                requestUuid: request.requestUuid,
                                userRole: "youth",
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
