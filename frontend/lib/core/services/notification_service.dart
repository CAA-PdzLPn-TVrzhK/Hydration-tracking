import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter/material.dart'; // Для TimeOfDay, если потребуется

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // --- Методы с Time закомментированы, чтобы не было ошибок на web ---
  /*
  static Future<void> scheduleHydrationReminder({
    required Time time,
    required int id,
    required List<int> days,
    String? title,
    String? body,
  }) async {
    // ...
  }

  static tz.TZDateTime _nextInstanceOfTime(Time time, int dayOfWeek) {
    // ...
  }

  static Future<void> schedulePeriodicReminder({
    required Time startTime,
    required Time endTime,
    required int intervalMinutes,
  }) async {
    // ...
  }
  */
  // --- Конец блока ---

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showAchievementNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Hydration achievements and milestones',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showGoalReachedNotification() async {
    await showAchievementNotification(
      title: 'Goal Reached! 🎉',
      body: 'Congratulations! You\'ve reached your daily hydration goal.',
      payload: 'goal_reached',
    );
  }

  static Future<void> showStreakNotification(int days) async {
    await showAchievementNotification(
      title: 'Streak! 🔥',
      body: 'You\'ve maintained your hydration goal for $days days!',
      payload: 'streak_$days',
    );
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
} 