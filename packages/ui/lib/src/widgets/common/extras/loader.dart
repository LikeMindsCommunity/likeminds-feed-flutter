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
    LMFeedLoaderStyle style = this.style ?? LMFeedTheme.of(context).loaderStyle;
    return Center(
      child: CircularProgressIndicator.adaptive(
        backgroundColor: style.backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          style.color ??
              (isPrimary ? LMFeedTheme.of(context).primaryColor : Colors.white),
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

  const LMFeedLoaderStyle({
    this.color,
    this.backgroundColor,
  });

  LMFeedLoaderStyle copyWith({
    Color? color,
    Color? backgroundColor,
  }) {
    return LMFeedLoaderStyle(
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
