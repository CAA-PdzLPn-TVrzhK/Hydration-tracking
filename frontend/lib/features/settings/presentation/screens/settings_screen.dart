import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/theme_provider.dart';
import 'package:hydration_tracker/core/services/api_service.dart';
import 'package:hydration_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:hydration_tracker/core/providers/language_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydration_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

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

          // Language
          Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(languageProvider);
              return ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Язык'),
                subtitle: Text(locale.languageCode == 'en' ? 'English' : 'Русский'),
                onTap: () {
                  _showLanguageDialog(context, ref);
                },
              );
            },
          ),

          const Divider(),

          // API Status
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Статус API'),
            subtitle: const Text('Проверить подключение'),
            onTap: () {
              _showApiStatusDialog(context);
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
              _showLogoutDialog(context, ref);
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

  void _showApiStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<bool>(
        future: ApiService().isBackendAvailable(),
        builder: (context, snapshot) {
          final isAvailable = snapshot.data ?? false;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          
          return AlertDialog(
            title: const Text('Статус API'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Проверка подключения...'),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.error,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAvailable ? 'API доступен' : 'API недоступен',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text('Платформа: ${ApiService().getPlatformInfo()}'),
                const SizedBox(height: 4),
                Text('Auth API: ${ApiService.baseUrl}'),
                const SizedBox(height: 4),
                Text('Hydration API: ${ApiService.hydrationBaseUrl}'),
                const SizedBox(height: 16),
                if (!isAvailable)
                  const Text(
                    'Убедитесь, что бэкенд запущен на портах 8081 и 8082',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final locale = ref.watch(languageProvider);
        return AlertDialog(
          title: const Text('Выберите язык'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                value: const Locale('ru'),
                groupValue: locale,
                title: const Text('Русский'),
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale>(
                value: const Locale('en'),
                groupValue: locale,
                title: const Text('English'),
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  testWidgets('Onboarding screen shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ru'),
        ],
        locale: const Locale('ru'), // или 'en', если тестируешь английский
        home: const OnboardingScreen(),
      ),
    );

    // Используй локализованный текст
    final welcomeText = AppLocalizations.of(tester.element(find.byType(OnboardingScreen)))!.welcome;
    expect(find.text(welcomeText), findsOneWidget);
  });
}
