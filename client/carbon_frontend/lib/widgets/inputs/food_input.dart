import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodInput extends StatefulWidget {
  final DateTime initialDate;

  const FoodInput({super.key, required this.initialDate});

  @override
  State<FoodInput> createState() => _FoodInputState();
}

class _FoodInputState extends State<FoodInput> {
  final TextEditingController _controller = TextEditingController();
  String _selectedFood = "소고기";

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

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
    String amount = _controller.text;
    if (amount.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userId') ?? "unknown";

    String dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      'http://10.0.2.2:8080/api/food?type=$_selectedFood&amount=$amount&username=$myId&date=$dateStr',
    );

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
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

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

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: calculateUsage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "식사 기록 저장",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
