import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/ui/pages/auth.dart';
import 'package:grandbuddy_client/ui/pages/home.dart';
import 'package:grandbuddy_client/ui/pages/match_create.dart';

void main() {
  runApp(const GBApp());
}

class GBApp extends StatelessWidget {
  const GBApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Grandbuddy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 118, 143, 248),
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const GBMainPage(title: 'Grandbuddy'),
        );
      },
    );
  }
}

class GBMainPage extends StatefulWidget {
  const GBMainPage({super.key, required this.title});

  final String title;

  @override
  State<GBMainPage> createState() => _GBMainPageState();
}

class _GBMainPageState extends State<GBMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: SecureStorage().storage.read(key: "auto_login"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != "true") {
              return GBAuthPage();
            } else {
              return GBHomePage();
            }
          } else {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('로그인 정보 확인중...'),
                  SizedBox(height: 16.sp),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
