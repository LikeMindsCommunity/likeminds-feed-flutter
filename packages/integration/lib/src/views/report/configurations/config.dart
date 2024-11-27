import 'package:likeminds_feed_flutter_core/src/views/report/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/report/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/report/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/report/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/report/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/report/configurations/style.dart';

/// {@template lm_feed_report_screen_config}
/// Configuration class for Report Screen
/// Holds configuration classes for Report Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedReportScreenConfig {
  /// {@macro lm_feed_report_screen_builder_delegate}
  final LMFeedReportScreenBuilderDelegate builder;

  /// {@macro lm_feed_report_screen_setting}
  final LMFeedReportScreenSetting setting;

  /// {@macro lm_feed_report_screen_style}
  final LMFeedReportScreenStyle style;

  /// {@macro lm_feed_report_screen_config}
  const LMFeedReportScreenConfig({
    this.builder = const LMFeedReportScreenBuilderDelegate(),
    this.setting = const LMFeedReportScreenSetting(),
    this.style = const LMFeedReportScreenStyle(),
  });
}
