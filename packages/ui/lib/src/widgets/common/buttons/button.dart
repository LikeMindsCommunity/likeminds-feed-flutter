import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
export 'package:likeminds_feed_ui_fl/src/widgets/common/buttons/style/button_style.dart';

// This widget is used to display a text button
// The [LMButton] can be customized by passing in the required parameters
class LMButton extends StatelessWidget {
  const LMButton({
    super.key,
    this.icon,
    this.text,
    this.onTap,
    this.activeIcon,
    this.activeText,
    this.height,
    this.width,
    this.margin,
    this.isActive = false,
    this.padding,
    this.placement = LMIconPlacement.start,
    this.mainAxisAlignment,
    this.style,
  });

  // Required parameters, defines whether the button is active or disabled
  final bool isActive;
  final double? margin;
  // Icon to be displayed in the button
  final LMIcon? icon;
  // Text to be displayed in the button, [LMTextView] only
  final LMTextView? text;
  // Action to perform after tapping on the button
  final Function()? onTap;
  // Icon to be displayed in the button if the button is active
  final LMIcon? activeIcon;
  // Text to be displayed in the button if the button is active,
  // [LMTextView] only
  final LMTextView? activeText;
  // Padding of the button, defaults to zero
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  // Placement of the icon in the button, required
  final LMIconPlacement placement;
  final MainAxisAlignment? mainAxisAlignment;

  final LMButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onHover: style?.onHover,
      splashColor: style?.splashColor,
      focusColor: style?.focusColor,
      hoverColor: style?.hoverColor,
      enableFeedback: style?.enableFeedback,
      child: Container(
        height: height ?? 32,
        width: width,
        padding: padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: style?.backgroundColor ?? Colors.transparent,
          borderRadius: style?.borderRadius == null
              ? null
              : BorderRadius.circular(style!.borderRadius!),
          border: style?.border,
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          children: [
            placement == LMIconPlacement.start
                ? isActive
                    ? activeIcon ?? const SizedBox()
                    : icon ?? const SizedBox()
                : const SizedBox(),
            placement == LMIconPlacement.start
                ? (icon != null || activeIcon != null)
                    ? SizedBox(width: margin ?? 8)
                    : const SizedBox()
                : const SizedBox(),
            (style?.showText ?? true)
                ? isActive
                    ? activeText ?? text ?? const SizedBox()
                    : text ?? const SizedBox()
                : const SizedBox.shrink(),
            placement == LMIconPlacement.end
                ? (icon != null || activeIcon != null)
                    ? SizedBox(width: margin ?? 8)
                    : const SizedBox()
                : const SizedBox(),
            placement == LMIconPlacement.end
                ? isActive
                    ? activeIcon ?? const SizedBox()
                    : icon ?? const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  LMButton copyWith(LMButton button) {
    return LMButton(
      icon: button.icon ?? icon,
      text: button.text ?? text,
      onTap: button.onTap ?? onTap,
      activeIcon: button.activeIcon ?? activeIcon,
      activeText: button.activeText ?? activeText,
      height: button.height ?? height,
      width: button.width ?? width,
      margin: button.margin ?? margin,
      isActive: button.isActive,
      padding: button.padding ?? padding,
      placement: button.placement,
      mainAxisAlignment: button.mainAxisAlignment ?? mainAxisAlignment,
      style: button.style ?? style,
    );
  }
}
