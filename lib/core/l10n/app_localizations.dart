import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'world': 'World',
      'alarms': 'Alarms',
      'stopwatch': 'Stopwatch',
      'timer': 'Timer',
      'app_name': 'Vaclocks',
      'about': 'About',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'current_location': 'Current location',
      'new_alarm': 'New alarm',
      'morning': 'Morning',
      'evening': 'Evening',
      'pick_time': 'Pick time',
      'am': 'AM',
      'pm': 'PM',
      'one_time': 'One-time',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'add': 'Add',
      'cancel': 'Cancel',
      'start': 'Start',
      'stop': 'Stop',
      'reset': 'Reset',
      'lap': 'Lap',
      'resume': 'Resume',
      'pause': 'Pause',
      'timer_started': 'Timer started',
      'timer_finished': 'Timer finished',
      'hours_ahead': 'hours ahead',
      'hours_behind': 'hours behind',
      'hour_ahead': 'hour ahead',
      'hour_behind': 'hour behind',
      'tomorrow': 'Tomorrow',
      'alarm_ringing': 'Alarm ringing',
      'snooze_10_min': 'Snooze 10 min',
    },
    'ar': {
      'world': 'العالم',
      'alarms': 'المنبهات',
      'stopwatch': 'ساعة الإيقاف',
      'timer': 'المؤقت',
      'app_name': 'Vaclocks',
      'about': 'حول',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'current_location': 'الموقع الحالي',
      'new_alarm': 'منبه جديد',
      'morning': 'صباحًا',
      'evening': 'مساءً',
      'pick_time': 'اختر الوقت',
      'am': 'ص',
      'pm': 'م',
      'one_time': 'لمرة واحدة',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'add': 'إضافة',
      'cancel': 'إلغاء',
      'start': 'ابدأ',
      'stop': 'إيقاف',
      'reset': 'إعادة تعيين',
      'lap': 'دورة',
      'resume': 'استئناف',
      'pause': 'إيقاف مؤقت',
      'timer_started': 'تم بدء المؤقت',
      'timer_finished': 'انتهى المؤقت',
      'hours_ahead': 'ساعات متقدمة',
      'hours_behind': 'ساعات متأخرة',
      'hour_ahead': 'ساعة متقدمة',
      'hour_behind': 'ساعة متأخرة',
      'tomorrow': 'غدًا',
      'alarm_ringing': 'رنين المنبه',
      'snooze_10_min': 'غفوة 10 دقائق',
    },
  };

  String _t(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;

  String get world => _t('world');
  String get alarms => _t('alarms');
  String get stopwatch => _t('stopwatch');
  String get timer => _t('timer');
  String get appName => _t('app_name');
  String get about => _t('about');
  String get language => _t('language');
  String get english => _t('english');
  String get arabic => _t('arabic');
  String get currentLocation => _t('current_location');
  String get newAlarm => _t('new_alarm');
  String get morning => _t('morning');
  String get evening => _t('evening');
  String get pickTime => _t('pick_time');
  String get am => _t('am');
  String get pm => _t('pm');
  String get oneTime => _t('one_time');
  String get daily => _t('daily');
  String get weekly => _t('weekly');
  String get monthly => _t('monthly');
  String get add => _t('add');
  String get cancel => _t('cancel');
  String get start => _t('start');
  String get stop => _t('stop');
  String get reset => _t('reset');
  String get lap => _t('lap');
  String get resume => _t('resume');
  String get pause => _t('pause');
  String get timerStarted => _t('timer_started');
  String get timerFinished => _t('timer_finished');
  String get hoursAhead => _t('hours_ahead');
  String get hoursBehind => _t('hours_behind');
  String get hourAhead => _t('hour_ahead');
  String get hourBehind => _t('hour_behind');
  String get tomorrow => _t('tomorrow');
  String get alarmRinging => _t('alarm_ringing');
  String get snooze10Min => _t('snooze_10_min');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}


