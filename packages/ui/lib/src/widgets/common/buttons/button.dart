import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/common/commons.dart';

// This widget is used to display a text button
// The [LMFeedButton] can be customized by passing in the required parameters
class LMFeedButton extends StatefulWidget {
  const LMFeedButton({
    super.key,
    this.text,
    required this.onTap,
    this.activeText,
    this.isActive = false,
    this.style,
    this.onTextTap,
  });

  /// Required parameter, defines whether the button is active or disabled
  final bool isActive;

  /// style class to customise the look and feel of the button
  final LMFeedButtonStyle? style;

  /// Text to be displayed in the button
  final LMFeedText? text;

  /// Action to perform after tapping on the button
  final Function() onTap;

  /// Text to be displayed in the button if the button is active
  final LMFeedText? activeText;

  final VoidCallback? onTextTap;

  @override
  State<LMFeedButton> createState() => _LMButtonState();

  LMFeedButton copyWith({
    bool? isActive,
    LMFeedButtonStyle? style,
    LMFeedText? text,
    Function()? onTap,
    LMFeedText? activeText,
    VoidCallback? onTextTap,
  }) {
    return LMFeedButton(
      isActive: isActive ?? this.isActive,
      style: style ?? this.style,
      text: text ?? this.text,
      onTap: onTap ?? this.onTap,
      activeText: activeText ?? this.activeText,
      onTextTap: onTextTap ?? this.onTextTap,
    );
  }
}

class _LMButtonState extends State<LMFeedButton> {
  bool _active = false;

  @override
  void initState() {
    _active = widget.isActive;
    super.initState();
  }

  @override
  void didUpdateWidget(LMFeedButton oldWidget) {
    _active = widget.isActive;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final inStyle = widget.style ?? LMFeedButtonStyle.basic();
    return GestureDetector(
      onTap: () {
        setState(() {
          _active = !_active;
        });
        widget.onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: inStyle.height,
        width: inStyle.width,
        padding: inStyle.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: inStyle.backgroundColor,
          borderRadius: BorderRadius.circular(inStyle.borderRadius ?? 0),
          border: inStyle.border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              inStyle.mainAxisAlignment ?? MainAxisAlignment.center,
          children: [
            inStyle.placement == LMFeedIconButtonPlacement.start
                ? _active
                    ? (inStyle.activeIcon ?? inStyle.icon) ??
                        const SizedBox.shrink()
                    : inStyle.icon ?? const SizedBox.shrink()
                : const SizedBox.shrink(),
            GestureDetector(
              onTap: inStyle.showText ? widget.onTextTap : null,
              behavior: HitTestBehavior.translucent,
              child: Row(
                children: [
                  inStyle.placement == LMFeedIconButtonPlacement.start
                      ? (inStyle.icon != null || inStyle.activeIcon != null)
                          ? SizedBox(width: inStyle.margin ?? 8)
                          : const SizedBox.shrink()
                      : const SizedBox.shrink(),
                  inStyle.showText
                      ? Container(
                          padding: inStyle.textPadding,
                          child: _active
                              ? widget.activeText ??
                                  widget.text ??
                                  const SizedBox.shrink()
                              : widget.text ?? const SizedBox.shrink())
                      : const SizedBox.shrink(),
                  inStyle.placement == LMFeedIconButtonPlacement.end
                      ? (inStyle.icon != null || inStyle.activeIcon != null)
                          ? SizedBox(width: inStyle.margin ?? 8)
                          : const SizedBox.shrink()
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            inStyle.placement == LMFeedIconButtonPlacement.end
                ? _active
                    ? inStyle.activeIcon ??
                        inStyle.icon ??
                        const SizedBox.shrink()
                    : inStyle.icon ?? const SizedBox.shrink()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class LMFeedButtonStyle {
  /// padding of the button, defaults to zero
  final EdgeInsets? padding;

  /// background color of the button, defaults to transparent
  final Color? backgroundColor;

  /// border radius of the button container
  final double? borderRadius;

  /// height of the button
  final double? height;

  /// width of the button
  final double? width;

  /// border of the button
  final Border? border;

  /// placement of the icon in the button
  final LMFeedIconButtonPlacement placement;

  /// axis alignment for setting button's icon and text spacing
  final MainAxisAlignment? mainAxisAlignment;

  /// margin between the text and icon
  final double? margin;

  final bool showText;

  /// Icon to be displayed in the button
  final LMFeedIcon? icon;

  /// Icon to be displayed in the button if the button is active
  final LMFeedIcon? activeIcon;

  final EdgeInsets? textPadding;

  const LMFeedButtonStyle({
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.width,
    this.placement = LMFeedIconButtonPlacement.start,
    this.margin,
    this.mainAxisAlignment,
    this.showText = true,
    this.icon,
    this.activeIcon,
    this.textPadding,
  });

  factory LMFeedButtonStyle.basic() {
    return const LMFeedButtonStyle(
      padding: EdgeInsets.all(4),
      backgroundColor: Colors.transparent,
      borderRadius: 8,
      height: 28,
      margin: 4,
      textPadding: EdgeInsets.zero,
    );
  }

  LMFeedButtonStyle copyWith({
    EdgeInsets? padding,
    Color? backgroundColor,
    Border? border,
    double? borderRadius,
    double? height,
    double? width,
    LMFeedIconButtonPlacement? placement,
    MainAxisAlignment? mainAxisAlignment,
    double? margin,
    bool? showText,
    LMFeedIcon? icon,
    LMFeedIcon? activeIcon,
    EdgeInsets? textPadding,
  }) {
    return LMFeedButtonStyle(
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      width: width ?? this.width,
      placement: placement ?? this.placement,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      margin: margin ?? this.margin,
      showText: showText ?? this.showText,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      textPadding: textPadding ?? this.textPadding,
    );
  }

  factory LMFeedButtonStyle.like({Color? primaryColor}) => LMFeedButtonStyle(
        padding: const EdgeInsets.only(right: 16.0),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeInActiveSvg,
          style: LMFeedIconStyle.basic(),
        ),
        height: 44,
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeActiveSvg,
          style: LMFeedIconStyle.basic().copyWith(
            color: primaryColor,
          ),
        ),
      );

  factory LMFeedButtonStyle.comment() => LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmCommentSvg,
          style: LMFeedIconStyle.basic(),
        ),
      );

  factory LMFeedButtonStyle.share() => LMFeedButtonStyle(
        showText: false,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmShareSvg,
          style: LMFeedIconStyle.basic(),
        ),
      );

  factory LMFeedButtonStyle.save({Color? primaryColor}) => LMFeedButtonStyle(
        showText: false,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmSaveInactiveSvg,
          style: LMFeedIconStyle.basic(),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmSaveActiveSvg,
          style: LMFeedIconStyle.basic().copyWith(
            color: primaryColor,
          ),
        ),
        padding: const EdgeInsets.only(right: 8.0),
      );

  factory LMFeedButtonStyle.repost({Color? primaryColor}) => LMFeedButtonStyle(
        padding: const EdgeInsets.only(right: 16.0),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmRepostSvg,
          style: LMFeedIconStyle.basic().copyWith(
            color: primaryColor,
          ),
        ),
        height: 44,
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmRepostSvg,
          style: LMFeedIconStyle.basic().copyWith(
            color: primaryColor,
          ),
        ),
      );
}
