import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Tracker'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @min6chars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get min6chars;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get haveAccount;

  /// No description provided for @todayDrank.
  ///
  /// In en, this message translates to:
  /// **'Today Drank'**
  String get todayDrank;

  /// No description provided for @drankOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{current} ml of {goal} ml'**
  String drankOfGoal(Object current, Object goal);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String progress(Object percent);

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percent(Object percent);

  /// No description provided for @waterType.
  ///
  /// In en, this message translates to:
  /// **'water'**
  String get waterType;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minAgo(Object minutes);

  /// No description provided for @hAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hAgo(Object hours);

  /// No description provided for @addWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Add Water Intake'**
  String get addWaterIntake;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMl;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @apiStatus.
  ///
  /// In en, this message translates to:
  /// **'API Status'**
  String get apiStatus;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hydration Tracker!'**
  String get welcome;

  /// No description provided for @onboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your water balance, set goals and get reminders!'**
  String get onboardingDesc;

  /// No description provided for @errorLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard'**
  String get errorLoadingDashboard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent Entries'**
  String get recentEntries;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @waterReminders.
  ///
  /// In en, this message translates to:
  /// **'Water reminders'**
  String get waterReminders;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get checkConnection;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @goalFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Daily goal feature will be added in the next update.'**
  String get goalFeatureComingSoon;

  /// No description provided for @notificationsFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notification settings will be added in the next update.'**
  String get notificationsFeatureComingSoon;

  /// No description provided for @profileFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile editing will be added in the next update.'**
  String get profileFeatureComingSoon;

  /// No description provided for @checkingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking connection...'**
  String get checkingConnection;

  /// No description provided for @apiAvailable.
  ///
  /// In en, this message translates to:
  /// **'API available'**
  String get apiAvailable;

  /// No description provided for @apiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'API unavailable'**
  String get apiUnavailable;

  /// No description provided for @makeSureBackendRunning.
  ///
  /// In en, this message translates to:
  /// **'Make sure the backend is running on ports 8081 and 8082'**
  String get makeSureBackendRunning;

  /// No description provided for @aboutAppDesc.
  ///
  /// In en, this message translates to:
  /// **'An app for tracking your water intake'**
  String get aboutAppDesc;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard'**
  String get dashboardLoadError;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @waterChartStub.
  ///
  /// In en, this message translates to:
  /// **'Water chart (stub)'**
  String get waterChartStub;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @platformInfo.
  ///
  /// In en, this message translates to:
  /// **'Platform: {platform}'**
  String platformInfo(Object platform);

  /// No description provided for @authApiInfo.
  ///
  /// In en, this message translates to:
  /// **'Auth API: {url}'**
  String authApiInfo(Object url);

  /// No description provided for @hydrationApiInfo.
  ///
  /// In en, this message translates to:
  /// **'Hydration API: {url}'**
  String hydrationApiInfo(Object url);

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'min ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @teaType.
  ///
  /// In en, this message translates to:
  /// **'tea'**
  String get teaType;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
