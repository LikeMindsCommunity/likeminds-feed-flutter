import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/feed/feed_pending_post_banner.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post_something.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_social_screen_builder_delegate}
/// Builder delegate class for the Social screen.
/// it extends [LMFeedWidgetBuilderDelegate] and provides methods to override the default
/// widget builders for the Social screen.
/// {@endtemplate}
class LMFeedSocialScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_social_screen_builder_delegate}
  const LMFeedSocialScreenBuilderDelegate();

  /// Override this method to provide a custom pending post banner for the QnA screen.
  Widget pendingPostBannerBuilder(BuildContext context, int pendingPostCount,
      LMFeedPendingPostBanner pendingPostBanner) {
    return pendingPostBanner;
  }

  /// Override this method to provide a custom app bar for the QnA screen.
  PreferredSizeWidget appBarBuilder(BuildContext context, LMFeedAppBar appBar) {
    return appBar;
  }

  /// Builds a custom widget for the feed screen.
  Widget customWidgetBuilder(
      LMFeedPostSomething postSomethingWidget, BuildContext context) {
    return postSomethingWidget;
  }

  /// Builds a floating action button for the feed screen.
  Widget floatingActionButtonBuilder(
      BuildContext context, LMFeedButton floatingActionButton) {
    return floatingActionButton;
  }
}
