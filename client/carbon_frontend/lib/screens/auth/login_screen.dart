import 'package:flutter/material.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_naver_login/flutter_naver_login.dart';

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

  Future<void> _processLoginSuccess(String userId, String nickname) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final tokenUrl = Uri.parse('http://10.0.2.2:8080/api/fcm-token');
        await http.post(tokenUrl, body: {'id': userId, 'token': token});
        print("FCM 토큰 전송 완료");
      }
    } catch (e) {
      print("토큰 전송 실패(무시 가능): $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setString('userId', userId);
    LoginScreen.loggedInId = userId;

    print(" 로그인 최종 완료: $userId ($nickname)");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Future<void> _loginWithKakao() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          if (error is PlatformException && error.code == 'CANCELED') return;
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      User user = await UserApi.instance.me();
      String nickname = user.kakaoAccount?.profile?.nickname ?? "카카오유저";

      await _authenticateWithServer("kakao_${user.id}", nickname);
    } catch (e) {
      print('카카오 실패: $e');
      _showError('카카오 로그인 실패');
    }
  }

  Future<void> _loginWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final account = result.account;

        // account가 null이면 중단 (안전)
        if (account == null || account.id == null) {
          _showError("네이버 계정 정보가 없습니다.");
          return;
        }

        final String socialId = "naver_${account.id!}";

        // nickname이 없을 수도 있으니 기본값 처리
        final String nickname = (account.nickname?.trim().isNotEmpty ?? false)
            ? account.nickname!.trim()
            : (account.name?.trim().isNotEmpty ?? false)
            ? account.name!.trim()
            : "네이버유저";

        await _authenticateWithServer(socialId, nickname);
      } else {
        _showError("네이버 로그인 취소/실패");
      }
    } catch (e) {
      print('네이버 실패: $e');
      _showError('네이버 로그인 실패');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final user = await GoogleSignIn().signIn();
      if (user != null) {
        await _authenticateWithServer(
          "google_${user.id}",
          user.displayName ?? "구글유저",
        );
      }
    } catch (e) {
      print('구글 실패: $e');
      _showError('구글 로그인 실패');
    }
  }

  // 소셜 로그인 정보를 서버로 보내는 함수
  Future<void> _authenticateWithServer(String socialId, String nickname) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/social-login');
    try {
      final response = await http.post(
        url,
        body: {'id': socialId, 'nickname': nickname},
      );

      if (response.statusCode == 200) {
        await _processLoginSuccess(socialId, nickname);
      } else {
        _showError("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      // 서버가 꺼져있어도 일단 로그인은 시켜줌 (테스트용)
      print("⚠️ 서버 연결 실패(테스트 모드): $e");
      await _processLoginSuccess(socialId, nickname);
    }
  }

  // ----------------------------------------------------------------
  // 3. 일반 ID/PW 로그인
  // ----------------------------------------------------------------
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
          await _processLoginSuccess(id, realNickname); // 공통 함수 사용
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Text("|", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FindAccountScreen(),
                    ),
                  ),
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
              onTap: _loginWithKakao,
            ),
            const SizedBox(height: 10),
            _socialButton(
              "네이버로 시작하기",
              const Color(0xFF03C75A),
              Colors.white,
              "N",
              onTap: _loginWithNaver,
            ),
            const SizedBox(height: 10),
            _socialButton(
              "구글로 시작하기",
              Colors.white,
              Colors.black87,
              "G",
              border: true,
              onTap: _loginWithGoogle,
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
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
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
