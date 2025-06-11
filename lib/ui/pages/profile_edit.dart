import 'package:flutter/material.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileEditPage extends StatefulWidget {
  User? user;
  ProfileEditPage({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController nicknameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  final passwordController = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: widget.user!.nickname);
    emailController = TextEditingController(text: widget.user!.email);
    addressController = TextEditingController(text: widget.user!.address);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (mounted) {
      setState(() => isProcessing = true);
    }

    // 실제 수정 API 호출 필요. 아래는 예시
    final profileData = {
      "password": passwordController.text,
      "nickname": nicknameController.text,
      "email": emailController.text,
      "address": addressController.text,
    };

    // TODO: 프로필 수정 API 호출 (예시)
    // final result = await updateProfileAPI(profileData);
    // if (result.statusCode == 200) ...

    await Future.delayed(const Duration(seconds: 1)); // 디버깅용 대기

    setState(() => isProcessing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("프로필이 저장되었습니다.")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Text(
          "프로필 편집",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7BAFD4),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("비밀번호", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "새 비밀번호를 입력하세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: "닉네임을 입력하세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text("이메일", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "이메일을 입력하세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text("주소", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: "주소를 입력하세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BAFD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isProcessing ? null : _saveProfile,
                child:
                    isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "저장",
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
