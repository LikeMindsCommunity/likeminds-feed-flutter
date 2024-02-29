import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedTopicBar extends StatelessWidget {
  final List<LMTopicViewData> selectedTopics;
  final VoidCallback openTopicSelector;
  final Function(LMTopicViewData)? removeTopicFromSelection;
  final LMFeedTopicBarStyle? style;

  const LMFeedTopicBar({
    super.key,
    required this.selectedTopics,
    required this.openTopicSelector,
    this.removeTopicFromSelection,
    this.style,
  });

  LMFeedTopicBar copyWith({
    List<LMTopicViewData>? selectedTopics,
    VoidCallback? openTopicSelector,
    Function(LMTopicViewData)? removeTopicFromSelection,
    LMFeedTopicBarStyle? style,
  }) {
    return LMFeedTopicBar(
      selectedTopics: selectedTopics ?? this.selectedTopics,
      openTopicSelector: openTopicSelector ?? this.openTopicSelector,
      removeTopicFromSelection:
          removeTopicFromSelection ?? this.removeTopicFromSelection,
      style: style ?? this.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedTheme.instance.theme;
    return Container(
      width: style?.width,
      decoration: BoxDecoration(
        color: style?.backgroundColor ?? feedThemeData.container,
        border: style?.border,
        borderRadius: style?.borderRadius,
        boxShadow: style?.boxShadow,
      ),
      margin: style?.margin,
      padding: style?.padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: GestureDetector(
        onTap: openTopicSelector,
        child: Row(
          children: [
            selectedTopics.isEmpty
                ? LMFeedTopicChip(
                    topic: (LMTopicViewDataBuilder()
                          ..id("0")
                          ..isEnabled(true)
                          ..name(style?.topicChipText ?? "All Topic"))
                        .build(),
                    style: style?.topicChipStyle ??
                        feedThemeData.topicStyle.inactiveChipStyle,
                    isSelected: false,
                  )
                : selectedTopics.length == 1
                    ? LMFeedTopicChip(
                        topic: (LMTopicViewDataBuilder()
                              ..id(selectedTopics.first.id)
                              ..isEnabled(selectedTopics.first.isEnabled)
                              ..name(selectedTopics.first.name))
                            .build(),
                        style: feedThemeData.topicStyle.activeChipStyle,
                        isSelected: false,
                      )
                    : LMFeedTopicChip(
                        topic: (LMTopicViewDataBuilder()
                              ..id("0")
                              ..isEnabled(true)
                              ..name("Topics"))
                            .build(),
                        isSelected: false,
                        style:
                            feedThemeData.topicStyle.activeChipStyle?.copyWith(
                          icon: Row(
                            children: [
                              LikeMindsTheme.kHorizontalPaddingXSmall,
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                child: LMFeedText(
                                  text: selectedTopics.length.toString(),
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      color: feedThemeData.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              LikeMindsTheme.kHorizontalPaddingSmall,
                              LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: CupertinoIcons.chevron_down,
                                style: LMFeedIconStyle(
                                  size: 16,
                                  color: feedThemeData.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class LMFeedTopicBarStyle {
  final Color? backgroundColor;

  final EdgeInsets? padding;
  final EdgeInsets? margin;

  final List<BoxShadow>? boxShadow;

  final Border? border;
  final BorderRadius? borderRadius;

  final double? height;
  final double? width;
  final String? topicChipText;
  final LMFeedTopicChipStyle? topicChipStyle;

  const LMFeedTopicBarStyle({
    this.backgroundColor,
    this.padding,
    this.border,
    this.borderRadius,
    this.margin,
    this.boxShadow,
    this.height,
    this.width,
    this.topicChipText,
    this.topicChipStyle,
  });

  LMFeedTopicBarStyle copyWith({
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? boxShadow,
    Border? border,
    BorderRadius? borderRadius,
    double? height,
    double? width,
    String? topicChipText,
    LMFeedTopicChipStyle? topicChipStyle,
  }) {
    return LMFeedTopicBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      margin: margin ?? this.margin,
      height: height ?? this.height,
      width: width ?? this.width,
      topicChipText: topicChipText ?? this.topicChipText,
      topicChipStyle: topicChipStyle ?? this.topicChipStyle,
    );
  }
}
