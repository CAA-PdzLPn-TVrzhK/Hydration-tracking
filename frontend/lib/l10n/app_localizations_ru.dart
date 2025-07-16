// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Hydration Tracker';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Повторите пароль';

  @override
  String get enterUsername => 'Введите имя пользователя';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get min6chars => 'Минимум 6 символов';

  @override
  String get noAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get haveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get todayDrank => 'Сегодня выпито';

  @override
  String get progress => 'Прогресс';

  @override
  String get addWaterIntake => 'Добавить воду';

  @override
  String get amountMl => 'Количество (мл)';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get settings => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get dailyGoal => 'Дневная цель';

  @override
  String get profile => 'Профиль';

  @override
  String get apiStatus => 'Статус API';

  @override
  String get about => 'О приложении';

  @override
  String get logout => 'Выйти';

  @override
  String get language => 'Язык';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'Английский';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get ok => 'OK';

  @override
  String get start => 'Начать';

  @override
  String get welcome => 'Добро пожаловать в Hydration Tracker!';

  @override
  String get onboardingDesc => 'Следите за своим водным балансом, ставьте цели и получайте напоминания!';

  @override
  String get errorLoadingDashboard => 'Ошибка загрузки дашборда';

  @override
  String get retry => 'Повторить';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get recentEntries => 'Последние записи';

  @override
  String get noEntriesYet => 'Записей пока нет';
}
