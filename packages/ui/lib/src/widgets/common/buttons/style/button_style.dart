import 'package:flutter/material.dart';

class LMButtonStyle {
  bool? showText;

  final Color? backgroundColor;
  // Border radius of the button, required
  final double? borderRadius;
  final Border? border;

  final void Function(bool)? onHover;
  final Color? splashColor;
  final Color? focusColor;
  final Color? hoverColor;
  final bool enableFeedback;

  LMButtonStyle({
    this.showText,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.enableFeedback = true,
    this.focusColor,
    this.hoverColor,
    this.onHover,
    this.splashColor,
  });

  LMButtonStyle copyWith(LMButtonStyle style) {
    return LMButtonStyle(
      showText: style.showText ?? showText,
      backgroundColor: style.backgroundColor ?? backgroundColor,
      borderRadius: style.borderRadius ?? borderRadius,
      border: style.border ?? border,
      enableFeedback: style.enableFeedback,
      focusColor: style.focusColor ?? focusColor,
      hoverColor: style.hoverColor ?? hoverColor,
      onHover: style.onHover ?? onHover,
      splashColor: style.splashColor ?? splashColor,
    );
  }
}
