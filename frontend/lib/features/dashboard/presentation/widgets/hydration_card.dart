import 'package:flutter/material.dart';

class HydrationCard extends StatelessWidget {
  final int currentAmount;
  final int goalAmount;
  final int percentage;
  const HydrationCard({super.key, required this.currentAmount, required this.goalAmount, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня выпито', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('$currentAmount мл из $goalAmount мл'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percentage / 100),
            const SizedBox(height: 8),
            Text('Прогресс: $percentage%'),
          ],
        ),
      ),
    );
  }
} 