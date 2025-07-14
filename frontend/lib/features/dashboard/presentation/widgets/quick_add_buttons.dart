import 'package:flutter/material.dart';

class QuickAddButtons extends StatelessWidget {
  final void Function(int) onAddWater;
  const QuickAddButtons({super.key, required this.onAddWater});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => onAddWater(200),
          child: const Text('+200 мл'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(300),
          child: const Text('+300 мл'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(500),
          child: const Text('+500 мл'),
        ),
      ],
    );
  }
} 