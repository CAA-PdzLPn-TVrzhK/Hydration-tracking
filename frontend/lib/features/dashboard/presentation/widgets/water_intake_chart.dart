import 'package:flutter/material.dart';

class WaterIntakeChart extends StatelessWidget {
  final List<dynamic> data;
  const WaterIntakeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Здесь должен быть график, но пока просто заглушка
    return Container(
      height: 150,
      color: Colors.blue[50],
      child: const Center(child: Text('График воды (заглушка)')),
    );
  }
} 