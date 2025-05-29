// lib/ui/widgets/custom_drawer.dart

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF7BAFD4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  userID,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.user),
            title: const Text('수락한 매칭'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GBMyMatchPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () async {
              await SecureStorage().storage.delete(key: "access_token");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GBAuthPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
