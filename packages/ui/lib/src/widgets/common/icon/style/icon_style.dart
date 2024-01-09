import 'package:flutter/material.dart';

class LMFeedIconStyle {
  final Color? color;
  final double? size;
  final double? boxBorder;
  final double? boxBorderRadius;
  final double? boxPadding;
  final Color? backgroundColor;
  final BoxFit? fit;

  const LMFeedIconStyle({
    this.backgroundColor,
    this.color,
    this.size,
    this.boxBorder,
    this.boxBorderRadius,
    this.boxPadding,
    this.fit,
  });

  LMFeedIconStyle copyWith(LMFeedIconStyle style) {
    return LMFeedIconStyle(
      color: style.color ?? color,
      size: style.size ?? size,
      boxBorder: style.boxBorder ?? boxBorder,
      boxBorderRadius: style.boxBorderRadius ?? boxBorderRadius,
      boxPadding: style.boxPadding ?? boxPadding,
      backgroundColor: style.backgroundColor ?? backgroundColor,
      fit: style.fit ?? fit,
    );
  }

  factory LMFeedIconStyle.inActivePreset() {
    return const LMFeedIconStyle(
      color: Colors.black,
      size: 24,
      boxPadding: 0,
      fit: BoxFit.contain,
    );
  }

  factory LMFeedIconStyle.activePreset() {
    return const LMFeedIconStyle(
      color: Colors.red,
      size: 24,
      boxPadding: 0,
      fit: BoxFit.contain,
    );
  }
}
