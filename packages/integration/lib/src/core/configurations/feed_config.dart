import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/social/social_feed_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/feedroom_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/post_detail_screen.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
export 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/social/social_feed_screen.dart';
export 'package:likeminds_feed_flutter_core/src/views/post/post_detail_screen.dart';

/// enum to describe which type of feed to render
enum LMFeedType {
  /// render universal feed
  universal,

  /// render personalised feed
  personalised
}

/// enum to describe which feed theme to render
enum LMFeedThemeType {
  /// render social theme feed
  social,

  /// render qna theme feed
  qna,
}

/// {@template lm_feed_config}
/// Configuration class for Likeminds Feed
/// Holds configurations classes for each screen
/// {@endtemplate}
class LMFeedConfig {
  final LMFeedScreenConfig feedScreenConfig;
  final LMFeedComposeScreenConfig composeConfig;
  final LMPostDetailScreenConfig postDetailConfig;
  final LMFeedRoomScreenConfig feedRoomScreenConfig;
  final LMFeedWebConfiguration webConfiguration;
  final LMFeedThemeType feedThemeType;

  /// {@macro lm_feed_widget_builder_delegate}
  final LMFeedWidgetBuilderDelegate widgetBuilderDelegate;

  /// [globalSystemOverlayStyle] is the system overlay style for the app.
  final SystemUiOverlayStyle? globalSystemOverlayStyle;

  /// {@macro lm_feed_config}
  LMFeedConfig({
    this.feedScreenConfig = const LMFeedScreenConfig(),
    this.composeConfig = const LMFeedComposeScreenConfig(),
    this.postDetailConfig = const LMPostDetailScreenConfig(),
    this.feedRoomScreenConfig = const LMFeedRoomScreenConfig(),
    this.webConfiguration = const LMFeedWebConfiguration(),
    this.feedThemeType = LMFeedThemeType.social,
    this.widgetBuilderDelegate = const LMFeedWidgetBuilderDelegate(),
    this.globalSystemOverlayStyle,
  });
}
