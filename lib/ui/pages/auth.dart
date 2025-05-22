import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grandbuddy_client/ui/dialog/dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grandbuddy_client/utils/form_checker.dart';
import 'package:grandbuddy_client/utils/model/response.dart';
import 'package:grandbuddy_client/utils/requester.dart';
import 'package:grandbuddy_client/utils/secure_storage.dart';
import 'package:grandbuddy_client/ui/pages/home.dart';

class GBAuthPage extends StatefulWidget {
  const GBAuthPage({super.key});

  @override
  State<GBAuthPage> createState() => _GBAuthPageState();
}

class _GBAuthPageState extends State<GBAuthPage> {
  bool isLogin = true;
  int step = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController loginUserIdController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController profileController = TextEditingController();
  int roleValue = 0;

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      step = 0;
    });
  }

  void nextStep() {
    if (_formKey.currentState!.validate()) {
      if (step < 2)
        setState(() => step++);
      else
        print(step);
    } else {
      print("result: $_formKey.currentState!.validate()");
    }
  }

  void previousStep() {
    if (step > 0) setState(() => step--);
  }

  Widget customInput({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 19.sp),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: loginUserIdController,
              validator: validateID,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.user, size: 19.sp),
                hintText: "아이디",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: loginPasswordController,
              obscureText: true,
              validator: validatePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.lock, size: 19.sp),
                hintText: "비밀번호",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BAFD4),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                ResponseWithAccessToken result = await login(
                  loginUserIdController.text,
                  loginPasswordController.text,
                );
                String resultTitle = "";
                String resultContent = "";
                String token = "";
                bool success = false;
                switch (result.statusCode) {
                  case 200:
                    success = true;
                    resultTitle = "로그인 성공";
                    resultContent = result.message;
                    token = result.token!.accessToken;
                    break;
                  case 404:
                    resultTitle = "로그인 실패";
                    resultContent = result.message;
                    break;
                  case 422:
                    resultTitle = "데이터 전송 오류";
                    resultContent = result.message;
                    break;
                  case 500:
                    resultTitle = "서버 내부 오류";
                    resultContent = result.message;
                    break;
                }
                if (success) {
                  await SecureStorage().storage.write(
                    key: "access_token",
                    value: token,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GBHomePage()),
                  );
                } else {
                  createSmoothDialog(
                    context,
                    resultTitle,
                    Text(resultContent),
                    TextButton(
                      child: Text("닫기"),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
              }
            },
            child: const Text("로그인", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget signupStep1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: userIdController,
              validator: validateID,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.user, size: 19.sp),
                hintText: "아이디",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: validatePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.lock, size: 19.sp),
                hintText: "비밀번호",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: nicknameController,
              validator: validateNickname,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.faceGrin, size: 19.sp),
                hintText: "닉네임",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signupStep2() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: emailController,
              validator: validateEmail,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.envelope, size: 19.sp),
                hintText: "이메일",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: phoneController,
              validator: validatePhone,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.phone, size: 19.sp),
                hintText: "전화번호",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: birthdayController,
              validator: validateBirthDay,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.cake, size: 19.sp),
                hintText: "생년월일 (YYYY-MM-DD)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signupStep3() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.userCheck, size: 19.sp),
                hintText: "역할 선택",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value:
                  roleController.text.isNotEmpty
                      ? int.tryParse(roleController.text)
                      : null,
              items: const [
                DropdownMenuItem(value: 0, child: Text("시니어")),
                DropdownMenuItem(value: 1, child: Text("청년")),
              ],
              onChanged: (value) {
                if (value != null) {
                  roleController.text = value.toString();
                  roleValue = value;
                }
              },
            ),
          ),
          customInput(
            icon: Icons.home,
            hint: "주소",
            controller: addressController,
          ),
          customInput(
            icon: Icons.image,
            hint: "프로필 이미지 URL",
            controller: profileController,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7BAFD4),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                GeneralResponse result = await register(
                  userIdController.text,
                  passwordController.text,
                  nicknameController.text,
                  emailController.text,
                  phoneController.text.replaceAll("-", ""),
                  birthdayController.text,
                  roleValue,
                  addressController.text,
                  profileController.text,
                );
                String resultTitle = "";
                String resultContent = "";
                bool success = false;
                switch (result.statusCode) {
                  case 201:
                    success = true;
                    resultTitle = "회원가입 성공";
                    resultContent = result.message;
                    break;
                  case 409:
                    resultTitle = "중복된 데이터";
                    resultContent = result.message;
                    break;
                  case 422:
                    resultTitle = "데이터 전송 오류";
                    resultContent = result.message;
                    break;
                  case 500:
                    resultTitle = "서버 내부 오류";
                    resultContent = result.message;
                    break;
                }
                createSmoothDialog(
                  context,
                  resultTitle,
                  Text(resultContent),
                  TextButton(
                    child: Text("닫기"),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                );
                if (success) {
                  setState(() {
                    isLogin = true;
                  });
                }
              }
            },
            child: const Text("회원가입", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget currentForm() {
    if (isLogin) return loginForm();
    if (step == 0) return signupStep1();
    if (step == 1) return signupStep2();
    return signupStep3();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 12),
              ],
            ),
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? "로그인" : "회원가입",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                currentForm(),
                if (!isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (step > 0)
                          TextButton(
                            onPressed: previousStep,
                            child: const Text("이전"),
                          ),
                        const SizedBox(width: 8),
                        if (step < 2)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7BAFD4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: nextStep,
                            child: const Text(
                              "다음",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: toggleMode,
                  child: Text(
                    isLogin ? "계정이 없으신가요? 회원가입" : "이미 계정이 있으신가요? 로그인",
                    style: const TextStyle(color: Colors.blueGrey),
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
