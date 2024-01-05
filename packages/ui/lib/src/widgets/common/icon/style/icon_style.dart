import 'package:flutter/material.dart';

class LMIconStyle {
  final Color? color;
  final double? size;
  final double? boxBorder;
  final double? boxBorderRadius;
  final double? boxPadding;
  final Color? backgroundColor;
  final BoxFit? fit;

  const LMIconStyle({
    this.backgroundColor,
    this.color,
    this.size,
    this.boxBorder,
    this.boxBorderRadius,
    this.boxPadding,
    this.fit,
  });

  LMIconStyle copyWith(LMIconStyle style) {
    return LMIconStyle(
      color: style.color ?? color,
      size: style.size ?? size,
      boxBorder: style.boxBorder ?? boxBorder,
      boxBorderRadius: style.boxBorderRadius ?? boxBorderRadius,
      boxPadding: style.boxPadding ?? boxPadding,
      backgroundColor: style.backgroundColor ?? backgroundColor,
      fit: style.fit ?? fit,
    );
  }

  factory LMIconStyle.inActivePreset() {
    return const LMIconStyle(
      color: Colors.black,
      size: 24,
      boxPadding: 0,
      fit: BoxFit.contain,
    );
  }

  factory LMIconStyle.activePreset() {
    return const LMIconStyle(
      color: Colors.red,
      size: 24,
      boxPadding: 0,
      fit: BoxFit.contain,
    );
  }
}
