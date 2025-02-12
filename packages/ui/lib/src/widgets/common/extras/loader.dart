import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';

class LMFeedLoader extends StatelessWidget {
  final bool isPrimary;
  final LMFeedLoaderStyle? style;

  const LMFeedLoader({
    super.key,
    this.isPrimary = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedLoaderStyle style =
        this.style ?? LMFeedTheme.instance.theme.loaderStyle;
    return Center(
      child: Padding(
        padding: style.padding ?? EdgeInsets.zero,
        child: SizedBox(
          height: style.height,
          width: style.width,
          child: CircularProgressIndicator.adaptive(
            backgroundColor: style.backgroundColor,
            strokeWidth: style.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              style.color ??
                  (isPrimary
                      ? LMFeedTheme.instance.theme.primaryColor
                      : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  LMFeedLoader copyWith({
    bool? isPrimary,
    LMFeedLoaderStyle? style,
  }) {
    return LMFeedLoader(
      isPrimary: isPrimary ?? this.isPrimary,
      style: style ?? this.style,
    );
  }
}

class LMFeedLoaderStyle {
  final Color? color;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final double strokeWidth;

  const LMFeedLoaderStyle({
    this.color,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding,
    this.strokeWidth = 4.0,
  });

  LMFeedLoaderStyle copyWith({
    Color? color,
    Color? backgroundColor,
    double? height,
    double? width,
    EdgeInsets? padding,
    double? strokeWidth,
  }) {
    return LMFeedLoaderStyle(
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
