import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedPostTopic extends StatelessWidget {
  final LMPostViewData post;
  final List<LMTopicViewData> topics;
  final Function(BuildContext, LMTopicViewData)? onTopicTap;

  final Widget Function(BuildContext, LMFeedTopicChip)? topicChipBuilder;

  final LMFeedPostTopicStyle? style;

  const LMFeedPostTopic({
    super.key,
    required this.post,
    required this.topics,
    this.topicChipBuilder,
    this.onTopicTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedPostTopicStyle topicStyle =
        style ?? LMFeedTheme.instance.theme.topicStyle;
    return Container(
      margin: topicStyle.margin,
      padding: topicStyle.padding,
      child: Wrap(
        children: post.topics
            .map((e) =>
                topicChipBuilder?.call(context, defTopicChip(e, topicStyle)) ??
                defTopicChip(e, topicStyle))
            .toList(),
      ),
    );
  }

  LMFeedTopicChip defTopicChip(
          LMTopicViewData topicViewData, LMFeedPostTopicStyle topicStyle) =>
      LMFeedTopicChip(
        topic: topicViewData,
        style: topicStyle.activeChipStyle,
        onTap: onTopicTap,
        isSelected: true,
      );

  LMFeedPostTopic copyWith({
    LMPostViewData? post,
    List<LMTopicViewData>? topics,
    Widget Function(BuildContext, LMFeedTopicChip)? topicChipBuilder,
    LMFeedPostTopicStyle? style,
    Function(BuildContext, LMTopicViewData)? onTopicTap,
  }) {
    return LMFeedPostTopic(
      post: post ?? this.post,
      topics: topics ?? this.topics,
      topicChipBuilder: topicChipBuilder ?? this.topicChipBuilder,
      style: style ?? this.style,
      onTopicTap: onTopicTap ?? this.onTopicTap,
    );
  }
}

class LMFeedPostTopicStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final LMFeedTopicChipStyle? activeChipStyle;
  final LMFeedTopicChipStyle? inactiveChipStyle;

  const LMFeedPostTopicStyle({
    this.margin,
    this.padding,
    this.activeChipStyle,
    this.inactiveChipStyle,
  });

  LMFeedPostTopicStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    LMFeedTopicChipStyle? activeChipStyle,
    LMFeedTopicChipStyle? inactiveChipStyle,
  }) {
    return LMFeedPostTopicStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      activeChipStyle: activeChipStyle ?? this.activeChipStyle,
      inactiveChipStyle: inactiveChipStyle ?? this.inactiveChipStyle,
    );
  }

  factory LMFeedPostTopicStyle.basic({Color? primaryColor}) =>
      LMFeedPostTopicStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        activeChipStyle: LMFeedTopicChipStyle.active(
          primaryColor: primaryColor,
        ),
        inactiveChipStyle: LMFeedTopicChipStyle.inActive(
          primaryColor: primaryColor,
        ),
      );
}
