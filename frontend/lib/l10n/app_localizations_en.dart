// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hydration Tracker';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get min6chars => 'Minimum 6 characters';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get haveAccount => 'Already have an account? Login';

  @override
  String get todayDrank => 'Today Drank';

  @override
  String drankOfGoal(Object current, Object goal) {
    return '$current ml of $goal ml';
  }

  @override
  String progress(Object percent) {
    return 'Progress: $percent%';
  }

  @override
  String percent(Object percent) {
    return '$percent%';
  }

  @override
  String get waterType => 'water';

  @override
  String get now => 'now';

  @override
  String minAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String hAgo(Object hours) {
    return '$hours h ago';
  }

  @override
  String get addWaterIntake => 'Add Water Intake';

  @override
  String get amountMl => 'Amount (ml)';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get apiStatus => 'API Status';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get ok => 'OK';

  @override
  String get start => 'Start';

  @override
  String get welcome => 'Welcome to Hydration Tracker!';

  @override
  String get onboardingDesc => 'Track your water balance, set goals and get reminders!';

  @override
  String get errorLoadingDashboard => 'Error loading dashboard';

  @override
  String get retry => 'Retry';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get recentEntries => 'Recent Entries';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get personalData => 'Personal Data';

  @override
  String get waterReminders => 'Water reminders';

  @override
  String get checkConnection => 'Check connection';

  @override
  String get version => 'Version';

  @override
  String get goalFeatureComingSoon => 'Daily goal feature will be added in the next update.';

  @override
  String get notificationsFeatureComingSoon => 'Notification settings will be added in the next update.';

  @override
  String get profileFeatureComingSoon => 'Profile editing will be added in the next update.';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get apiAvailable => 'API available';

  @override
  String get apiUnavailable => 'API unavailable';

  @override
  String get makeSureBackendRunning => 'Make sure the backend is running on ports 8081 and 8082';

  @override
  String get aboutAppDesc => 'An app for tracking your water intake';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get dashboardLoadError => 'Error loading dashboard';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get waterChartStub => 'Water chart (stub)';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get noAccountRegister => 'No account? Register';

  @override
  String get ml => 'ml';

  @override
  String platformInfo(Object platform) {
    return 'Platform: $platform';
  }

  @override
  String authApiInfo(Object url) {
    return 'Auth API: $url';
  }

  @override
  String hydrationApiInfo(Object url) {
    return 'Hydration API: $url';
  }

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get minutesAgo => 'min ago';

  @override
  String get hoursAgo => 'h ago';

  @override
  String get teaType => 'tea';
}
