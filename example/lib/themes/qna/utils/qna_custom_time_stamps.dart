import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// English short Messages
class LMQnACustomTimeStamps implements LMFeedTimeAgoMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'ago';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds, DateTime dateTime) =>
      '${seconds.abs()}s';
  @override
  String aboutAMinute(DateTime dateTime) => '1m';
  @override
  String minutes(int minutes, DateTime dateTime) => '${minutes}m';
  @override
  String aboutAnHour(DateTime dateTime) => '1h';
  @override
  String hours(int hours, DateTime dateTime) => '${hours}h';
  @override
  String aDay(DateTime dateTime) => '1d';
  @override
  String days(int days, DateTime dateTime) => '${days}d';
  @override
  String aboutAMonth(DateTime dateTime) => '1mo';
  @override
  String months(int months, DateTime dateTime) => '${months}mo';
  @override
  String aboutAYear(DateTime dateTime) => '1y';
  @override
  String years(int years, DateTime dateTime) => '${years}y';
  @override
  String wordSeparator() => ' ';
}
