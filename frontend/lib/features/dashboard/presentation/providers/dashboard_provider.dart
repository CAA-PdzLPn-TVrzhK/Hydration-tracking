import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardData>> {
  DashboardNotifier() : super(const AsyncValue.loading());

  void loadDashboardData() async {
    // Имитация загрузки данных
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(DashboardData.mock());
  }

  void addWaterIntake(int amount) {
    // Имитация добавления воды
    if (state.value != null) {
      final data = state.value!;
      state = AsyncValue.data(data.copyWith(
        todayIntake: data.todayIntake + amount,
        percentage: ((data.todayIntake + amount) * 100 ~/ data.dailyGoal).clamp(0, 100),
        recentEntries: [
          WaterEntry(amount: amount, type: 'вода', time: 'сейчас'),
          ...data.recentEntries
        ],
      ));
    }
  }
}

class DashboardData {
  final int todayIntake;
  final int dailyGoal;
  final int percentage;
  final int weeklyIntake;
  final int monthlyIntake;
  final List<dynamic> weeklyData;
  final List<WaterEntry> recentEntries;

  DashboardData({
    required this.todayIntake,
    required this.dailyGoal,
    required this.percentage,
    required this.weeklyIntake,
    required this.monthlyIntake,
    required this.weeklyData,
    required this.recentEntries,
  });

  DashboardData copyWith({
    int? todayIntake,
    int? dailyGoal,
    int? percentage,
    int? weeklyIntake,
    int? monthlyIntake,
    List<dynamic>? weeklyData,
    List<WaterEntry>? recentEntries,
  }) {
    return DashboardData(
      todayIntake: todayIntake ?? this.todayIntake,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      percentage: percentage ?? this.percentage,
      weeklyIntake: weeklyIntake ?? this.weeklyIntake,
      monthlyIntake: monthlyIntake ?? this.monthlyIntake,
      weeklyData: weeklyData ?? this.weeklyData,
      recentEntries: recentEntries ?? this.recentEntries,
    );
  }

  factory DashboardData.mock() {
    return DashboardData(
      todayIntake: 800,
      dailyGoal: 2000,
      percentage: 40,
      weeklyIntake: 3500,
      monthlyIntake: 12000,
      weeklyData: [500, 600, 700, 800, 900, 1000, 1200],
      recentEntries: [
        WaterEntry(amount: 300, type: 'вода', time: '10:00'),
        WaterEntry(amount: 200, type: 'чай', time: '09:00'),
      ],
    );
  }
}

class WaterEntry {
  final int amount;
  final String type;
  final String time;
  WaterEntry({required this.amount, required this.type, required this.time});
} 