import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/add_request.dart';
import 'package:grandbuddy_client/ui/pages/chat_list_page.dart';
import 'package:grandbuddy_client/ui/pages/request_detail.dart';
import 'package:grandbuddy_client/ui/widgets/drawer.dart';
import 'package:grandbuddy_client/utils/req/application.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/message.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/res/request.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/ui/widgets/request_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GBHomePage extends StatefulWidget {
  const GBHomePage({Key? key}) : super(key: key);

  @override
  State<GBHomePage> createState() => _GBHomePageState();
}

class _GBHomePageState extends State<GBHomePage> {
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F8F5),
      drawer: CustomDrawer(user: user),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BAFD4),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.bars, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.comments, color: Colors.white),
            onPressed: () async {
              final accessToken =
                  await SecureStorage().storage.read(key: "access_token") ?? "";
              final profile = await getProfile(accessToken);
              final myUser = profile.user!;
              final matchRes = await getMyMatch(accessToken);

              final List<Map<String, String>> chats = [];
              final Set<String> addedUuids = {};
              if (matchRes.matches != null) {
                for (final match in matchRes.matches!) {
                  final reqRes = await getRequestByUuid(match.requestUuid);
                  if (reqRes.request == null) continue;
                  final req = reqRes.request!;

                  final isSenior = myUser.role == "senior";
                  final otherUuid = isSenior ? match.youthUuid : req.seniorUuid;

                  if (otherUuid.isEmpty || addedUuids.contains(otherUuid))
                    continue;

                  final otherUserRes = await getUserByUuid(otherUuid);
                  if (otherUserRes.user == null) continue;
                  final other = otherUserRes.user!;
                  addedUuids.add(otherUuid); // ✅ 여기에 옮김

                  final msgRes = await getLastMessage(match.matchUuid);
                  final lastMsg = msgRes?["message"] ?? "";

                  chats.add({
                    "name": other.nickname,
                    "lastMessage": lastMsg,
                    "matchUuid": match.matchUuid,
                    "senderUuid": myUser.userUuid,
                    "receiverUuid": other.userUuid,
                    "profile": other.profile ?? "",
                  });
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatListPage(chats: chats)),
              );
            },
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
              ),
      floatingActionButton:
          user?.role == 'senior'
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
