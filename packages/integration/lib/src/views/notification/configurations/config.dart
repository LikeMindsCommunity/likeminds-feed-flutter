import 'package:likeminds_feed_flutter_core/src/views/notification/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/notification/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/notification/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/notification/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/notification/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/notification/configurations/style.dart';

/// {@template lm_feed_notification_screen_config}
/// Configuration class for Notification Screen
/// Holds configuration classes for Notification Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedNotificationScreenConfig {
  /// {@macro lm_feed_notification_screen_builder_delegate}
  final LMFeedNotificationScreenBuilderDelegate builder;

  /// {@macro lm_feed_notification_screen_setting}
  final LMFeedNotificationScreenSetting setting;

  /// {@macro lm_feed_notification_screen_style}
  final LMFeedNotificationScreenStyle style;

  /// {@macro lm_feed_notification_screen_config}
  const LMFeedNotificationScreenConfig({
    this.builder = const LMFeedNotificationScreenBuilderDelegate(),
    this.setting = const LMFeedNotificationScreenSetting(),
    this.style = const LMFeedNotificationScreenStyle(),
  });
}
