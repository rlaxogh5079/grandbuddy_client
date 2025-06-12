import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/utils/req/user.dart';
import 'package:grandbuddy_client/utils/res/user.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileEditPage extends StatefulWidget {
  final User? user;
  const ProfileEditPage({Key? key, this.user}) : super(key: key);

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
    nicknameController = TextEditingController(
      text: widget.user?.nickname ?? "",
    );
    emailController = TextEditingController(text: widget.user?.email ?? "");
    addressController = TextEditingController(text: widget.user?.address ?? "");
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
    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String address = addressController.text.trim();
    String password = passwordController.text.trim();

    if (nickname.isEmpty || email.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("닉네임, 이메일, 주소는 필수입니다.")));
      return;
    }
    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("유효한 이메일을 입력하세요.")));
      return;
    }

    setState(() => isProcessing = true);

    final accessToken = await SecureStorage().storage.read(key: "access_token");
    final result = await updateUser(
      accessToken ?? "",
      password, // 빈 값이면 서버에서 무시
      nickname,
      email,
      address,
    );

    setState(() => isProcessing = false);

    if (result.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("프로필이 저장되었습니다.")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  InputDecoration _inputDecoration(String hint, IconData iconData) =>
      InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.w, right: 8),
          child: FaIcon(iconData, color: Color(0xFF7BAFD4), size: 20.sp),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFF7BAFD4), width: 2),
        ),
      );

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nicknameController,
                  decoration: _inputDecoration("닉네임", FontAwesomeIcons.userTag),
                ),
                SizedBox(height: 2.2.h),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    "이메일",
                    FontAwesomeIcons.solidEnvelope,
                  ),
                ),
                SizedBox(height: 2.2.h),

                TextField(
                  controller: addressController,
                  decoration: _inputDecoration(
                    "주소",
                    FontAwesomeIcons.locationDot,
                  ),
                ),
                SizedBox(height: 2.2.h),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration(
                    "새 비밀번호(미입력시 변경 안함)",
                    FontAwesomeIcons.lock,
                  ),
                ),

                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    icon: FaIcon(
                      FontAwesomeIcons.solidFloppyDisk,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    label:
                        isProcessing
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              "저장",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7BAFD4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isProcessing ? null : _saveProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
