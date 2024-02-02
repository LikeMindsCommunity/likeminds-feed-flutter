/// [LookupMessages] template for any language
abstract class LMFeedTimeAgoMessages {
  /// Example: `prefixAgo()` 1 min `suffixAgo()`
  String prefixAgo();

  /// Example: `prefixFromNow()` 1 min `suffixFromNow()`
  String prefixFromNow();

  /// Example: `prefixAgo()` 1 min `suffixAgo()`
  String suffixAgo();

  /// Example: `prefixFromNow()` 1 min `suffixFromNow()`
  String suffixFromNow();

  /// Format when time is less than a minute
  String lessThanOneMinute(int seconds, DateTime dateTime);

  /// Format when time is about a minute
  String aboutAMinute(DateTime dateTime);

  /// Format when time is in minutes
  String minutes(int minutes, DateTime dateTime);

  /// Format when time is about an hour
  String aboutAnHour(DateTime dateTime);

  /// Format when time is in hours
  String hours(int hours, DateTime dateTime);

  /// Format when time is a day
  String aDay(DateTime dateTime);

  /// Format when time is in days
  String days(int days, DateTime dateTime);

  /// Format when time is about a month
  String aboutAMonth(DateTime dateTime);

  /// Format when time is in months
  String months(int months, DateTime dateTime);

  /// Format when time is about a year
  String aboutAYear(DateTime dateTime);

  /// Format when time is about a year
  String years(int years, DateTime dateTime);

  /// word separator when words are concatenated
  String wordSeparator() => ' ';
}

/// English Messages
class LMFeedTimeMessages implements LMFeedTimeAgoMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'ago';
  @override
  String suffixFromNow() => 'from now';
  @override
  String lessThanOneMinute(int seconds, DateTime dateTime) => 'a moment';
  @override
  String aboutAMinute(DateTime dateTime) => 'a minute';
  @override
  String minutes(int minutes, DateTime dateTime) => '$minutes minutes';
  @override
  String aboutAnHour(DateTime dateTime) => 'about an hour';
  @override
  String hours(int hours, DateTime dateTime) => '$hours hours';
  @override
  String aDay(DateTime dateTime) => 'a day';
  @override
  String days(int days, DateTime dateTime) => '$days days';
  @override
  String aboutAMonth(DateTime dateTime) => 'about a month';
  @override
  String months(int months, DateTime dateTime) => '$months months';
  @override
  String aboutAYear(DateTime dateTime) => 'about a year';
  @override
  String years(int years, DateTime dateTime) => '$years years';
  @override
  String wordSeparator() => ' ';
}

/// English short Messages
class LMFeedTimeShortMessages implements LMFeedTimeAgoMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds, DateTime dateTime) => 'now';
  @override
  String aboutAMinute(DateTime dateTime) => '1m';
  @override
  String minutes(int minutes, DateTime dateTime) => '${minutes}m';
  @override
  String aboutAnHour(DateTime dateTime) => '~1h';
  @override
  String hours(int hours, DateTime dateTime) => '${hours}h';
  @override
  String aDay(DateTime dateTime) => '~1d';
  @override
  String days(int days, DateTime dateTime) => '${days}d';
  @override
  String aboutAMonth(DateTime dateTime) => '~1mo';
  @override
  String months(int months, DateTime dateTime) => '${months}mo';
  @override
  String aboutAYear(DateTime dateTime) => '~1y';
  @override
  String years(int years, DateTime dateTime) => '${years}y';
  @override
  String wordSeparator() => ' ';
}
