import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/ui/pages/auth.dart';

void main() async {
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
    return Scaffold(body: GBAuthPage());
  }
}
