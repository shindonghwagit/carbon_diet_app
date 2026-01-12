import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';

import '../main_screen.dart';
import 'signup_screen.dart';
import 'find_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String loggedInId = "";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _login() async {
    String id = _idController.text;
    String pw = _pwController.text;

    if (id.isEmpty || pw.isEmpty) return;

    final url = Uri.parse('http://10.0.2.2:8080/api/login?id=$id&pw=$pw');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        String result = utf8.decode(response.bodyBytes);

        if (result.startsWith("SUCCESS")) {
          String realNickname = result.split(":")[1];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nickname', realNickname);
          await prefs.setString('userId', _idController.text);

          LoginScreen.loggedInId = _idController.text;

          print("로그인 성공!");
          print("저장된 아이디(전역변수): ${LoginScreen.loggedInId}");
          print("저장된 닉네임: $realNickname");

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          _showError(result.split(":")[1]);
        }
      }
    } catch (e) {
      _showError("서버 연결 실패");
      print(e);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Lottie.asset(
              'assets/eco.json',
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            const Text(
              "탄소 다이어트",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // ID 입력
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            // PW 입력
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),

            // 로그인 버튼
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "로그인",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 회원가입 연결
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "회원가입",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const Text("|", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindAccountScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "아이디/비밀번호 찾기",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("또는"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            _socialButton(
              "카카오로 시작하기",
              Colors.yellow[700]!,
              Colors.black87,
              "K",
            ),
            const SizedBox(height: 10),
            _socialButton(
              "네이버로 시작하기",
              const Color(0xFF03C75A),
              Colors.white,
              "N",
            ),
            const SizedBox(height: 10),
            _socialButton(
              "구글로 시작하기",
              Colors.white,
              Colors.black87,
              "G",
              border: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
    String text,
    Color bgColor,
    Color textColor,
    String logo, {
    bool border = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        _showError("$text 기능은 API 연동이 필요합니다!");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: border ? const BorderSide(color: Colors.grey) : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(logo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
