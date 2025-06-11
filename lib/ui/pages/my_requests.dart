import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({Key? key}) : super(key: key);

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<Request> myRequests = [];
  Map<String, User> seniorMap = {}; // 내가 등록한 요청이므로 나 자신의 정보만 들어감
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyRequests();
  }

  Future<void> _fetchMyRequests() async {
    final accessToken = await SecureStorage().storage.read(key: "access_token");
    final response = await getRequestsBySenior(accessToken ?? "");
    final reqs = response.requests ?? [];
    if (reqs.isNotEmpty) {
      final userRes = await getProfile(accessToken ?? "");
      for (var r in reqs) {
        seniorMap[r.seniorUuid] = userRes.user!;
      }
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        myRequests = reqs;
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
          "내가 등록한 요청",
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
              ? const Center(child: Text("등록한 요청이 없습니다."))
              : ListView.builder(
                itemCount: myRequests.length,
                itemBuilder: (context, index) {
                  final request = myRequests[index];
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
                                userRole: "senior",
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
