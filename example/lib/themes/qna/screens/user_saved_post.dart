import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';


class LMFeedSavedPostScreen extends StatefulWidget {
  const LMFeedSavedPostScreen({
    super.key,
    this.appBarBuilder,
    this.postBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
  });

  final LMFeedPostAppBarBuilder? appBarBuilder;
  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;

  /// Builder for the first page error indicator
  /// {@macro error_indicator_builder}
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  /// Builder for the first page progress indicator
  /// {@macro progress_indicator_builder}
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;

  /// Builder for the new page error indicator
  /// {@macro error_indicator_builder}
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;

  /// Builder for the new page progress indicator
  /// {@macro progress_indicator_builder}
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;

  /// Builder for the no items found indicator
  /// {@macro no_items_found_indicator_builder}
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;

  /// Builder for the no more items indicator
  /// {@macro no_more_items_indicator_builder}
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;

  @override
  State<LMFeedSavedPostScreen> createState() => _LMFeedSavedPostScreenState();
}

class _LMFeedSavedPostScreenState extends State<LMFeedSavedPostScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  final LMFeedThemeData _theme = LMFeedCore.theme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _theme.backgroundColor,
      appBar: widget.appBarBuilder?.call(context, _defAppBar()) ?? _defAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _defCustomWidget(context),
          Expanded(
            child: LMFeedSavedPostListView(
              postBuilder: widget.postBuilder,
              firstPageErrorIndicatorBuilder:
                  widget.firstPageErrorIndicatorBuilder,
              firstPageProgressIndicatorBuilder:
                  widget.firstPageProgressIndicatorBuilder,
              newPageErrorIndicatorBuilder: widget.newPageErrorIndicatorBuilder,
              newPageProgressIndicatorBuilder:
                  widget.newPageProgressIndicatorBuilder,
              noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
              noMoreItemsIndicatorBuilder: widget.noMoreItemsIndicatorBuilder,
            ),
          ),
        ],
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: _theme.container,
        border: const Border(),
        padding: EdgeInsets.zero,
      ),
      leading: BackButton(
        color: _theme.onContainer,
      ),
    );
  }

  Widget _defCustomWidget(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: _theme.container,
      width: width,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: LMFeedText(
        text: 'Saved $postTitleFirstCap',
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
