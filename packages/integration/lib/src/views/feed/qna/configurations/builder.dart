import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/index.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_qna_screen_builder_delegate}
/// Builder delegate class for the QnA screen.
/// it extends [LMFeedWidgetBuilderDelegate] and provides methods to override the default
/// widget builders for the QnA screen.
/// {@endtemplate}
class LMFeedQnaScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_qna_screen_builder_delegate}
  const LMFeedQnaScreenBuilderDelegate();

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
