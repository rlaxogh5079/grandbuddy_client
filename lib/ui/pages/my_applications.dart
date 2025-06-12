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
    final reqs = response.requests ?? [];
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
