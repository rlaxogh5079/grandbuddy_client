import 'package:flutter/material.dart';
import 'package:grandbuddy_client/ui/widgets/readonly_task_list.dart';
import 'package:grandbuddy_client/utils/req/match.dart';
import 'package:grandbuddy_client/utils/req/request.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/res/match.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';

class MatchedUserListPage extends StatefulWidget {
  const MatchedUserListPage({super.key});

  @override
  State<MatchedUserListPage> createState() => _MatchedUserListPageState();
}

class _MatchedUserListPageState extends State<MatchedUserListPage> {
  List<User> matchedUsers = [];
  List<Match> matchedMatches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchedUsers();
  }

  Future<void> _loadMatchedUsers() async {
    final token = await SecureStorage().storage.read(key: "access_token") ?? "";

    final matchRes = await getMyMatch(token);
    final Set<String> added = {};

    final List<User> users = [];
    final List<Match> matches = [];

    for (final m in matchRes.matches ?? []) {
      if (m.status == "declined") continue;

      final reqRes = await getRequestByUuid(m.requestUuid);
      final seniorUuid = reqRes.request?.seniorUuid;

      if (seniorUuid != null && !added.contains(seniorUuid)) {
        final res = await getUserByUuid(seniorUuid);
        if (res.user != null) {
          matches.add(m); // ✅ match 저장
          users.add(res.user!); // ✅ user 저장
          added.add(seniorUuid);
        }
      }
    }

    setState(() {
      matchedUsers = users;
      matchedMatches = matches;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(title: const Text("매칭된 어르신"), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: matchedUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = matchedUsers[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ReadOnlyTaskList(
                                match: matchedMatches[index],
                              ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7BAFD4),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                user.profile != null
                                    ? NetworkImage(
                                      "http://3.27.71.121:8000${user.profile!}",
                                    )
                                    : null,
                            backgroundColor: Colors.grey[200],
                            child:
                                user.profile == null
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                        ),
                        title: Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        subtitle: Text(
                          user.email ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
