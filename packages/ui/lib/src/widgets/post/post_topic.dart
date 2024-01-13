import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedPostTopic extends StatelessWidget {
  final LMPostViewData post;
  final Map<String, LMTopicViewData> topics;

  final Widget Function(BuildContext, LMFeedTopicChip)? topicChipBuilder;

  final LMFeedPostTopicStyle? style;

  const LMFeedPostTopic({
    super.key,
    required this.post,
    required this.topics,
    this.topicChipBuilder,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: style?.margin,
      padding: style?.padding,
      child: Wrap(
        children: post.topics
            .map((e) =>
                topicChipBuilder?.call(context, defTopicChip(topics[e]!)) ??
                defTopicChip(topics[e]!))
            .toList(),
      ),
    );
  }

  LMFeedTopicChip defTopicChip(LMTopicViewData topicViewData) =>
      LMFeedTopicChip(
        topic: topicViewData,
        style: style?.activeChipStyle,
      );
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
}
