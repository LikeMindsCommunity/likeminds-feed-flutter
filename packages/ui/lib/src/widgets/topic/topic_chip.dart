import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

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
  // Action to perform after tapping on the topic chip icon
  final Function(LMTopicViewData)? onIconTap;
  // Action to perform after tapping on the topic chip
  final Function(BuildContext, LMTopicViewData)? onTap;
  // Required parameters
  final LMTopicViewData topic;

  final LMFeedTopicChipStyle? style;

  final bool isSelected;

  final LMFeedTextBuilder? textBuilder;

  const LMFeedTopicChip({
    super.key,
    required this.topic,
    this.style,
    this.onTap,
    this.onIconTap,
    this.textBuilder,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;

    LMFeedTopicChipStyle? style = this.style ??
        (isSelected
            ? feedTheme.topicStyle.activeChipStyle
            : feedTheme.topicStyle.inactiveChipStyle);

    LMFeedText topicText = LMFeedText(
      text: topic.name,
      style: LMFeedTextStyle(
        textStyle: style?.textStyle,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return InkWell(
      onTap: () {
        onTap?.call(context, topic);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin:
                style?.margin ?? const EdgeInsets.only(right: 8.0, bottom: 4.0),
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
                    ? InkWell(
                        onTap:
                            onIconTap != null ? () => onIconTap!(topic) : null,
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
                        ? Expanded(
                            child: textBuilder?.call(context, topicText) ??
                                topicText,
                          )
                        : textBuilder?.call(context, topicText) ?? topicText,
                style?.icon != null &&
                        style?.iconPlacement == LMFeedIconButtonPlacement.end
                    ? LikeMindsTheme.kHorizontalPaddingSmall
                    : const SizedBox(),
                style?.icon != null &&
                        style?.iconPlacement == LMFeedIconButtonPlacement.end
                    ? InkWell(
                        onTap:
                            onIconTap != null ? () => onIconTap!(topic) : null,
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
      ),
    );
  }

  LMFeedTopicChip copyWith({
    Function(LMTopicViewData)? onIconTap,
    LMTopicViewData? topic,
    LMFeedTopicChipStyle? style,
    bool? isSelected,
    Function(BuildContext, LMTopicViewData)? onTap,
    LMFeedTextBuilder? textBuilder,
  }) {
    return LMFeedTopicChip(
      onIconTap: onIconTap ?? this.onIconTap,
      topic: topic ?? this.topic,
      style: style ?? this.style,
      isSelected: isSelected ?? this.isSelected,
      onTap: onTap ?? this.onTap,
      textBuilder: textBuilder ?? this.textBuilder,
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

  factory LMFeedTopicChipStyle.active({Color? primaryColor}) =>
      LMFeedTopicChipStyle(
        backgroundColor: primaryColor?.withOpacity(0.1) ??
            LikeMindsTheme.primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        textStyle: TextStyle(
          color: primaryColor ?? LikeMindsTheme.primaryColor,
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
        borderRadius: BorderRadius.circular(4.0),
      );

  factory LMFeedTopicChipStyle.inActive({Color? primaryColor}) =>
      LMFeedTopicChipStyle(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        textStyle: TextStyle(
          color: primaryColor ?? LikeMindsTheme.primaryColor,
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
        borderRadius: BorderRadius.circular(4.0),
        showBorder: true,
        borderColor: primaryColor ?? LikeMindsTheme.primaryColor,
      );
}
