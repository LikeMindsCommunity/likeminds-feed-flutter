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
    this.isToggleEnabled = true,
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

  /// [bool] to determine if the button should toogle
  /// between active and inactive states
  /// defaults to true
  final bool isToggleEnabled;

  @override
  State<LMFeedButton> createState() => _LMButtonState();

  LMFeedButton copyWith({
    bool? isActive,
    LMFeedButtonStyle? style,
    LMFeedText? text,
    Function()? onTap,
    LMFeedText? activeText,
    VoidCallback? onTextTap,
    bool? isToggleEnabled,
  }) {
    return LMFeedButton(
      isActive: isActive ?? this.isActive,
      style: style ?? this.style,
      text: text ?? this.text,
      onTap: onTap ?? this.onTap,
      activeText: activeText ?? this.activeText,
      onTextTap: onTextTap ?? this.onTextTap,
      isToggleEnabled: isToggleEnabled ?? this.isToggleEnabled,
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
    final inStyle = widget.style ?? const LMFeedButtonStyle.basic();
    return InkWell(
      onTap: () {
        if (widget.isToggleEnabled) {
          setState(() {
            _active = !_active;
          });
        }
        widget.onTap();
      },
      splashFactory: InkRipple.splashFactory,
      child: Container(
        height: inStyle.height,
        width: inStyle.width,
        margin: inStyle.margin ?? EdgeInsets.zero,
        padding: inStyle.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: inStyle.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(inStyle.borderRadius ?? 0),
          border: inStyle.border,
          boxShadow: inStyle.boxShadow,
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
                          ? SizedBox(width: inStyle.gap ?? 8)
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
                          ? SizedBox(width: inStyle.gap ?? 8)
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

  /// gap between the text and icon
  final double? gap;

  /// margin of the button
  final EdgeInsets? margin;

  final bool showText;

  /// Icon to be displayed in the button
  final LMFeedIcon? icon;

  /// Icon to be displayed in the button if the button is active
  final LMFeedIcon? activeIcon;

  final EdgeInsets? textPadding;

  final List<BoxShadow>? boxShadow; 

  const LMFeedButtonStyle({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.width,
    this.placement = LMFeedIconButtonPlacement.start,
    this.gap,
    this.mainAxisAlignment,
    this.showText = true,
    this.icon,
    this.activeIcon,
    this.textPadding,
    this.boxShadow,
  });

  const factory LMFeedButtonStyle.basic() = LMFeedButtonStyle._;

  const LMFeedButtonStyle._({
    this.padding = const EdgeInsets.all(4.0),
    this.margin,
    this.backgroundColor = Colors.transparent,
    this.border,
    this.borderRadius = 8.0,
    this.height = 28.0,
    this.width,
    this.placement = LMFeedIconButtonPlacement.start,
    this.mainAxisAlignment,
    this.gap = 4.0,
    this.showText = true,
    this.icon,
    this.activeIcon,
    this.textPadding = EdgeInsets.zero,
    this.boxShadow,
  });

  LMFeedButtonStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Border? border,
    double? borderRadius,
    double? height,
    double? width,
    LMFeedIconButtonPlacement? placement,
    MainAxisAlignment? mainAxisAlignment,
    double? gap,
    bool? showText,
    LMFeedIcon? icon,
    LMFeedIcon? activeIcon,
    EdgeInsets? textPadding,
    List<BoxShadow>? boxShadow,
  }) {
    return LMFeedButtonStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      width: width ?? this.width,
      placement: placement ?? this.placement,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      gap: gap ?? this.gap,
      showText: showText ?? this.showText,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      textPadding: textPadding ?? this.textPadding,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }

  factory LMFeedButtonStyle.like({Color? primaryColor}) => LMFeedButtonStyle(
        padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeInActiveSvg,
          style: LMFeedIconStyle.basic(),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeActiveSvg,
          style: LMFeedIconStyle.basic().copyWith(
            color: primaryColor,
          ),
        ),
      );

  factory LMFeedButtonStyle.comment() => LMFeedButtonStyle(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmCommentSvg,
          style: LMFeedIconStyle.basic(),
        ),
      );

  factory LMFeedButtonStyle.share() => LMFeedButtonStyle(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
      );

  factory LMFeedButtonStyle.repost({Color? primaryColor}) => LMFeedButtonStyle(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
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
