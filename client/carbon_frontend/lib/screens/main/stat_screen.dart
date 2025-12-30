import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../widgets/inputs/record_bottom_sheets.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  Map<DateTime, List<dynamic>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastTapTime;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String myId = prefs.getString('userId') ?? "unknown";

    final url = Uri.parse('http://10.0.2.2:8080/api/logs?username=$myId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        Map<DateTime, List<dynamic>> grouped = {};

        for (var item in data) {
          if (item['createdAt'] != null) {
            DateTime fullDate = DateTime.parse(item['createdAt']).toLocal();

            if (item['category'] == '전기') {
              double monthlyCarbon = item['carbonEmitted'];
              int daysInMonth = DateTime(
                fullDate.year,
                fullDate.month + 1,
                0,
              ).day;

              double dailyCarbon = monthlyCarbon / daysInMonth;
              double dailyMoney = item['inputAmount'] / daysInMonth;

              for (int i = 1; i <= daysInMonth; i++) {
                DateTime dateKey = DateTime(fullDate.year, fullDate.month, i);
                if (grouped[dateKey] == null) grouped[dateKey] = [];

                grouped[dateKey]!.add({
                  'category': '전기',
                  'type': '전기 (일일 환산)',
                  'inputAmount': dailyMoney.toStringAsFixed(0),
                  'carbonEmitted': double.parse(dailyCarbon.toStringAsFixed(2)),
                  'createdAt': dateKey.toIso8601String(),
                });
              }
            } else {
              DateTime dateKey = DateTime(
                fullDate.year,
                fullDate.month,
                fullDate.day,
              );
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

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  double _calculateMonthlyAverage() {
    double total = 0;
    int count = 0;

    _events.forEach((key, value) {
      if (key.month == _focusedDay.month && key.year == _focusedDay.year) {
        for (var item in value) {
          total += item['carbonEmitted'];
        }
        count++;
      }
    });

    if (count == 0) return 0.0;
    return total / count;
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 600,
            child: RecordBottomSheet(selectedDate: date),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay!);
    double monthlyAvg = _calculateMonthlyAverage();

    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 탄소 통계"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    DateTime now = DateTime.now();
                    if (isSameDay(_selectedDay, selectedDay) &&
                        _lastTapTime != null &&
                        now.difference(_lastTapTime!) <
                            const Duration(milliseconds: 300)) {
                      _showRecordModal(selectedDay);
                      _lastTapTime = null;
                    } else {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _lastTapTime = now;
                    }
                  },

                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();

                      double dailyTotal = 0;
                      for (var event in events) {
                        if (event is Map && event['carbonEmitted'] != null) {
                          dailyTotal += (event['carbonEmitted'] as num)
                              .toDouble();
                        }
                      }

                      Color dotColor = Colors.green;
                      if (dailyTotal > 10.0) {
                        dotColor = Colors.redAccent;
                      } else if (dailyTotal > 5.0) {
                        dotColor = Colors.orange;
                      }

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
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(thickness: 1),

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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: _getIcon(item['category']),
                                title: Text(item['type']),
                                subtitle: Text("${item['inputAmount']} "),
                                trailing: Text(
                                  "${item['carbonEmitted']} kg",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
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

  Widget _getIcon(String? category) {
    if (category == '전기') return const Icon(Icons.bolt, color: Colors.yellow);
    if (category == '교통')
      return const Icon(Icons.directions_bus, color: Colors.blue);
    if (category == '식사')
      return const Icon(Icons.restaurant, color: Colors.orange);
    return const Icon(Icons.question_mark, color: Colors.grey);
  }
}
