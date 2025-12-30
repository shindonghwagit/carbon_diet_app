import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransportInput extends StatefulWidget {
  final DateTime initialDate;
  final bool isReadOnly;

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
    String km = _controller.text;
    if (km.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userId') ?? "unknown";

    String dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      'http://10.0.2.2:8080/api/trans?type=$_selectedTransport&km=$km&username=$myId&date=$dateStr',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          _controller.clear();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("교통 기록 저장 완료!"),
              backgroundColor: Colors.blue,
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
            "오늘의 이동 수단은?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (!widget.isReadOnly) ...[
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
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
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["버스", "지하철", "택시", "자차"].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedTransport == type,
                selectedColor: Colors.green.shade200,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTransport = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.timer),
              labelText: "이동 거리 (km)",
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
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "이동 기록 저장",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
