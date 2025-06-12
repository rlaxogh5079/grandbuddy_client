import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/utils/req/application.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({Key? key}) : super(key: key);

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  User? user;
  List<Request> requests = [];
  Map<String, User> seniorMap = {};
  bool isLoadingProfile = true;
  bool isLoadingRequest = true;
  String accessToken = '';
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
    accessToken = await SecureStorage().storage.read(key: "access_token") ?? '';
    final profile = await getProfile(accessToken);
    setState(() {
      user = profile.user;
      isLoadingProfile = false;
    });
  }

  Future<void> _loadRequestList() async {
    setState(() => isLoadingRequest = true);

    accessToken = await SecureStorage().storage.read(key: "access_token") ?? "";
    final profile = await getProfile(accessToken);
    user = profile.user;

    final response = await getRequestExplore(); // 전체 요청
    final fetched = response.requests ?? [];

    List<Request> filtered = fetched;

    // ✅ 유저가 청년이면 내가 신청한 요청 제외
    if (user?.role == "youth") {
      final appsRes = await getMyApplications(accessToken); // 내가 신청한 모든 요청
      final myRequestUuids =
          appsRes.requests?.map((a) => a.requestUuid).toSet();

      filtered =
          fetched
              .where((r) => !myRequestUuids!.contains(r.requestUuid))
              .toList();
    }

    // senior 정보 불러오기
    final seniorUuids = filtered.map((r) => r.seniorUuid).toSet();
    seniorMap.clear();
    for (var uuid in seniorUuids) {
      final res = await getUserByUuid(uuid);
      if (res.statusCode == 200 && res.user != null) {
        seniorMap[uuid] = res.user!;
      }
    }

    setState(() {
      requests = filtered;
      isLoadingRequest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingRequest
        ? const Center(child: CircularProgressIndicator())
        : requests.isEmpty
        ? const Center(child: Text("요청 목록이 없습니다."))
        : ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, idx) {
            final req = requests[idx];
            final senior = seniorMap[req.seniorUuid];
            return RequestCard(
              request: req,
              senior: senior,
              onTap: () async {
                // detail에서 true 리턴받으면 새로고침
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => RequestDetailPage(
                          requestUuid: req.requestUuid,
                          userRole: user!.role,
                        ),
                  ),
                );
                if (changed == true) {
                  _loadRequestList();
                }
              },
            );
          },
        );
  }
}
