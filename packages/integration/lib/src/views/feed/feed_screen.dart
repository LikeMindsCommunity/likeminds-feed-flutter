import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

@Deprecated('Use [LMFeedSocialScreen()] instead for default feed screen, This [LMFeedScreen] will be removed from version 1.14.0')
class LMFeedScreen extends StatefulWidget {
  const LMFeedScreen({
    super.key,
    this.feedType = LMFeedType.universal,
    this.appBar,
    this.customWidgetBuilder,
    this.topicChipBuilder,
    this.postBuilder,
    this.floatingActionButtonBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.pendingPostBannerBuilder,
    this.topicBarBuilder,
    this.floatingActionButtonLocation,
    this.config,
  });

  /// [LMFeedType] for the feed.
  /// It can be [LMFeedType.personalised] or [LMFeedType.universal]
  /// Default is [LMFeedType.universal]
  final LMFeedType feedType;

  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBar;

  /// Builder for custom widget on top
  final LMFeedCustomWidgetBuilder? customWidgetBuilder;
  // Builder for topic chip [Button]
  final Widget Function(BuildContext context, List<LMTopicViewData>? topic)?
      topicChipBuilder;

  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // Floating action button
  // i.e. new post button
  final LMFeedContextButtonBuilder? floatingActionButtonBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;
  // Builder for error view while loading a new page
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;
  // Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  // Builder for pending post banner on feed screen above post list
  final Widget Function(BuildContext context, int noOfPendingPost)?
      pendingPostBannerBuilder;

  final LMFeedTopicBarBuilder? topicBarBuilder;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final LMFeedScreenConfig? config;

  @override
  State<LMFeedScreen> createState() => _LMFeedScreenState();
}

class _LMFeedScreenState extends State<LMFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildFeed();
  }

  Widget _buildFeed() {
    return widget.feedType == LMFeedType.universal
        ? _buildUniversalFeed()
        : _buildPersonalisedFeed();
  }

  Widget _buildUniversalFeed() {
    return LMFeedSocialUniversalScreen(
      appBar: widget.appBar,
      customWidgetBuilder: widget.customWidgetBuilder,
      topicChipBuilder: widget.topicChipBuilder,
      postBuilder: widget.postBuilder,
      floatingActionButtonBuilder: widget.floatingActionButtonBuilder,
      noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
      firstPageProgressIndicatorBuilder:
          widget.firstPageProgressIndicatorBuilder,
      newPageProgressIndicatorBuilder: widget.newPageProgressIndicatorBuilder,
      noMoreItemsIndicatorBuilder: widget.noMoreItemsIndicatorBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorIndicatorBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorIndicatorBuilder,
      pendingPostBannerBuilder: widget.pendingPostBannerBuilder,
      topicBarBuilder: widget.topicBarBuilder,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      config: widget.config,
    );
  }

  Widget _buildPersonalisedFeed() {
    return LMFeedSocialPersonalisedScreen(
      appBar: widget.appBar,
      customWidgetBuilder: widget.customWidgetBuilder,
      postBuilder: widget.postBuilder,
      floatingActionButtonBuilder: widget.floatingActionButtonBuilder,
      noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
      firstPageProgressIndicatorBuilder:
          widget.firstPageProgressIndicatorBuilder,
      newPageProgressIndicatorBuilder: widget.newPageProgressIndicatorBuilder,
      noMoreItemsIndicatorBuilder: widget.noMoreItemsIndicatorBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorIndicatorBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorIndicatorBuilder,
      pendingPostBannerBuilder: widget.pendingPostBannerBuilder,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      config: widget.config,
    );
  }
}
