import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/app_theme.dart';
import 'package:hydration_tracker/core/theme/theme_provider.dart';
import 'package:hydration_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:hydration_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:hydration_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hydration_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:hydration_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:hydration_tracker/core/services/storage_service.dart';
import 'package:hydration_tracker/core/services/api_service.dart';
import 'package:hydration_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydration_tracker/core/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.initialize();
  await ApiService().initialize();

  runApp(
    const ProviderScope(
      child: HydrationTrackerApp(),
    ),
  );
}

class HydrationTrackerApp extends ConsumerStatefulWidget {
  const HydrationTrackerApp({super.key});

  @override
  ConsumerState<HydrationTrackerApp> createState() => _HydrationTrackerAppState();
}

class _HydrationTrackerAppState extends ConsumerState<HydrationTrackerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Hydration Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildHomeScreen(authState),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      locale: ref.watch(languageProvider),
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  Widget _buildHomeScreen(AuthState authState) {
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const DashboardScreen();
    }

    return const OnboardingScreen();
  }
}
