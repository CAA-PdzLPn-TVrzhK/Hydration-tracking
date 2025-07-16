import 'package:flutter/material.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

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
          child: Text('+200 ${AppLocalizations.of(context)!.ml}'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(300),
          child: Text('+300 ${AppLocalizations.of(context)!.ml}'),
        ),
        ElevatedButton(
          onPressed: () => onAddWater(500),
          child: Text('+500 ${AppLocalizations.of(context)!.ml}'),
        ),
      ],
    );
  }
} 