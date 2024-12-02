import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_search_screen_builder_delegate}
/// Builder delegate for Search Screen
/// Used to customise the Search Screen's Widgets
/// {@endtemplate}
class LMFeedSearchScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_search_screen_builder_delegate}
  const LMFeedSearchScreenBuilderDelegate();

  /// AppBar builder for the Search Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
    TextEditingController controller,
    ValueNotifier<bool> showClearButton,
    Function(String) onTextChanged,
  ) {
    return appBar;
  }
}
