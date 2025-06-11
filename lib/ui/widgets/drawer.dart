import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/auth.dart';
import 'package:grandbuddy_client/ui/pages/my_match.dart';
import 'package:grandbuddy_client/ui/pages/receive_application_page.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/ui/pages/profile_edit.dart'; // 프로필 편집 페이지(예시)
import 'package:grandbuddy_client/ui/pages/my_requests.dart'; // 내가 등록한 요청(노인)
import 'package:grandbuddy_client/ui/pages/my_applications.dart'; // 내가 신청한 요청(청년)

// ignore: must_be_immutable
class CustomDrawer extends StatefulWidget {
  User? user; // User 객체 전체 전달 (닉네임, 이메일, 프로필 등)
  CustomDrawer({Key? key, this.user}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF7BAFD4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  backgroundImage:
                      widget.user?.profile != null
                          ? NetworkImage(
                            "http://3.27.71.121:8000${widget.user?.profile}",
                          )
                          : null,
                  child:
                      widget.user?.profile == null
                          ? const Icon(
                            FontAwesomeIcons.user,
                            size: 36,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user?.nickname ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user?.email ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user?.role == "senior" ? "노인 회원" : "청년 회원",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.penToSquare,
                    color: Colors.white,
                    size: 18,
                  ),
                  tooltip: "프로필 편집",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditPage(user: widget.user),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (widget.user?.role == "youth") ...[
            _buildDrawerTile(
              icon: FontAwesomeIcons.listCheck,
              label: "내가 신청한 요청",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyApplicationsPage()),
                );
              },
            ),
          ],
          if (widget.user?.role == "senior") ...[
            _buildDrawerTile(
              icon: FontAwesomeIcons.clipboardList,
              label: "내가 등록한 요청",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyRequestsPage()),
                );
              },
            ),
            _buildDrawerTile(
              icon: FontAwesomeIcons.envelopeOpen,
              label: "받은 신청 목록",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReceivedApplicationsPage()),
                );
              },
            ),
          ],
          _buildDrawerTile(
            icon: FontAwesomeIcons.handshake,
            label: "수락한 매칭",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GBMyMatchPage()),
              );
            },
          ),
          Divider(indent: 16, endIndent: 16, color: Colors.grey.shade400),
          _buildDrawerTile(
            icon: FontAwesomeIcons.arrowRightFromBracket,
            label: "로그아웃",
            onTap: () async {
              await SecureStorage().storage.delete(key: "access_token");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GBAuthPage()),
              );
            },
            color: Colors.redAccent,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "GrandBuddy © 2025",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
      hoverColor: Colors.grey.shade200,
      splashColor: Colors.blue.shade50,
    );
  }
}
