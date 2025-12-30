import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FindAccountScreen extends StatefulWidget {
  const FindAccountScreen({super.key});

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

//
class _FindAccountScreenState extends State<FindAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();

  String _idFindMessage = "";
  String _pwFindMessage = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 2개
  }

  Future<void> _findId() async {
    String name = _nameController.text;
    String email = _emailController.text;

    var url = Uri.parse(
      "http://10.0.2.2:8080/api/member/find-id?name=$name&email=$email",
    );
    var response = await http.get(url);

    setState(() {
      _idFindMessage = response.body;
    });
  }

  // 비번 찾기 요청
  Future<void> _findPw() async {
    String id = _idController.text;
    String name = _nameController.text;
    var url = Uri.parse(
      "http://10.0.2.2:8080/api/member/find-pw?username=$id&name=$name",
    );
    var response = await http.get(url);

    setState(() {
      _pwFindMessage = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("계정 찾기")),
      body: Column(
        children: [
          // 탭 메뉴 (아이디 찾기 / 비번 찾기)
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "아이디 찾기"),
              Tab(text: "비밀번호 찾기"),
            ],
          ),

          // 탭 내용물
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // [탭1] 아이디 찾기 화면
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: "이름"),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: "이메일"),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: _findId, child: Text("아이디 찾기")),
                      SizedBox(height: 20),
                      Text(
                        _idFindMessage,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(labelText: "아이디"),
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: "이름"),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _findPw,
                        child: Text("비밀번호 찾기"),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _pwFindMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
