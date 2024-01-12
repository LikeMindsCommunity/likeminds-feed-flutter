import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

/*
* Topic chip widget
* This widget is used to display a topic chip
* A topic chip is a chip that displays a topic name and an icon
* The icon can be placed before or after the topic name
* The icon can be tapped to perform an action
* The topic chip can be customized by passing in the required parameters
* and can be used in a list of chips
*/
class LMFeedTopicChip extends StatelessWidget {
  // Action to perform after tapping on the topic chip
  final Function(LMTopicViewData)? onIconTap;
  // Required parameters
  final LMTopicViewData topic;

  final LMFeedTopicChipStyle? style;

  const LMFeedTopicChip({
    Key? key,
    required this.topic,
    this.style,
    this.onIconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    Widget topicText = LMFeedText(
      text: topic.name,
      style: LMFeedTextStyle(
        textStyle: style?.textStyle,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: style?.margin ?? const EdgeInsets.only(right: 8.0),
          alignment: Alignment.center,
          height: style?.height,
          padding: style?.padding ??
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            borderRadius: style?.borderRadius ?? BorderRadius.circular(5.0),
            border: (style?.showBorder ?? false)
                ? Border.all(
                    color: style?.borderColor ?? Colors.transparent,
                    width: style?.borderWidth ?? 1,
                  )
                : null,
            color: style?.backgroundColor ?? Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              style?.icon != null &&
                      style?.iconPlacement == LMFeedIconButtonPlacement.start
                  ? GestureDetector(
                      onTap: onIconTap != null ? () => onIconTap!(topic) : null,
                      child: Container(
                        color: Colors.transparent,
                        child: style?.icon,
                      ),
                    )
                  : const SizedBox(),
              style?.icon != null &&
                      style?.iconPlacement == LMFeedIconButtonPlacement.start
                  ? LikeMindsTheme.kHorizontalPaddingSmall
                  : const SizedBox(),
              topic.name.isEmpty
                  ? const SizedBox()
                  : (style?.gripChip ?? false)
                      ? Expanded(child: topicText)
                      : topicText,
              style?.icon != null &&
                      style?.iconPlacement == LMFeedIconButtonPlacement.end
                  ? LikeMindsTheme.kHorizontalPaddingSmall
                  : const SizedBox(),
              style?.icon != null &&
                      style?.iconPlacement == LMFeedIconButtonPlacement.end
                  ? GestureDetector(
                      onTap: onIconTap != null ? () => onIconTap!(topic) : null,
                      child: Container(
                        color: Colors.transparent,
                        child: style?.icon,
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ],
    );
  }
}

class LMFeedTopicChipStyle {
// background color of the topic chip defaults to transparent
  final Color? backgroundColor;
  // border color of the topic chip defaults to null
  final Color? borderColor;
  // border radius of the topic chip defaults to 5.0
  final BorderRadius? borderRadius;
  // showBorder must be true, border width of the topic chip defaults to 1.0
  final double? borderWidth;
  // Whether to show a border around the topic chip
  // defaults to false
  final bool showBorder;
  // Text style of the topic chip
  final TextStyle? textStyle;
  // Icon to be displayed in the topic chip
  final Widget? icon;
  // Padding of the topic chip
  final EdgeInsets? padding;
  // Whether to place the icon before the text
  // or after the text of the topic chip
  // LMIconPlacement.start places the icon before the text
  // LMIconPlacement.end places the icon after the text
  final LMFeedIconButtonPlacement iconPlacement;
  final double? height;
  final EdgeInsets? margin;
  final bool gripChip;

  const LMFeedTopicChipStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.showBorder = false,
    this.textStyle,
    this.icon,
    this.padding,
    this.iconPlacement = LMFeedIconButtonPlacement.end,
    this.height,
    this.margin,
    this.gripChip = false,
  });

  LMFeedTopicChipStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    double? borderWidth,
    bool? showBorder,
    TextStyle? textStyle,
    Widget? icon,
    EdgeInsets? padding,
    LMFeedIconButtonPlacement? iconPlacement,
    double? height,
    EdgeInsets? margin,
    bool? gripChip,
  }) {
    return LMFeedTopicChipStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      showBorder: showBorder ?? this.showBorder,
      textStyle: textStyle ?? this.textStyle,
      icon: icon ?? this.icon,
      padding: padding ?? this.padding,
      iconPlacement: iconPlacement ?? this.iconPlacement,
      height: height ?? this.height,
      margin: margin ?? this.margin,
      gripChip: gripChip ?? this.gripChip,
    );
  }
}
