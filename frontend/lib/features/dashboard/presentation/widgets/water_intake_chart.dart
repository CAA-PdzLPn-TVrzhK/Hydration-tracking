import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

class WaterIntakeChart extends StatelessWidget {
  final List<dynamic> data;
  const WaterIntakeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    const daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const daysRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final days = locale == 'ru' ? daysRu : daysEn;
    final maxY = data.isEmpty
        ? 1000
        : ((data.cast<num>().reduce((a, b) => a > b ? a : b) * 1.2) / 100)
                .ceil() *
            100;
    const minY = 0;
    final yStep = (maxY / 4).ceil();
    final mlUnit = AppLocalizations.of(context)!.ml;
    return Container(
      height: 220,
      padding: const EdgeInsets.only(left: 32, right: 8, top: 8, bottom: 8),
      child: data.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.waterChartStub))
          : LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true, horizontalInterval: yStep.toDouble()),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yStep.toDouble(),
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) => SizedBox(
                        width: 80,
                        child: Text(
                          '${value.toInt()} $mlUnit',
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            days[index],
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY.toDouble(),
                maxY: maxY.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < data.length; i++)
                        FlSpot(i.toDouble(), (data[i] as num).toDouble()),
                    ],
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary
                            .withAlpha((0.15 * 255).toInt())),
                  ),
                ],
              ),
            ),
    );
  }
}
