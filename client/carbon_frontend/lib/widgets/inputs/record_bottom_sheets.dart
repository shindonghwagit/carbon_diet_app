import 'package:flutter/material.dart';
import 'elec_input.dart';
import 'trains_input.dart';
import 'food_input.dart';

class RecordBottomSheet extends StatelessWidget {
  final DateTime selectedDate;

  const RecordBottomSheet({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
                ElectricityInput(initialDate: selectedDate),
                TransportInput(initialDate: selectedDate),
                FoodInput(initialDate: selectedDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
