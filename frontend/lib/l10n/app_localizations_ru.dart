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
  String drankOfGoal(Object current, Object goal) {
    return '$current мл из $goal мл';
  }

  @override
  String progress(Object percent) {
    return 'Прогресс: $percent%';
  }

  @override
  String percent(Object percent) {
    return '$percent%';
  }

  @override
  String get waterType => 'вода';

  @override
  String get now => 'сейчас';

  @override
  String minAgo(Object minutes) {
    return '$minutes мин назад';
  }

  @override
  String hAgo(Object hours) {
    return '$hours ч назад';
  }

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
  String get notifications => 'Уведомления';

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

  @override
  String get personalData => 'Личные данные';

  @override
  String get waterReminders => 'Напоминания о воде';

  @override
  String get checkConnection => 'Проверить подключение';

  @override
  String get version => 'Версия';

  @override
  String get goalFeatureComingSoon => 'Функция настройки дневной цели будет добавлена в следующем обновлении.';

  @override
  String get notificationsFeatureComingSoon => 'Настройки уведомлений будут добавлены в следующем обновлении.';

  @override
  String get profileFeatureComingSoon => 'Редактирование профиля будет добавлено в следующем обновлении.';

  @override
  String get checkingConnection => 'Проверка подключения...';

  @override
  String get apiAvailable => 'API доступен';

  @override
  String get apiUnavailable => 'API недоступен';

  @override
  String get makeSureBackendRunning => 'Убедитесь, что бэкенд запущен на портах 8081 и 8082';

  @override
  String get aboutAppDesc => 'Приложение для отслеживания потребления воды';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get dashboardLoadError => 'Ошибка загрузки дашборда';

  @override
  String get weeklyProgress => 'Прогресс за неделю';

  @override
  String get waterChartStub => 'График воды (заглушка)';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get passwordsDontMatch => 'Пароли не совпадают';

  @override
  String get alreadyHaveAccountLogin => 'Уже есть аккаунт? Войти';

  @override
  String get noAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get ml => 'мл';

  @override
  String platformInfo(Object platform) {
    return 'Платформа: $platform';
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
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get minutesAgo => 'мин назад';

  @override
  String get hoursAgo => 'ч назад';

  @override
  String get teaType => 'чай';
}
