import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/app_theme.dart';
import 'package:hydration_tracker/features/dashboard/presentation/widgets/hydration_card.dart';
import 'package:hydration_tracker/features/dashboard/presentation/widgets/quick_add_buttons.dart';
import 'package:hydration_tracker/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:hydration_tracker/features/dashboard/presentation/widgets/water_intake_chart.dart';
import 'package:hydration_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: dashboardState.when(
        data: (data) => _buildDashboardContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.dashboardLoadError,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(dashboardProvider.notifier).loadDashboardData();
                },
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWaterDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardContent(dynamic data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardProvider.notifier).loadDashboardData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Progress Card
            HydrationCard(
              currentAmount: data.todayIntake,
              goalAmount: data.dailyGoal,
              percentage: data.percentage,
            ),

            const SizedBox(height: 24),

            // Quick Add Buttons
            QuickAddButtons(
              onAddWater: (amount) {
                ref.read(dashboardProvider.notifier).addWaterIntake(amount);
              },
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: AppLocalizations.of(context)!.thisWeek,
                    value: '${data.weeklyIntake}ml',
                    icon: Icons.calendar_today,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatsCard(
                    title: AppLocalizations.of(context)!.thisMonth,
                    value: '${data.monthlyIntake}ml',
                    icon: Icons.calendar_month,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Water Intake Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.weeklyProgress,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: WaterIntakeChart(data: data.weeklyData),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Entries
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recentEntries,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (data.recentEntries.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.noEntriesYet,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recentEntries.length,
                        itemBuilder: (context, index) {
                          final entry = data.recentEntries[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryBlue.withAlpha((0.1 * 255).toInt()),
                              child: const Icon(
                                Icons.water_drop,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            title: Text('${entry.amount}ml'),
                            subtitle: Text(_localizedDrinkType(context, entry.type)),
                            trailing: Text(_localizedEntryTime(context, entry.time)),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWaterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addWaterIntake),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amountMl,
                hintText: '250',
              ),
              onSubmitted: (value) {
                final amount = int.tryParse(value);
                if (amount != null && amount > 0) {
                  ref.read(dashboardProvider.notifier).addWaterIntake(amount);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle add water logic
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }
}

String _localizedDrinkType(BuildContext context, String type) {
  switch (type.toLowerCase()) {
    case 'water':
    case 'вода':
      return AppLocalizations.of(context)!.waterType;
    case 'tea':
    case 'чай':
      return AppLocalizations.of(context)!.teaType;
    default:
      return type;
  }
}

String _localizedEntryTime(BuildContext context, String time) {
  if (time == 'now' || time == 'сейчас') {
    return AppLocalizations.of(context)!.now;
  }
  if (time.endsWith('min ago') || time.endsWith('мин назад')) {
    final num = RegExp(r'\d+').stringMatch(time) ?? '';
    return AppLocalizations.of(context)!.minAgo(num);
  }
  if (time.endsWith('h ago') || time.endsWith('ч назад')) {
    final num = RegExp(r'\d+').stringMatch(time) ?? '';
    return AppLocalizations.of(context)!.hAgo(num);
  }
  return time;
}
