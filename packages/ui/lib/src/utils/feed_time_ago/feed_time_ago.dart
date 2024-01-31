import 'package:likeminds_feed_flutter_ui/src/utils/feed_time_ago/lm_custom_time_ago_message.dart';

class LMFeedTimeAgo {
  LMFeedTimeAgoMessages? lmFeedTimeAgoMessages;

  static LMFeedTimeAgo? _instance;

  static LMFeedTimeAgo get instance => _instance ??= LMFeedTimeAgo._();

  LMFeedTimeAgo._();

  void setDefaultTimeFormat(LMFeedTimeAgoMessages locale) {
    lmFeedTimeAgoMessages = locale;
  }

  String format(DateTime date,
      {String? locale, DateTime? clock, bool allowFromNow = false}) {
    final allowFromNow0 = allowFromNow;

    final messages = lmFeedTimeAgoMessages ?? LMFeedTimeShortMessages();
    final clock0 = clock ?? DateTime.now();
    var elapsed = clock0.millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    String prefix, suffix;

    if (allowFromNow0 && elapsed < 0) {
      elapsed = date.isBefore(clock0) ? elapsed : elapsed.abs();
      prefix = messages.prefixFromNow();
      suffix = messages.suffixFromNow();
    } else {
      prefix = messages.prefixAgo();
      suffix = messages.suffixAgo();
    }

    final num seconds = elapsed / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;
    final num months = days / 30;
    final num years = days / 365;

    String result;
    if (seconds < 45) {
      result = messages.lessThanOneMinute(seconds.round(), date);
    } else if (seconds < 90) {
      result = messages.aboutAMinute(date);
    } else if (minutes < 45) {
      result = messages.minutes(minutes.round(), date);
    } else if (minutes < 90) {
      result = messages.aboutAnHour(date);
    } else if (hours < 24) {
      result = messages.hours(hours.round(), date);
    } else if (hours < 48) {
      result = messages.aDay(date);
    } else if (days < 30) {
      result = messages.days(days.round(), date);
    } else if (days < 60) {
      result = messages.aboutAMonth(date);
    } else if (days < 365) {
      result = messages.months(months.round(), date);
    } else if (years < 2) {
      result = messages.aboutAYear(date);
    } else {
      result = messages.years(years.round(), date);
    }

    return [prefix, result, suffix]
        .where((str) => str.isNotEmpty)
        .join(messages.wordSeparator());
  }
}
