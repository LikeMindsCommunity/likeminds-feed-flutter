import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

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
        backgroundColor: style?.chipColor,
        borderColor: style?.borderColor,
        borderRadius: style?.borderRadius,
        borderWidth: style?.borderWidth,
        height: style?.height,
        icon: style?.icon,
        iconPlacement: style?.iconPlacement ?? LMFeedIconButtonPlacement.end,
        margin: style?.chipMargin,
        onIconTap: style?.onIconTap,
        padding: style?.chipPadding,
        showBorder: style?.showBorder ?? false,
        textStyle: style?.textStyle,
      );
}

class LMFeedPostTopicStyle {
  final Color? backgroundColor;
  final Color? chipColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final double? height;
  final Widget? icon;
  final LMFeedIconButtonPlacement iconPlacement;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final EdgeInsets? chipPadding;
  final EdgeInsets? chipMargin;
  final bool showBorder;
  final TextStyle? textStyle;
  final Function(LMTopicViewData)? onIconTap;

  const LMFeedPostTopicStyle({
    this.backgroundColor,
    this.chipColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.height,
    this.icon,
    this.iconPlacement = LMFeedIconButtonPlacement.end,
    this.margin,
    this.padding,
    this.showBorder = false,
    this.textStyle,
    this.onIconTap,
    this.chipPadding,
    this.chipMargin,
  });
}
