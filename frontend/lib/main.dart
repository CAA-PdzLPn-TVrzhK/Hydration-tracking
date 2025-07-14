import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/app_theme.dart';
import 'package:hydration_tracker/core/theme/theme_provider.dart';
import 'package:hydration_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:hydration_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:hydration_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hydration_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hydration_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:hydration_tracker/core/services/notification_service.dart';
import 'package:hydration_tracker/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: HydrationTrackerApp(),
    ),
  );
}

class HydrationTrackerApp extends ConsumerWidget {
  const HydrationTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Hydration Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
