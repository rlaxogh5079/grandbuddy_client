import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/pages/request_list_page.dart';
import 'package:grandbuddy_client/ui/pages/task_page.dart';
import 'package:grandbuddy_client/ui/pages/chat_list_page.dart';
import 'package:grandbuddy_client/ui/widgets/drawer.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/message.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GBHomePage extends StatefulWidget {
  const GBHomePage({Key? key}) : super(key: key);

  @override
  State<GBHomePage> createState() => _GBHomePageState();
}

class _GBHomePageState extends State<GBHomePage> {
  int _currentIndex = 0;
  User? user;
  bool isLoading = true;
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final token = await SecureStorage().storage.read(key: 'access_token') ?? '';
    final res = await getProfile(token);
    setState(() {
      user = res.user;
      isLoading = false;
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
        title: const Text("동네 손주", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.bars, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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

                  if (otherUuid.isEmpty || addedUuids.contains(otherUuid)) {
                    continue;
                  }

                  final otherUserRes = await getUserByUuid(otherUuid);
                  if (otherUserRes.user == null) continue;
                  final other = otherUserRes.user!;
                  addedUuids.add(otherUuid);

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
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: [RequestListPage(), TasksPage(user: user!)],
              ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF7BAFD4),
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '요청'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: '할 일'),
        ],
      ),
    );
  }
}
