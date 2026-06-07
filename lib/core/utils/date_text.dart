import '../localization/app_localizations.dart';

class DateText {
  static const _monthsEs = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _monthsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _weekdaysEs = <String>[
    'lun',
    'mar',
    'mie',
    'jue',
    'vie',
    'sab',
    'dom',
  ];

  static const _weekdaysEn = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String dayChip(DateTime date, AppLanguage language) {
    final local = date.toLocal();
    final weekdays = language == AppLanguage.es ? _weekdaysEs : _weekdaysEn;
    return '${weekdays[local.weekday - 1]}\n${local.day}';
  }

  static String matchDate(DateTime date, AppLanguage language) {
    final local = date.toLocal();
    final months = language == AppLanguage.es ? _monthsEs : _monthsEn;
    final weekdays = language == AppLanguage.es ? _weekdaysEs : _weekdaysEn;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${weekdays[local.weekday - 1]}, ${local.day} ${months[local.month - 1]} - $hour:$minute';
  }

  static String shortDate(DateTime date, AppLanguage language) {
    final local = date.toLocal();
    final months = language == AppLanguage.es ? _monthsEs : _monthsEn;
    return '${local.day} ${months[local.month - 1]}';
  }
}
