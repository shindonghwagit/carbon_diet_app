import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthController = TextEditingController();

  String _selectedGender = "남성";
  final List<String> _genderList = ["남성", "여성"];

  Future<void> _register() async {
    String id = _idController.text;
    String pw = _pwController.text;
    String name = _nameController.text;
    String email = _emailController.text;
    String birth = _birthController.text;
    String gender = _selectedGender;

    if (id.isEmpty ||
        pw.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        birth.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("모든 정보를 입력해주세요!")));
      return;
    }

    final url = Uri.parse(
      'http://10.0.2.2:8080/api/register?id=$id&pw=$pw&name=$name&email=$email&gender=$gender&birthDate=$birth',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        String result = utf8.decode(response.bodyBytes);
        if (result.startsWith("SUCCESS")) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("가입 성공"),
                content: const Text("회원가입이 완료되었습니다!\n로그인 해주세요."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text("확인"),
                  ),
                ],
              ),
            );
          }
        } else {
          if (result.contains(":")) {
            _showError(result.split(":")[1]);
          } else {
            _showError(result);
          }
        }
      }
    } catch (e) {
      _showError("서버 연결 실패");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // 1. 아이디
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            // 2. 비밀번호
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 15),

            // 3. 닉네임
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "닉네임",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.face),
              ),
            ),
            const SizedBox(height: 15),

            // 4. 이메일
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "이메일",
                hintText: "abc@naver.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _birthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "생년월일 (예: 19990101)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 15),

            // 6. 성별
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "성별",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // [남성] 버튼
                    Radio<String>(
                      value: "남성",
                      groupValue: _selectedGender, // 현재 선택된 값
                      activeColor: Colors.green, // 체크됐을 때 색상
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    const Text("남성"),

                    const SizedBox(width: 20), // 간격 띄우기
                    // [여성] 버튼
                    Radio<String>(
                      value: "여성",
                      groupValue: _selectedGender,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    const Text("여성"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("가입하기", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
