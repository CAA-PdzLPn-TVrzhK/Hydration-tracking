import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Theme Settings
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Тема'),
            subtitle: Text(themeMode == ThemeMode.dark ? 'Тёмная' : 'Светлая'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),

          const Divider(),

          // Daily Goal
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Дневная цел'),
            subtitle: const Text('2000 мл'),
            onTap: () {
              _showGoalDialog(context);
            },
          ),

          const Divider(),

          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Уведомления'),
            subtitle: const Text('Напоминания о воде'),
            onTap: () {
              _showNotificationSettings(context);
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            subtitle: const Text('Личные данные'),
            onTap: () {
              _showProfileSettings(context);
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('О приложении'),
            subtitle: const Text('Версия 1.0.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Дневная цель'),
        content: const Text(
            'Функция настройки дневной цели будет добавлена в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уведомления'),
        content: const Text(
            'Настройки уведомлений будут добавлены в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProfileSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Профиль'),
        content: const Text(
            'Редактирование профиля будет добавлено в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hydration Tracker'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            SizedBox(height: 8),
            Text('Приложение для отслеживания потребления воды'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
