import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

void main() async {
  await initializeDateFormatting(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
    scaffoldBackgroundColor: const Color(0xFFF6F7F8),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    tabBarTheme: const TabBarThemeData(
    labelColor: Color(0xFF2E7D32),
    unselectedLabelColor: Colors.grey,
    indicatorSize: TabBarIndicatorSize.tab,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  ),
  home: const SplashScreen(),
);

  }
}

// ---------------------------------------------------------
//  1. 표지
// ---------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 뒤에 로그인 화면으로 자동 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // 브랜드 컬러
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.eco, size: 100, color: Colors.white), // 대형 로고
            SizedBox(height: 20),
            Text(
              "탄소 다이어트",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 10),
            Text("지구를 살리는 작은 습관", style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
//  2. 로그인 화면
// ---------------------------------------------------------
//  2. 로그인 화면 (수정됨: 소셜 로그인 UI + 서버 연동)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

    // 서버에 로그인 요청
    final url = Uri.parse('http://10.0.2.2:8080/api/login?id=$id&pw=$pw');
    try {
      final response = await http.post(url);
      
      if (response.statusCode == 200) {
        String result = utf8.decode(response.bodyBytes);
        
        if (result.startsWith("SUCCESS")) {
          //  서버에서 온 응답 예시 -> "SUCCESS:지구용사"
          String realNickname = result.split(":")[1]; // "지구용사"만 추출

          // 휴대폰에 닉네임 저장 (이 부분이 추가되었습니다!)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nickname', realNickname); 
          
          print("저장 완료! 환영합니다, $realNickname님!");

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else {
          // 실패 메시지 (FAIL:...)
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
            const Icon(Icons.eco, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("탄소 다이어트", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            // ID 입력
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "아이디",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("로그인", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            
            // 회원가입 연결
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text("아직 계정이 없으신가요? 회원가입", style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 30),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("또는")), Expanded(child: Divider())]),
            const SizedBox(height: 20),

            // 소셜 로그인 버튼들 
            _socialButton("카카오로 시작하기", Colors.yellow[700]!, Colors.black87, "K"),
            const SizedBox(height: 10),
            _socialButton("네이버로 시작하기", const Color(0xFF03C75A), Colors.white, "N"),
            const SizedBox(height: 10),
            _socialButton("구글로 시작하기", Colors.white, Colors.black87, "G", border: true),
          ],
        ),
      ),
    );
  }

  // 소셜 버튼 만드는 함수
  Widget _socialButton(String text, Color bgColor, Color textColor, String logo, {bool border = false}) {
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
          Text(logo, style: const TextStyle(fontWeight: FontWeight.bold)), // 로고 대신 글자
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

//  회원가입 화면
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    String id = _idController.text;
    String pw = _pwController.text;
    String name = _nameController.text;

    if (id.isEmpty || pw.isEmpty || name.isEmpty) return;

    // 서버에 회원가입 요청
    final url = Uri.parse('http://10.0.2.2:8080/api/register?id=$id&pw=$pw&name=$name');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        String result = utf8.decode(response.bodyBytes);
        if (result.startsWith("SUCCESS")) {
          // 가입 성공 시 팝업 띄우고 로그인 화면으로 복귀
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("가입 성공"),
                content: const Text("회원가입이 완료되었습니다!\n로그인 해주세요."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // 팝업 닫기
                      Navigator.pop(context); // 회원가입 창 닫기 (로그인 화면으로)
                    }, 
                    child: const Text("확인")
                  )
                ],
              ),
            );
          }
        } else {
          _showError(result.split(":")[1]); // 실패 사유 표시
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
      appBar: AppBar(title: const Text("회원가입"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(controller: _idController, decoration: const InputDecoration(labelText: "아이디", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(controller: _pwController, obscureText: true, decoration: const InputDecoration(labelText: "비밀번호", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 15),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "닉네임", border: OutlineInputBorder(), prefixIcon: Icon(Icons.face))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: const Text("가입하기", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. 메인 화면 
// ---------------------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatScreen(),
    const NewsScreen(),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // + 버튼 누르면 나오는 '통합 기록장'
  void _showRecordModal(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 600,
            // 2. [전달] 받은 날짜를 BottomSheet에 넘김
            child: RecordBottomSheet(selectedDate: date), 
          ),
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // 바로 여기서 클릭한 날짜를 넣어서 실행!
    _showRecordModal(selectedDay); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed:  () {
          // 오늘 날짜로 기록장 열기
          DateTime today = DateTime.now();
          _showRecordModal(today);
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(icon: Icons.home, label: "홈", index: 0),
              _buildTabItem(icon: Icons.bar_chart, label: "통계", index: 1),
              const SizedBox(width: 40),
              _buildTabItem(icon: Icons.emoji_events, label: "매거진", index: 2),
              _buildTabItem(icon: Icons.settings, label: "설정", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.green : Colors.grey),
          Text(label, style: TextStyle(color: isSelected ? Colors.green : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

//  통합 기록 시트 (전기 / 교통 / 식사 탭 포함)
class RecordBottomSheet extends StatelessWidget {
  // 1. [추가] 날짜를 받는 변수
  final DateTime selectedDate; 

  // 2. [추가] 생성자 수정
  const RecordBottomSheet({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 10),
          const TabBar(
            tabs: [
              Tab(text: " 전기", icon: Icon(Icons.bolt)),
              Tab(text: " 교통", icon: Icon(Icons.directions_bus)),
              Tab(text: " 식사", icon: Icon(Icons.restaurant)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ElectricityInput(initialDate: selectedDate), // ⚡ 전기도 날짜 넘기기
                TransportInput(initialDate: selectedDate),   // 🚌 교통도 날짜 넘기기
                FoodInput(initialDate: selectedDate),        // 🍱 식사도 날짜 넘기기
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  1. 전기 입력 화면 
class ElectricityInput extends StatefulWidget {
  final DateTime initialDate; // 1. 날짜 받기
  final bool isReadOnly;      // 2. 고정 모드 받기

  const ElectricityInput({
    super.key,
    required this.initialDate,
    this.isReadOnly = false,
  });

  @override
  State<ElectricityInput> createState() => _ElectricityInputState();
}

class _ElectricityInputState extends State<ElectricityInput> {
  final TextEditingController _controller = TextEditingController();
  late DateTime _selectedDate; // 3. 내 변수 준비

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate; // 4. 받아온 날짜로 초기화
  }

  Future<void> calculateUsage() async {
    String money = _controller.text;
    if (money.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userid') ?? "unknown";

    // 5. 날짜 포함해서 전송 (yyyy-MM-dd)
    String dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";
    
    // URL에 &date=$dateStr 추가
    final url = Uri.parse('http://10.0.2.2:8080/api/elec?money=$money&username=$myId&date=$dateStr');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          _controller.clear();       
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("전기요금 기록 저장 완료!"), backgroundColor: Colors.blue),
          );
        }
      }
    } catch (e) {
      print("서버 연결 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("이번 달 전기요금은?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // 6. 달력에서 왔으면 날짜 보여주기 (수정은 불가)
          if (widget.isReadOnly) 
            Text("날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}", 
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                icon: Icon(Icons.flash_on, color: Colors.amber),
                border: InputBorder.none,
                hintText: "요금을 입력하세요 (원)",
                suffixText: "원",
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: calculateUsage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text("전기요금 기록 저장", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

//  2. 교통 입력 화면 
// 2. 교통 입력 화면 (수정됨 ✨)
class TransportInput extends StatefulWidget {
  final DateTime initialDate; // 1. 날짜 받기
  final bool isReadOnly;      // 2. 고정 모드 받기

  const TransportInput({
    super.key,
    required this.initialDate,
    this.isReadOnly = false,
  });

  @override
  State<TransportInput> createState() => _TransportInputState();
}

class _TransportInputState extends State<TransportInput> {
  final TextEditingController _controller = TextEditingController();
  String _selectedTransport = "버스";
  late DateTime _selectedDate; // 3. 내 변수

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate; // 4. 초기화
  }

  // 날짜 선택 팝업
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> calculateUsage() async {
    String km = _controller.text;
    if (km.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userid') ?? "unknown";

    String dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";

    final url = Uri.parse('http://10.0.2.2:8080/api/trans?type=$_selectedTransport&km=$km&username=$myId&date=$dateStr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          _controller.clear();       
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("교통 기록 저장 완료!"), backgroundColor: Colors.blue),
          );
        }
      }
    } catch (e) { print("에러: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("오늘의 이동 수단은?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 5. [핵심] isReadOnly가 아닐 때만(false일 때만) 날짜 선택 버튼 보여주기!
          if (!widget.isReadOnly) ...[
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}", style: const TextStyle(fontSize: 16)),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["버스", "지하철", "택시", "자차"].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedTransport == type,
                selectedColor: Colors.green.shade200,
                onSelected: (selected) { if (selected) setState(() => _selectedTransport = type); },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.timer), labelText: "이동 거리 (km)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: calculateUsage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text("이동 기록 저장", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. 식사 입력 화면 (수정 완료)
class FoodInput extends StatefulWidget {
  final DateTime initialDate; 

  // 2. [수정] 생성자에서 initialDate를 필수로 받음
  const FoodInput({super.key, required this.initialDate});

  @override
  State<FoodInput> createState() => _FoodInputState();
}

class _FoodInputState extends State<FoodInput> {
  final TextEditingController _controller = TextEditingController();
  String _selectedFood = "소고기"; // 변수명 확인!

  // [위치 1] 날짜 변수 추가
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // 4. [수정] 받아온 날짜(widget.initialDate)로 초기화!
    _selectedDate = widget.initialDate; 
  }

  // [위치 2] 날짜 선택 함수 추가
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // [위치 3] 전송 함수 수정 (날짜 포함)
  Future<void> calculateUsage() async {
    String amount = _controller.text;
    if (amount.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userid') ?? "unknown";

    // 날짜 문자열 변환
    String dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";

    // URL에 &date=$dateStr 추가
    final url = Uri.parse('http://10.0.2.2:8080/api/food?type=$_selectedFood&amount=$amount&username=$myId&date=$dateStr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          _controller.clear();      
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("식사 기록이 저장되었습니다."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print("에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "오늘 무엇을 드셨나요?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // [위치 4] 날짜 선택 버튼 UI
          GestureDetector(
             onTap: _pickDate,
             child: Container(
               margin: const EdgeInsets.only(bottom: 20),
               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.grey.shade300),
                 borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     "날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
                     style: const TextStyle(fontSize: 16),
                   ),
                   const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                 ],
               ),
             ),
           ),

          // (식사 메뉴 선택 버튼들)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["소고기", "돼지고기", "닭고기", "채식"].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedFood == type,
                selectedColor: Colors.orange.shade200,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedFood = type);
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // (입력창)
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.restaurant_menu),
              labelText: "식사량 (인분)",
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // (저장 버튼)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: calculateUsage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("식사 기록 저장", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// [내부 화면들] 홈, 통계, 챌린지, 설정
// ---------------------------------------------------------

//  1. 홈 화면 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalCarbon = 0.0;
  bool _isLoading = true;
  double _dailyLimit = 50.0;
  
  //  요일별 데이터 (월~일)
  List<double> _weeklyUsage = [0, 0, 0, 0, 0, 0, 0]; 

  // 💡 랜덤 꿀팁 리스트
  final List<String> _tips = [
    "텀블러를 사용하면 연간 2kg의 탄소를 줄일 수 있어요!",
    "이메일을 지우면 데이터센터의 전력을 아낄 수 있어요.",
    "양치컵을 쓰면 4.8L의 물을 절약할 수 있어요.",
    "비닐봉투 대신 장바구니를 챙겨보세요!",
    "가까운 거리는 걷거나 자전거를 타보세요.",
  ];
  String _todayTip = "";

  @override
  void initState() {
    super.initState();
    _todayTip = _tips[Random().nextInt(_tips.length)]; // 랜덤 꿀팁 선택
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    double savedGoal = prefs.getDouble('dailyGoal') ?? 50.0;
    String myId = prefs.getString('userid') ?? "unknown";

    final url = Uri.parse('http://10.0.2.2:8080/api/logs?username=$myId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        
        double monthlyTotal = 0; // 이번 달 총 합계
        List<double> recent7Days = [0, 0, 0, 0, 0, 0, 0]; // 최근 7일 그래프용

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        
        DateTime sevenDaysAgo = today.subtract(const Duration(days: 6));

        for (var item in data) {
          double carbon = item['carbonEmitted'];
          DateTime itemDate = DateTime.parse(item['createdAt']).toLocal();
          DateTime dateOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);

          // 1.  이번 달 데이터면 무조건 합산 (과거 입력 반영됨!)
          if (dateOnly.year == today.year && dateOnly.month == today.month) {
             // 전기는 1/30로 나눠서 더하기
             if (item['category'] == '전기') {
               monthlyTotal += (carbon / 30.0);
             } else {
               monthlyTotal += carbon;
             }
          }

          // 2. 최근 7일 데이터 계산
          if (item['category'] == '전기') {
             double dailyElec = carbon / 30.0;
             for(int i=0; i<7; i++) {
               recent7Days[i] += dailyElec;
             }
          } else {
             // 날짜 차이 계산 (오늘 - 기록날짜)
             int diff = today.difference(dateOnly).inDays;
             
             // 0일전(오늘) ~ 6일전 사이에 있으면 그래프에 추가
             if (diff >= 0 && diff < 7) {
               // 그래프는 왼쪽(과거) -> 오른쪽(오늘) 순서이므로 인덱스 계산
               // 6일전(index 0) ... 오늘(index 6)
               int index = 6 - diff; 
               recent7Days[index] += carbon;
             }
          }
        }

        setState(() {
          _dailyLimit = savedGoal; // (목표치는 그대로 둠)
          _totalCarbon = monthlyTotal; // "이번 달 총 배출량"으로 변경
          _weeklyUsage = recent7Days;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("에러: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 상태 결정 (아이콘 모드)
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    if (_totalCarbon < _dailyLimit * 0.4) {
      statusColor = Colors.green;
      statusIcon = Icons.sentiment_very_satisfied_outlined; // 웃는 얼굴
      statusMessage = "지구가 웃고 있어요";
    } else if (_totalCarbon < _dailyLimit * 0.8) {
      statusColor = Colors.orange;
      statusIcon = Icons.sentiment_neutral_outlined; // 무표정
      statusMessage = "지구가 고민 중이에요";
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.sentiment_very_dissatisfied_outlined; // 우는 얼굴
      statusMessage = "지구가 많이 아파요";
    }
    
    double percent = (_totalCarbon / _dailyLimit).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[50], // 배경을 살짝 회색으로 (카드 돋보이게)
      appBar: AppBar(
        title: const Text("나의 환경 점수", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // 내용이 많아지니 스크롤 가능하게!
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ------------------------------------
                  // 1️ 메인 상태 카드 (아이콘 + 게이지)
                  // ------------------------------------
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        Icon(statusIcon, size: 80, color: statusColor), // 다시 아이콘으로!
                        const SizedBox(height: 15),
                        Text(statusMessage, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor)),
                        const SizedBox(height: 20),
                        
                        // 게이지 바
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.grey[200],
                          color: statusColor,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("이번 달 누적: ${_totalCarbon.toStringAsFixed(1)} kg",
                            style: const TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // ------------------------------------
                  // 2️ 오늘의 꿀팁 카드 
                  // ------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50], // 연한 파란 배경
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lightbulb, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text("오늘의 Eco 꿀팁", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(_todayTip, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------
                  // 3️ 주간 요약 그래프 
                  // ------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... 위쪽 코드 생략 ...
              const Text(
                "최근 7일 배출 추이", // 제목 변경
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  // 요일 이름 동적으로 계산 (6일전 ~ 오늘)
                  DateTime day = DateTime.now().subtract(Duration(days: 6 - index));
                  List<String> weekDays = ["월", "화", "수", "목", "금", "토", "일"];
                  String label = weekDays[day.weekday - 1]; // 요일 구하기

                  return Column(
                    children: [
                      // 막대 그래프 (기존 코드 유지)
                      Container(
                        width: 15,
                        height: (_weeklyUsage[index] * 5).clamp(0, 100), 
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // 요일 라벨 (월, 화, 수... 가 자동으로 오늘 기준으로 바뀜!)
                      Text(
                        label, 
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  );
                }),
              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 막대그래프 하나 그리는 함수
  Widget _buildBar(String day, double value) {
    // 값이 너무 크면 그래프 뚫고 나가는 거 방지 (최대 높이 100으로 제한)
    double barHeight = (value * 2).clamp(0.0, 100.0); 
    if (value > 0 && barHeight < 5) barHeight = 5; // 값이 있으면 최소한 조금은 보이게

    return Column(
      children: [
        Text(value > 0 ? "${value.toInt()}" : "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: 15,
          height: barHeight,
          decoration: BoxDecoration(
            color: value > 20 ? Colors.redAccent : Colors.greenAccent, // 많이 쓰면 빨간색
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text(day, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// 2. 통계 화면 
class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  // 날짜별 데이터 저장소 
  Map<DateTime, List<dynamic>> _events = {};
  
  // 선택된 날짜 & 현재 보고 있는 달
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 처음엔 오늘 날짜 선택
    _fetchLogs();
  }

  // 서버에서 데이터 가져와서 달력에 맞게 가공하기
  Future<void> _fetchLogs() async {
    // 1. 내 아이디 가져오기 (로그인할 때 저장한 것)
    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userid') ?? "unknown";

    // 2. 내 아이디로 서버에 요청보내기 (?username=...)
    final url = Uri.parse('http://10.0.2.2:8080/api/logs?username=$myId');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        
        Map<DateTime, List<dynamic>> grouped = {};
        
        for (var item in data) {
          if (item['createdAt'] != null) {
            DateTime fullDate = DateTime.parse(item['createdAt']).toLocal();
            
            // 핵심: 통계에서도 전기는 "매일 조금씩 쓴 것"으로 나눠서 보여줌
            if (item['category'] == '전기') {
              double monthlyCarbon = item['carbonEmitted'];
              // 해당 월의 마지막 날짜 구하기 (예: 2월->28일, 3월->31일)
              int daysInMonth = DateTime(fullDate.year, fullDate.month + 1, 0).day;
              
              // 하루치 탄소량 & 금액 계산
              double dailyCarbon = monthlyCarbon / daysInMonth;
              double dailyMoney = item['inputAmount'] / daysInMonth;

              // 1일부터 말일까지 데이터 쫙 뿌리기 (달력에 점 찍기 위해)
              for (int i = 1; i <= daysInMonth; i++) {
                DateTime dateKey = DateTime(fullDate.year, fullDate.month, i);
                if (grouped[dateKey] == null) grouped[dateKey] = [];
                
                // 가짜 데이터(일일 환산용)를 만들어서 리스트에 넣음
                grouped[dateKey]!.add({
                  'category': '전기',
                  'type': '전기 (일일 환산)', 
                  'inputAmount': dailyMoney.toStringAsFixed(0), 
                  'carbonEmitted': double.parse(dailyCarbon.toStringAsFixed(2)),
                  'createdAt': dateKey.toIso8601String(),
                });
              }
            } else {
              //  나머지는(교통, 식사) 그냥 그 날짜에 저장
              DateTime dateKey = DateTime(fullDate.year, fullDate.month, fullDate.day);
              if (grouped[dateKey] == null) grouped[dateKey] = [];
              grouped[dateKey]!.add(item);
            }
          }
        }

        setState(() {
          _events = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("에러: $e");
      setState(() => _isLoading = false);
    }
  }

  // 특정 날짜의 기록 가져오기
  List<dynamic> _getEventsForDay(DateTime day) {
    // 시간 정보 무시하고 날짜로만 조회
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // 이번 달 하루 평균 배출량 계산
  double _calculateMonthlyAverage() {
    double total = 0;
    int count = 0;
    
    _events.forEach((key, value) {
      // 현재 보고 있는 달(Month)과 같은 데이터만 합산
      if (key.month == _focusedDay.month && key.year == _focusedDay.year) {
        for (var item in value) {
          total += item['carbonEmitted'];
        }
        count++; // 데이터가 있는 날짜 수
      }
    });

    if (count == 0) return 0.0;
    return total / count; // (총 배출량 / 기록된 날짜 수)
  }

  void _showRecordModal(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 600,
            // RecordBottomSheet에 날짜 전달
            child: RecordBottomSheet(selectedDate: date), 
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 목록
    final selectedEvents = _getEventsForDay(_selectedDay!);
    // 이번 달 평균
    double monthlyAvg = _calculateMonthlyAverage();

    return Scaffold(
      appBar: AppBar(title: const Text("나의 탄소 달력"), automaticallyImplyLeading: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. 월별 통계 요약
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics, color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        "${_focusedDay.month}월 하루 평균: ${monthlyAvg.toStringAsFixed(1)} kg",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),

                // 2. 달력 
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showRecordModal(selectedDay);
                  },
                  
                  //  여기가 핵심! 달력 스타일 커스텀
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false, // 이번 달 아닌 날짜 숨김
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent, // 오늘 날짜는 파란 동그라미
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green, // 선택한 날짜는 초록 동그라미
                      shape: BoxShape.circle,
                    ),
                  ),

                  //  점(Marker)을 내 맘대로 그리는 기능
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();

                      // 1. 그날의 총 탄소 배출량 계산
                      double dailyTotal = 0;
                      for (var event in events) {
                        // event가 Map<String, dynamic> 형태라고 가정
                        if (event is Map && event['carbonEmitted'] != null) {
                           dailyTotal += (event['carbonEmitted'] as num).toDouble();
                        }
                      }

                      // 2. 배출량에 따라 점 색깔 결정 (기준은 원하시는 대로 수정 가능!)
                      Color dotColor = Colors.green; // 기본: 착함 
                      if (dailyTotal > 10.0) {
                        dotColor = Colors.redAccent; // 위험 
                      } else if (dailyTotal > 5.0) {
                        dotColor = Colors.orange; // 주의 
                      }

                      // 3. 딱 하나의 점만 리턴
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                          width: 7.0,
                          height: 7.0,
                        ),
                      );
                    },
                  ),
                  
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const Divider(thickness: 1),

                // 3. 선택한 날짜의 상세 리스트
                Expanded(
                  child: selectedEvents.isEmpty
                      ? Center(
                          child: Text(
                            "${_selectedDay!.month}월 ${_selectedDay!.day}일 기록이 없습니다.",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: selectedEvents.length,
                          itemBuilder: (context, index) {
                            final item = selectedEvents[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              child: ListTile(
                                leading: _getIcon(item['category']),
                                title: Text(item['type']),
                                subtitle: Text("${item['inputAmount']} "),
                                trailing: Text(
                                  "${item['carbonEmitted']} kg",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // 아이콘 도우미 함수
  Widget _getIcon(String? category) {
    if (category == '전기') return const Icon(Icons.bolt, color: Colors.yellow);
    if (category == '교통') return const Icon(Icons.directions_bus, color: Colors.blue);
    if (category == '식사') return const Icon(Icons.restaurant, color: Colors.orange);
    return const Icon(Icons.question_mark, color: Colors.grey);
  }
}

//  3. 환경 뉴스 & 매거진 화면
class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  //  보여줄 기사 목록 (제목, 출처, 이미지, 링크)
  final List<Map<String, String>> _articles = const [
    {
      "title": "지구를 살리는 '제로 웨이스트' 실천법 5가지",
      "source": "환경부 공식 블로그",
      "image": "https://picsum.photos/200/200?random=1", // 랜덤 이미지
      "url": "https://me.go.kr", // 실제 기사 주소로 바꾸면 됩니다
    },
    {
      "title": "올해 여름이 유난히 더웠던 진짜 이유",
      "source": "그린피스 뉴스",
      "image": "https://picsum.photos/200/200?random=2",
      "url": "https://www.greenpeace.org/korea/",
    },
    {
      "title": "플라스틱 빨대, 정말로 사라질까?",
      "source": "BBC Earth",
      "image": "https://picsum.photos/200/200?random=3",
      "url": "https://www.bbc.com/korean/features-44473551",
    },
    {
      "title": "탄소 중립이 무엇인가요? 쉽게 알아보기",
      "source": "대한민국 정책브리핑",
      "image": "https://picsum.photos/200/200?random=4",
      "url": "https://www.korea.kr",
    },
    {
      "title": "분리수거 헷갈리는 품목 총정리 (최신판)",
      "source": "서울시 환경과",
      "image": "https://picsum.photos/200/200?random=5",
      "url": "https://news.seoul.go.kr/env/",
    },
  ];

  // 링크 여는 함수
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('링크를 열 수 없습니다: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("환경 매거진"),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 숨김
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final item = _articles[index];
          return GestureDetector(
            onTap: () => _launchURL(item['url']!), // 클릭하면 링크 열기
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Row(
                children: [
                  // 1. 썸네일 이미지
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                    child: Image.network(
                      item['image']!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.broken_image));
                      },
                    ),
                  ),
                  
                  // 2. 기사 내용
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['source']!,
                            style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['title']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis, // 글자 넘치면 ... 처리
                          ),
                          const SizedBox(height: 5),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("더 보기 >", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 4. 설정 화면 (프로필, 초기화, 로그아웃)

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

  final List<String> _avatars = ["🧑‍🚀", "🦸", "🧝‍♀️", "👽", "🦊", "🐼"];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // 화면이 살아있을 때만 실행
    setState(() {
      _nickname = prefs.getString('nickname') ?? "지구지킴이";
      _dailyGoal = prefs.getDouble('dailyGoal') ?? 50.0;
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

  // 1. 프로필 수정 (멈춤 현상 수정됨 ✨)
  void _editProfile() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // 바깥 클릭해도 안 닫히게 (안전장치)
      builder: (context) => ProfileEditDialog(
        currentNickname: _nickname,
        currentAvatarIndex: _avatarIndex,
        avatars: _avatars,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _nickname = result['nickname'];
        _avatarIndex = result['avatarIndex'];
      });
      _saveSetting('nickname', _nickname);
      _saveSetting('avatarIndex', _avatarIndex);
    }
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
                  const Text("하루 탄소 한도 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("${_dailyGoal.toInt()} kg", style: const TextStyle(fontSize: 40, color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Slider(
                    value: _dailyGoal,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: _dailyGoal.round().toString(),
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setModalState(() => _dailyGoal = value); // 모달창 갱신
                      setState(() => _dailyGoal = value);      // 뒷배경 갱신
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
                    child: const Text("목표 저장", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. 도움말 팝업 (새로 추가됨)
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("탈퇴하기", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. 서버에 데이터 삭제 요청 (기존 reset API 재활용)
      final prefs = await SharedPreferences.getInstance();
      String myId = prefs.getString('userid') ?? "unknown";
      
      // 실제로는 회원탈퇴 API가 필요하지만, 우선 기록 삭제로 대체
      final url = Uri.parse('http://10.0.2.2:8080/api/reset?username=$myId'); 
      
      try {
        await http.delete(url); // 서버 기록 삭제
        await prefs.clear();    // 앱 내부 저장소(로그인 정보 등) 싹 비우기
        
        if (!mounted) return;
        
        // 2. 로그인 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // 뒤로가기 불가능하게 만듦
        );
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원 탈퇴가 완료되었습니다.")));
      } catch (e) {
        print("탈퇴 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("서버 연결 실패")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("설정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.green.shade100,
                      child: Text(_avatars[_avatarIndex], style: const TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_nickname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text("내 정보를 수정하려면 터치하세요", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                    Text("${_dailyGoal.toInt()} kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: _editGoal,
              ),
            ),

            const SizedBox(height: 30),

            // 3️ 일반 설정
            _buildSectionHeader("일반"),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("푸시 알림"),
                    secondary: const Icon(Icons.notifications_active, color: Colors.orange),
                    value: _isNotificationOn,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() => _isNotificationOn = value);
                      _saveSetting('noti', value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.blue),
                    title: const Text("도움말"),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: _showHelp, // 도움말 기능 연결
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.grey),
                    title: const Text("로그아웃"),
                    onTap: () async {
                       // 로그아웃 시 SharedPreferences 일부 삭제 (자동로그인 방지)
                       final prefs = await SharedPreferences.getInstance();
                       await prefs.remove('userid'); 
                       if(!mounted) return;
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_off, color: Colors.red),
                    title: const Text("회원 탈퇴", style: TextStyle(color: Colors.red)), // 빨간 글씨
                    onTap: _deleteAccount, // 회원 탈퇴 연결
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
      child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }
}

//  중요! 이 클래스는 SettingScreen 클래스 중괄호 { } 바깥에 있어야 합니다!! 
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
    // ListView 대신 가벼운 Row를 사용해서 Layout 충돌 방지!
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Center(child: Text("프로필 수정", style: TextStyle(fontWeight: FontWeight.bold))),
      content: SingleChildScrollView( // 키보드가 올라와도 화면이 안 가려지게 감싸줌
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 창을 띄움
          children: [
            const SizedBox(height: 10),
            
            // 아바타 선택 영역 (ListView 제거 -> SingleChildScrollView + Row 변경)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로 스크롤 허용
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.avatars.length, (index) {
                  bool isSelected = _tempAvatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _tempAvatarIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8), // 간격 넓힘
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.green, width: 2) : Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Text(
                        widget.avatars[index], 
                        style: const TextStyle(fontSize: 34), // 이모지 크기 조절
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 25),
            
            //  닉네임 입력창
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "닉네임",
                hintText: "닉네임을 입력하세요",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("저장"),
        ),
      ],
    );
  }
}