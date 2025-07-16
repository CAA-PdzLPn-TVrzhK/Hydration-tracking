import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/theme/theme_provider.dart';
import 'package:hydration_tracker/core/services/api_service.dart';
import 'package:hydration_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:hydration_tracker/core/providers/language_provider.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
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
            title: Text(AppLocalizations.of(context)!.theme),
            subtitle: Text(themeMode == ThemeMode.dark ? AppLocalizations.of(context)!.dark : AppLocalizations.of(context)!.light),
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
            title: Text(AppLocalizations.of(context)!.dailyGoal),
            subtitle: Text('2000 ${AppLocalizations.of(context)!.ml}'),
            onTap: () {
              _showGoalDialog(context);
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.profile),
            subtitle: Text(AppLocalizations.of(context)!.personalData),
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
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text(locale.languageCode == 'en'
                    ? AppLocalizations.of(context)!.english
                    : AppLocalizations.of(context)!.russian),
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
            title: Text(AppLocalizations.of(context)!.apiStatus),
            subtitle: Text(AppLocalizations.of(context)!.checkConnection),
            onTap: () {
              _showApiStatusDialog(context);
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            subtitle: Text('${AppLocalizations.of(context)!.version} 1.0.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.red)),
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
        title: Text(AppLocalizations.of(context)!.dailyGoal),
        content: Text(AppLocalizations.of(context)!.goalFeatureComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showProfileSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.profile),
        content: Text(AppLocalizations.of(context)!.profileFeatureComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
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
            title: Text(AppLocalizations.of(context)!.apiStatus),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.checkingConnection),
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
                        isAvailable ? AppLocalizations.of(context)!.apiAvailable : AppLocalizations.of(context)!.apiUnavailable,
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.platformInfo(ApiService().getPlatformInfo())),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.authApiInfo(ApiService.baseUrl)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.hydrationApiInfo(ApiService.hydrationBaseUrl)),
                const SizedBox(height: 16),
                if (!isAvailable)
                  Text(
                    AppLocalizations.of(context)!.makeSureBackendRunning,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok),
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
        title: Text(AppLocalizations.of(context)!.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.appTitle),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.version}: 1.0.0'),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.aboutAppDesc),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.red)),
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
          title: Text(AppLocalizations.of(context)!.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                value: const Locale('ru'),
                groupValue: locale,
                title: Text(AppLocalizations.of(context)!.russian),
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale>(
                value: const Locale('en'),
                groupValue: locale,
                title: Text(AppLocalizations.of(context)!.english),
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }
}
