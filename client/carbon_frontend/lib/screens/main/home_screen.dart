import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalCarbon = 0.0;
  bool _isLoading = true;
  double _dailyLimit = 50.0;

  List<double> _weeklyUsage = [0, 0, 0, 0, 0, 0, 0];

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
    _todayTip = _tips[Random().nextInt(_tips.length)];
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    double savedGoal = prefs.getDouble('dailyGoal') ?? 50.0;
    String myId = prefs.getString('userId') ?? "unknown";

    final url = Uri.parse('http://10.0.2.2:8080/api/logs?username=$myId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        double monthlyTotal = 0;
        List<double> recent7Days = [0, 0, 0, 0, 0, 0, 0];

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        DateTime sevenDaysAgo = today.subtract(const Duration(days: 6));

        for (var item in data) {
          double carbon = item['carbonEmitted'];
          DateTime itemDate = DateTime.parse(item['createdAt']).toLocal();
          DateTime dateOnly = DateTime(
            itemDate.year,
            itemDate.month,
            itemDate.day,
          );

          if (dateOnly.year == today.year && dateOnly.month == today.month) {
            if (item['category'] == '전기') {
              monthlyTotal += (carbon / 30.0);
            } else {
              monthlyTotal += carbon;
            }
          }

          if (item['category'] == '전기') {
            double dailyElec = carbon / 30.0;
            for (int i = 0; i < 7; i++) {
              recent7Days[i] += dailyElec;
            }
          } else {
            int diff = today.difference(dateOnly).inDays;
            if (diff >= 0 && diff < 7) {
              int index = 6 - diff;
              recent7Days[index] += carbon;
            }
          }
        }

        setState(() {
          _dailyLimit = savedGoal;
          _totalCarbon = monthlyTotal;
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
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    if (_totalCarbon < _dailyLimit * 0.4) {
      statusColor = Colors.green;
      statusIcon = Icons.sentiment_very_satisfied_outlined;
      statusMessage = "지구가 웃고 있어요";
    } else if (_totalCarbon < _dailyLimit * 0.8) {
      statusColor = Colors.orange;
      statusIcon = Icons.sentiment_neutral_outlined;
      statusMessage = "지구가 힘들어 해요";
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.sentiment_very_dissatisfied_outlined;
      statusMessage = "지구가 많이 아파요";
    }

    double percent = (_totalCarbon / _dailyLimit).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "나의 환경 점수",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(statusIcon, size: 80, color: statusColor),

                        const SizedBox(height: 15),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),

                        const SizedBox(height: 20),
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
                          child: Text(
                            "이번 달 누적: ${_totalCarbon.toStringAsFixed(1)} kg",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
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
                            Text(
                              "오늘의 Eco 꿀팁",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(_todayTip, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "최근 7일 배출 추이", // 제목 변경
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            DateTime day = DateTime.now().subtract(
                              Duration(days: 6 - index),
                            );
                            List<String> weekDays = [
                              "월",
                              "화",
                              "수",
                              "목",
                              "금",
                              "토",
                              "일",
                            ];
                            String label = weekDays[day.weekday - 1];

                            return Column(
                              children: [
                                Container(
                                  width: 15,
                                  height: (_weeklyUsage[index] * 5).clamp(
                                    0,
                                    100,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
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

  Widget _buildBar(String day, double value) {
    double barHeight = (value * 2).clamp(0.0, 100.0);
    if (value > 0 && barHeight < 5) barHeight = 5;
    return Column(
      children: [
        Text(
          value > 0 ? "${value.toInt()}" : "",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Container(
          width: 15,
          height: barHeight,
          decoration: BoxDecoration(
            color: value > 20 ? Colors.redAccent : Colors.greenAccent,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text(day, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
