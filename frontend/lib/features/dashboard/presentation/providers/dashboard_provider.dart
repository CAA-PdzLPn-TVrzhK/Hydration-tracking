import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/services/api_service.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardData>> {
  DashboardNotifier() : super(const AsyncValue.loading());

  final ApiService _apiService = ApiService();

  Future<void> loadDashboardData() async {
    try {
      state = const AsyncValue.loading();
      
      // Check if backend is available first
      final isAvailable = await _apiService.isBackendAvailable();
      if (!isAvailable) {
        // Use mock data if backend is not available
        state = AsyncValue.data(DashboardData.mock());
        return;
      }
      
      // Load stats and entries in parallel
      final statsFuture = _apiService.getHydrationStats();
      final entriesFuture = _apiService.getHydrationEntries();
      
      final results = await Future.wait([statsFuture, entriesFuture]);
      final stats = results[0] as Map<String, dynamic>;
      final entries = results[1] as List<Map<String, dynamic>>;
      
      // Convert entries to WaterEntry objects
      final waterEntries = entries.map((entry) => WaterEntry(
        amount: entry['amount'] as int,
        type: entry['type'] as String,
        time: _formatTime(DateTime.parse(entry['timestamp'] as String)),
      )).toList();
      
      // Generate weekly data (mock for now)
      final weeklyData = _generateWeeklyData(stats['total_week'] as int? ?? 0);
      
      final data = DashboardData(
        todayIntake: stats['total_today'] as int? ?? 0,
        dailyGoal: stats['goal'] as int? ?? 2000,
        percentage: stats['goal_percentage'] as int? ?? 0,
        weeklyIntake: stats['total_week'] as int? ?? 0,
        monthlyIntake: stats['total_month'] as int? ?? 0,
        weeklyData: weeklyData,
        recentEntries: waterEntries,
      );
      
      state = AsyncValue.data(data);
    } catch (error) {
      // If API fails, use mock data and log error
      state = AsyncValue.data(DashboardData.mock());
    }
  }

  Future<void> addWaterIntake(int amount) async {
    try {
      // Add to API
      await _apiService.createHydrationEntry(
        amount: amount,
        type: 'water',
      );
      
      // Reload data
      await loadDashboardData();
    } catch (error) {
      // If API fails, update local state
      if (state.value != null) {
        final data = state.value!;
        state = AsyncValue.data(data.copyWith(
          todayIntake: data.todayIntake + amount,
          percentage: ((data.todayIntake + amount) * 100 ~/ data.dailyGoal).clamp(0, 100),
          recentEntries: [
            WaterEntry(amount: amount, type: 'water', time: 'now'),
            ...data.recentEntries
          ],
        ));
      }
    }
  }

  Future<void> updateDailyGoal(int goal) async {
    try {
      await _apiService.updateDailyGoal(goal);
      await loadDashboardData();
    } catch (error) {
      // Handle error
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  List<int> _generateWeeklyData(int totalWeek) {
    // Generate mock weekly data based on total
    final baseAmount = totalWeek ~/ 7;
    return List.generate(7, (index) => baseAmount + (index * 50));
  }
}

class DashboardData {
  final int todayIntake;
  final int dailyGoal;
  final int percentage;
  final int weeklyIntake;
  final int monthlyIntake;
  final List<int> weeklyData;
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
    List<int>? weeklyData,
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
        WaterEntry(amount: 300, type: 'water', time: '10:00'),
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