import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/add_request.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/ui/widgets/drawer.dart';

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

class GBHomePage extends StatefulWidget {
  const GBHomePage({Key? key}) : super(key: key);

  @override
  State<GBHomePage> createState() => _GBHomePageState();
}

class _GBHomePageState extends State<GBHomePage> {
  User? user;
  List<Request> requests = [];
  Map<String, User> seniorMap = {};
  String accessToken = '';
  bool isLoadingProfile = true;
  bool isLoadingRequest = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRequestList();
  }

  void _refreshRequestList() {
    _loadRequestList();
  }

  Future<void> _loadProfile() async {
    String token =
        await SecureStorage().storage.read(key: "access_token") ?? '';
    final profile = await getProfile(token);
    if (mounted) {
      setState(() {
        user = profile.user;
        accessToken = token;
      });
    }
  }

  Future<void> _loadRequestList() async {
    final response = await getRequestExplore();
    final fetchedRequests = response.requests ?? [];
    final seniorUuids = fetchedRequests.map((e) => e.seniorUuid).toSet();

    for (String uuid in seniorUuids) {
      try {
        final response = await getUserByUuid(uuid);
        seniorMap[uuid] = response.user!;
      } catch (e) {
        print("유저 정보 불러오기 실패: $e");
      }
    }

    if (mounted) {
      setState(() {
        requests = fetchedRequests;
        isLoadingRequest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      key: _scaffoldKey,
      drawer: CustomDrawer(user: user),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        title: Center(
          child: Text(
            "홈페이지",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.bars),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.comments, color: Colors.white),
            onPressed: () {},
          ),
          SizedBox(width: 5.w),
        ],
      ),
      body:
          isLoadingRequest
              ? const Center(child: CircularProgressIndicator())
              : requests.isEmpty
              ? const Center(child: Text("요청 목록이 없습니다."))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final senior = seniorMap[request.seniorUuid];
                  return RequestCard(
                    request: request,
                    senior: senior,
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RequestDetailPage(
                                requestUuid: request.requestUuid,
                                userRole: user!.role,
                              ),
                        ),
                      );
                      if (result == true) {
                        requests = [];
                        _loadRequestList();
                      }
                    },
                  );
                },
              ),
      floatingActionButton:
          user?.role == 'senior' && user?.userUuid != null
              ? Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: FloatingActionButton(
                  onPressed: () async {
                    // showAddRequestDialog → 페이지로 이동
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddRequestPage(
                              accessToken: accessToken,
                              onRequestCreated: _refreshRequestList,
                            ),
                      ),
                    );
                    if (result == true) {
                      _refreshRequestList();
                    }
                  },
                  child: Icon(FontAwesomeIcons.plus, color: Colors.white),
                  backgroundColor: const Color(0xFF7BAFD4),
                  shape: const CircleBorder(),
                ),
              )
              : null,
    );
  }
}
