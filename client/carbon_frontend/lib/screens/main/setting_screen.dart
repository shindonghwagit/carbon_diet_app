import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../auth/login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isNotificationOn = true;
  String _nickname = "지구지킴이";
  double _dailyGoal = 50.0;
  int _avatarIndex = 0;
  String _userId = "unknown";

  final List<String> _avatars = ["🧑‍🚀", "🦸", "🧝‍♀️", "👽", "🦊", "🐼"];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nickname = prefs.getString('nickname') ?? "지구지킴이";
      _dailyGoal = prefs.getDouble('dailyGoal') ?? 50.0;
      _userId = prefs.getString('userId') ?? "unknown";
      _avatarIndex = prefs.getInt('avatarIndex') ?? 0;
      _isNotificationOn = prefs.getBool('noti') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) prefs.setString(key, value);
    if (value is double) prefs.setDouble(key, value);
    if (value is int) prefs.setInt(key, value);
    if (value is bool) prefs.setBool(key, value);
  }

  // 1. 프로필 수정
  void _editProfile() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfileEditDialog(
        currentNickname: _nickname,
        currentAvatarIndex: _avatarIndex,
        avatars: _avatars,
      ),
    );

    if (result != null && mounted) {
      String newNickname = result['nickname'];
      int newAvatar = result['avatarIndex'];

      bool success = await _updateMemberInfo(_userId, newNickname);

      if (success) {
        setState(() {
          _nickname = newNickname;
          _avatarIndex = newAvatar;
        });

        _saveSetting('nickname', _nickname);
        _saveSetting('avatarIndex', _avatarIndex);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("정보가 수정되었습니다.")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("서버 저장 실패! 다시 시도해주세요.")));
      }
    }
  }

  Future<bool> _updateMemberInfo(String id, String newName) async {
    final url = Uri.parse(
      "http://10.0.2.2:8080/api/member/update?id=$id&name=$newName",
    );
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("수정 에러: $e");
    }
    return false;
  }

  //  아이디 변경 팝업 띄우기
  void _showIdChangeDialog() {
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("아이디 변경"),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: "새로운 아이디",
            hintText: "변경할 아이디를 입력하세요",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newId = idController.text;
              if (newId.isEmpty) return;

              try {
                // 백엔드 요청 (MemberController의 @RequestParam 방식)
                final response = await http.put(
                  Uri.parse("http://10.0.2.2:8080/api/member/change-id"),
                  body: {"currentId": LoginScreen.loggedInId, "newId": newId},
                );

                if (response.statusCode == 200) {
                  final result = response.body;

                  if (result.startsWith("SUCCESS")) {
                    if (!mounted) return;
                    Navigator.pop(context); // 팝업 닫기

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("아이디가 변경되었습니다. 다시 로그인해주세요."),
                      ),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    if (!mounted) return;
                    // 실패 메시지 (예: 이미 존재하는 아이디)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.split(":")[1])),
                    );
                  }
                }
              } catch (e) {
                print("에러: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("변경", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //  비밀번호 변경 팝업 띄우기
  void _showPasswordChangedDialog() {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("비밀번호 변경"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "현재 비밀번호"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "새 비밀번호"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "새 비밀번호 확인"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPwCtrl.text != confirmPwCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("새 비밀번호가 일치하지 않습니다.")),
                );
                return;
              }

              try {
                final response = await http.put(
                  Uri.parse("http://10.0.2.2:8080/api/member/password"),
                  body: {
                    "id": LoginScreen.loggedInId,
                    "currentPw": currentPwCtrl.text,
                    "newPw": newPwCtrl.text,
                  },
                );

                if (response.statusCode == 200) {
                  final result = response.body;

                  if (result.startsWith("SUCCESS")) {
                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("비밀번호가 변경되었습니다. 다시 로그인해주세요."),
                      ),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.split(":")[1])),
                    );
                  }
                }
              } catch (e) {
                print("에러: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("변경", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _changePasswordApi(String currentPw, String newPw) async {
    // _userId는 로그인할 때 저장된 내 아이디
    final url = Uri.parse(
      "http://10.0.2.2:8080/api/member/password?id=$_userId&currentPw=$currentPw&newPw=$newPw",
    );
    try {
      final response = await http.put(url);
      if (response.statusCode == 200 && response.body.startsWith("SUCCESS")) {
        return true;
      }
    } catch (e) {
      print("비번 변경 에러: $e");
    }
    return false;
  }

  // 2. 목표 설정 슬라이더
  void _editGoal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(30),
              height: 350,
              child: Column(
                children: [
                  const Text(
                    "하루 탄소 한도 설정",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${_dailyGoal.toInt()} kg",
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _dailyGoal,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: _dailyGoal.round().toString(),
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setModalState(() => _dailyGoal = value);
                      setState(() => _dailyGoal = value);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _saveSetting('dailyGoal', _dailyGoal);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "목표 저장",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. 도움말 팝업
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("도움말"),
        content: const SingleChildScrollView(
          child: Text(
            "탄소 발자국 줄이기 앱 사용법\n\n"
            "1. 홈 화면에서 '+' 버튼을 눌러 나의 탄소 배출 활동(전기, 교통, 식사)을 기록하세요.\n\n"
            "2. '나의 환경 점수'를 통해 이번 달 배출량을 확인하고 목표를 지켜보세요.\n\n"
            "3. 그래프를 통해 최근 7일간의 습관을 분석할 수 있습니다.\n\n"
            "작은 실천이 모여 지구를 지킵니다!",
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // 4. 회원 탈퇴
  Future<void> _deleteAccount() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("회원 탈퇴"),
        content: const Text("정말로 탈퇴하시겠습니까?\n모든 기록이 영구적으로 삭제됩니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "탈퇴하기",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      String myId = prefs.getString('userId') ?? "unknown";
      final url = Uri.parse('http://10.0.2.2:8080/api/reset?username=$myId');

      try {
        await http.delete(url);
        await prefs.clear();

        if (!mounted) return;

        // 2. 로그인 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("회원 탈퇴가 완료되었습니다.")));
      } catch (e) {
        print("탈퇴 오류: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("서버 연결 실패")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "설정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1️ 프로필 카드
            GestureDetector(
              onTap: _editProfile,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        _avatars[_avatarIndex],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _nickname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "내 정보를 수정하려면 터치하세요",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2️ 목표 관리
            _buildSectionHeader("목표 관리"),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.flag, color: Colors.green),
                title: const Text("하루 탄소 한도"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${_dailyGoal.toInt()} kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: _editGoal,
              ),
            ),

            const SizedBox(height: 30),

            _buildSectionHeader("계정"), // 섹션 제목 추가
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: Colors.purple),
                title: const Text("비밀번호 변경"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: _showPasswordChangedDialog,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: const Text("아이디 변경"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: _showIdChangeDialog,
            ),

            const SizedBox(height: 30),

            // 3️ 일반 설정
            _buildSectionHeader("일반"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.blue),
                    title: const Text("도움말"),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: _showHelp,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.grey),
                    title: const Text("로그아웃"),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_off, color: Colors.red),
                    title: const Text(
                      "회원 탈퇴",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProfileEditDialog extends StatefulWidget {
  final String currentNickname;
  final int currentAvatarIndex;
  final List<String> avatars;

  const ProfileEditDialog({
    super.key,
    required this.currentNickname,
    required this.currentAvatarIndex,
    required this.avatars,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _controller;
  late int _tempAvatarIndex;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
    _tempAvatarIndex = widget.currentAvatarIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Center(
        child: Text("프로필 수정", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.avatars.length, (index) {
                  bool isSelected = _tempAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _tempAvatarIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Text(
                        widget.avatars[index],
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "닉네임",
                hintText: "닉네임을 입력하세요",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            // 저장 버튼
            Navigator.pop(context, {
              'nickname': _controller.text,
              'avatarIndex': _tempAvatarIndex,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text("저장"),
        ),
      ],
    );
  }
}
