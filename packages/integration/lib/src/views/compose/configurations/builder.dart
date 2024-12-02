import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_compose_screen_builder_delegate}
/// Builder delegate for Compose Screen
/// Used to customise the Compose Screen's Widgets
/// {@endtemplate}
class LMFeedComposeScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_compose_screen_builder_delegate}
  const LMFeedComposeScreenBuilderDelegate();

  /// app bar builder
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar oldAppBar,
    LMResponse<void> Function() onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  ) {
    return oldAppBar;
  }

  /// Builds the user header for the compose screen.
  Widget composeScreenUserHeaderBuilder(
      BuildContext context, LMUserViewData user, LMFeedUserTile userTile) {
    return userTile;
  }

  /// Builds the topic selector for the compose screen.
  Widget composeScreenTopicSelectorBuilder(BuildContext context,
      Widget topicSelector, List<LMTopicViewData> selectedTopics) {
    return topicSelector;
  }

  /// Builds the heading text field for the compose screen.
  Widget composeScreenHeadingTextfieldBuilder(
      BuildContext context, TextField headingTextField) {
    return headingTextField;
  }

  /// Builds the content text field for the compose screen.
  Widget composeScreenContentTextfieldBuilder(
      BuildContext context, LMTaggingAheadTextField contentTextField) {
    return contentTextField;
  }
}
