import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
import 'package:likeminds_feed_flutter_core/src/views/activity/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/create_short_video/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/edit_short_video/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/notification/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/report/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/search/configurations/config.dart';
import 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/config.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
export 'package:likeminds_feed_flutter_core/src/views/activity/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/compose/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/create_short_video/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/edit_short_video/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/likes/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/media/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/notification/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/poll/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/report/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/search/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/post/configurations/config.dart';
export 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/config.dart';

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

  /// render video feed theme
  videoFeed,
}

/// {@template lm_feed_config}
/// Configuration class for Likeminds Feed
/// Holds configurations classes for each screen
/// {@endtemplate}
class LMFeedConfig {
  /// {@macro lm_feed_activity_screen_config}
  final LMFeedActivityScreenConfig activityScreenConfig;

  // check for import
  /// {@macro lm_compose_screen_config}
  final LMFeedComposeScreenConfig composeScreenConfig;

  final LMFeedCreateShortVideoConfig createShortVideoConfig;

  final LMFeedEditShortVideoConfig editShortVideoConfig;

  final LMFeedSocialScreenConfig socialFeedScreenConfig;

  final LMFeedQnaScreenConfig qnaFeedScreenConfig;

  final LMFeedVideoFeedScreenConfig videoFeedScreenConfig;

  /// {@macro lm_feedroom_screen_config}
  final LMFeedroomScreenConfig feedroomScreenConfig;

  /// {@macro lm_feed_like_screen_config}
  final LMFeedLikeScreenConfig likeScreenConfig;

  /// {@macro lm_feed_media_preview_screen_config}
  final LMFeedMediaPreviewScreenConfig mediaPreviewScreenConfig;

  /// {@macro lm_feed_notification_screen_config}
  final LMFeedNotificationScreenConfig notificationScreenConfig;

  /// {@macro lm_feed_poll_screen_config}
  final LMFeedPollScreenConfig pollScreenConfig;

  final LMFeedPendingPostsScreenConfig pendingPostScreenConfig;

  final LMFeedPostDetailScreenConfig postDetailScreenConfig;

  /// {@macro lm_feed_report_screen_config}
  final LMFeedReportScreenConfig reportScreenConfig;

  /// {@macro lm_feed_search_screen_config}
  final LMFeedSearchScreenConfig searchScreenConfig;

  /// {@macro lm_feed_topic_select_screen_config}
  final LMFeedTopicSelectScreenConfig topicSelectScreenConfig;

  /// {@macro lm_feed_web_configuration}
  final LMFeedWebConfiguration webConfiguration;

  /// feed theme type
  final LMFeedThemeType feedThemeType;

  /// {@macro lm_feed_widget_builder_delegate}
  final LMFeedWidgetBuilderDelegate widgetBuilderDelegate;

  /// [globalSystemOverlayStyle] is the system overlay style for the app.
  final SystemUiOverlayStyle? globalSystemOverlayStyle;

  /// {@macro lm_feed_config}
  LMFeedConfig({
    this.socialFeedScreenConfig = const LMFeedSocialScreenConfig(),
    this.qnaFeedScreenConfig = const LMFeedQnaScreenConfig(),
    this.videoFeedScreenConfig = const LMFeedVideoFeedScreenConfig(),
    this.postDetailScreenConfig = const LMFeedPostDetailScreenConfig(),
    this.pendingPostScreenConfig = const LMFeedPendingPostsScreenConfig(),
    this.feedroomScreenConfig = const LMFeedroomScreenConfig(),
    this.activityScreenConfig = const LMFeedActivityScreenConfig(),
    this.composeScreenConfig = const LMFeedComposeScreenConfig(),
    this.createShortVideoConfig = const LMFeedCreateShortVideoConfig(),
    this.editShortVideoConfig = const LMFeedEditShortVideoConfig(),
    this.likeScreenConfig = const LMFeedLikeScreenConfig(),
    this.mediaPreviewScreenConfig = const LMFeedMediaPreviewScreenConfig(),
    this.notificationScreenConfig = const LMFeedNotificationScreenConfig(),
    this.pollScreenConfig = const LMFeedPollScreenConfig(),
    this.reportScreenConfig = const LMFeedReportScreenConfig(),
    this.searchScreenConfig = const LMFeedSearchScreenConfig(),
    this.topicSelectScreenConfig = const LMFeedTopicSelectScreenConfig(),
    this.webConfiguration = const LMFeedWebConfiguration(),
    this.feedThemeType = LMFeedThemeType.social,
    this.widgetBuilderDelegate = const LMFeedWidgetBuilderDelegate(),
    this.globalSystemOverlayStyle,
  });
}
