import 'package:likeminds_feed_flutter_core/src/views/media/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/media/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/media/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/media/configurations/style.dart';

/// {@template lm_feed_media_preview_screen_config}
/// Configuration class for MediaPreview Screen
/// Holds configuration classes for MediaPreview Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedMediaPreviewScreenConfig {
  /// {@macro lm_feed_media_preview_screen_builder_delegate}
  final LMFeedMediaPreviewScreenBuilderDelegate builder;

  /// {@macro lm_feed_media_preview_screen_setting}
  final LMFeedMediaPreviewScreenSetting setting;

  /// {@macro lm_feed_media_preview_screen_style}
  final LMFeedMediaPreviewScreenStyle style;

  /// {@macro lm_feed_media_preview_screen_config}
  LMFeedMediaPreviewScreenConfig({
    this.builder = const LMFeedMediaPreviewScreenBuilderDelegate(),
    this.setting = const LMFeedMediaPreviewScreenSetting(),
    this.style = const LMFeedMediaPreviewScreenStyle(),
  });
}
