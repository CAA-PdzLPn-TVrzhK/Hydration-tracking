import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (!kIsWeb) {
      // tz.initializeTimeZones();
      // Инициализация для мобильных, если нужно
    }
    // Для web ничего не требуется
  }

  static Future<void> showAchievementNotification({
    required BuildContext context,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title\n$body')),
      );
    } else {
      // Здесь может быть реализация для мобильных через flutter_local_notifications
      // await _notifications.show(...);
    }
  }

  static Future<void> showGoalReachedNotification(BuildContext context) async {
    await showAchievementNotification(
      context: context,
      title: 'Goal Reached! 🎉',
      body: 'Congratulations! You\'ve reached your daily hydration goal.',
      payload: 'goal_reached',
    );
  }

  static Future<void> showStreakNotification(
      BuildContext context, int days) async {
    await showAchievementNotification(
      context: context,
      title: 'Streak! 🔥',
      body: 'You\'ve maintained your hydration goal for $days days!',
      payload: 'streak_$days',
    );
  }
}
