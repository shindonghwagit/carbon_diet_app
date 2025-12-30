import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ElectricityInput extends StatefulWidget {
  final DateTime initialDate;
  final bool isReadOnly;

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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> calculateUsage() async {
    String money = _controller.text;
    if (money.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userId') ?? "unknown";

    String dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      'http://10.0.2.2:8080/api/elec?money=$money&username=$myId&date=$dateStr',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          _controller.clear();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("전기요금 기록 저장 완료!"),
              backgroundColor: Colors.blue,
            ),
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
          const Text(
            "이번 달 전기요금은?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (widget.isReadOnly)
            Text(
              "날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "전기요금 기록 저장",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
