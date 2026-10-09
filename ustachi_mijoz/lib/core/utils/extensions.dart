import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/uikit/registan_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

extension Localization on BuildContext {
  MediaQueryData get queryData => MediaQuery.of(this);

  double get viewPaddingBottom => MediaQuery.of(this).viewPadding.bottom;

  double get viewPaddingTop => MediaQuery.of(this).viewPadding.top;

  Size get screenSize => MediaQuery.of(this).size;

  void popUntil(String path, [Object? returnValue]) {
    final router = AutoRouter.of(this);
    router.popUntil((route) {
      final routeName = route.settings.name ?? '';
      return routeName == path || routeName.endsWith(path);
    });
  }

  Future<T?> pushRouteSafe<T extends Object?>(PageRouteInfo route) {
    return AutoRouter.of(this).push<T>(route);
  }

  void maybePopSafe<T extends Object?>([T? result]) {
    if (AutoRouter.of(this).canPop()) {
      AutoRouter.of(this).maybePop(result);
    } else if (kDebugMode) {
      debugPrint('Router stack can not pop.');
    }
  }

  OpenTypographies get text {
    final text = Theme.of(this).extension<OpenTypographies>();

    return text ??
        OpenTypographies.fromColors(
            LightNeutralColor(), LightUncategorizedColor());
  }

  OpenColors get color {
    final color = Theme.of(this).extension<OpenColors>();

    return color ?? OpenColors.light;
  }
}

extension StringExt on String {
  bool get isEmail => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(this);

  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]}_${match[2]}',
    ).toLowerCase();
  }
}

extension PhoneX on String {
  String get digitsOnly => replaceAll(RegExp(r'\D'), '');

  String get backendPhone {
    final d = digitsOnly;
    return d.startsWith('998') ? d.substring(3) : d;
  }

  String get normalizedPhoneNumber {
    final d = digitsOnly;
    if (d.isEmpty) {
      return '';
    }
    if (d.startsWith('998') && d.length == 12) {
      return '+$d';
    }
    if (d.length == 9) {
      return '+998$d';
    }
    if (d.startsWith('0') && d.length == 10) {
      return '+998${d.substring(1)}';
    }
    return startsWith('+') ? this : '+$d';
  }

  String get maskedPhoneNumber {
    final normalized = normalizedPhoneNumber;
    if (normalized.length < 13) {
      return normalized;
    }

    return '${normalized.substring(0, 4)} ${normalized.substring(4, 6)} '
        '${normalized.substring(6, 9)} ${normalized.substring(9, 11)} '
        '${normalized.substring(11, 13)}';
  }
}

extension SvgPictureExt on SvgPicture {
  SvgPicture copyWith(
      {Color? color, double? width, final double? height, BoxFit? fit}) {
    final colorFilter =
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;
    return SvgPicture(
      bytesLoader,
      colorFilter: colorFilter ?? this.colorFilter,
      width: width ?? this.width,
      height: height ?? this.height,
      fit: fit ?? this.fit,
    );
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

extension DateTimeExt on DateTime {
  String get formatDate {
    return "${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year";
  }

  String get formatDateTime {
    return "${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year, ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String get formatTime {
    final hours = hour.toString().padLeft(2, '0');
    final minutes = minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String get formatDateWithDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(year, month, day);
    final locale = LocaleSettings.currentLocale.languageCode;

    if (targetDate == today) {
      final todayText = _getLocalizedString('today', locale);
      return "$todayText, ${DateFormat('dd MMMM', locale).format(this)}";
    } else if (targetDate == today.add(Duration(days: 1))) {
      final tomorrowText = _getLocalizedString('tomorrow', locale);
      return "$tomorrowText, ${DateFormat('dd MMMM', locale).format(this)}";
    } else {
      final weekdayName = _getWeekdayName(weekday, locale);
      return "$weekdayName, ${DateFormat('dd MMMM', locale).format(this)}";
    }
  }

  String _getLocalizedString(String key, String locale) {
    final strings = {
      'today': {
        'uz': 'Bugun',
        'ru': 'Сегодня',
        'en': 'Today',
      },
      'tomorrow': {
        'uz': 'Ertaga',
        'ru': 'Завтра',
        'en': 'Tomorrow',
      },
    };

    return strings[key]?[locale] ?? strings[key]?['en'] ?? '';
  }

  String _getWeekdayName(int weekday, String locale) {
    final weekdaysMap = {
      'uz': [
        'Yakshanba',
        'Dushanba',
        'Seshanba',
        'Chorshanba',
        'Payshanba',
        'Juma',
        'Shanba',
      ],
      'ru': [
        'Воскресенье',
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
      ],
      'en': [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
    };

    final weekdays = weekdaysMap[locale] ?? weekdaysMap['en']!;
    return weekdays[weekday % 7];
  }

  String get formatDateForApi {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  String get formatTimeForApi {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}.${millisecond.toString().padLeft(3, '0')}";
  }
}
