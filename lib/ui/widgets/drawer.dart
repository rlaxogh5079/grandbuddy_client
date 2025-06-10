import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/pages/auth.dart';
import 'package:grandbuddy_client/ui/pages/my_match.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';

class CustomDrawer extends StatelessWidget {
  final String userID;

  const CustomDrawer({Key? key, required this.userID}) : super(key: key);

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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    FontAwesomeIcons.user,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userID,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildDrawerTile(
            icon: FontAwesomeIcons.clipboardList,
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
