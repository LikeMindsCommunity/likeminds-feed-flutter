import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMButtonStyle {
  bool? showText;

  String? activeText;
  String? inactiveText;

  LMIcon? activeIcon;
  LMIcon? inactiveIcon;

  final bool? isActive;
  final double? margin;

  // Padding of the button, defaults to zero
  final EdgeInsets? padding;
  // Background color of the button, defaults to transparent
  final Color? backgroundColor;
  // Border radius of the button, required
  final double? borderRadius;
  final double? height;
  final double? width;
  final Border? border;
  // Placement of the icon in the button, required
  final LMIconPlacement? placement;

  LMButtonStyle({
    this.showText,
    this.activeText,
    this.inactiveText,
    this.activeIcon,
    this.inactiveIcon,
    this.isActive,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.height,
    this.width,
    this.border,
    this.placement,
  });
}
