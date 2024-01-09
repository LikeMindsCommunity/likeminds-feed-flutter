import 'package:flutter/material.dart';

class LMFeedTile extends StatelessWidget {
  const LMFeedTile({
    super.key,
    this.onTap,
    this.style,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final Function()? onTap;
  final LMFeedTileStyle? style;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Either pick the passed style or the default style
    final inStyle = style ?? LMFeedTileStyle.basic();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: inStyle.backgroundColor,
          border: inStyle.border,
          borderRadius: BorderRadius.all(
            Radius.circular(inStyle.borderRadius ?? 0),
          ),
        ),
        padding: inStyle.padding ?? const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment:
              inStyle.mainAxisAlignment ?? MainAxisAlignment.start,
          children: [
            leading ??
                Container(
                  color: Colors.grey,
                )
          ],
        ),
      ),
    );
  }
}

class LMFeedTileStyle {
  /// background color of the tile, defaults to transparent
  final Color? backgroundColor;

  /// border around the tile
  final Border? border;

  /// border radius of the tile, visible when bgColor is passed
  final double? borderRadius;

  /// main axis alignment for the row inside the tile
  final MainAxisAlignment? mainAxisAlignment;

  /// padding from exterior bounds (borders)
  final EdgeInsets? padding;

  const LMFeedTileStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.mainAxisAlignment,
    this.padding,
  });

  LMFeedTileStyle copyWith({
    Color? backgroundColor,
    Border? border,
    double? borderRadius,
    MainAxisAlignment? mainAxisAlignment,
    EdgeInsets? padding,
  }) {
    return LMFeedTileStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      padding: padding ?? this.padding,
    );
  }

  factory LMFeedTileStyle.basic() {
    return const LMFeedTileStyle(
      backgroundColor: Colors.transparent,
      borderRadius: 0,
      mainAxisAlignment: MainAxisAlignment.start,
      padding: EdgeInsets.all(12),
    );
  }
}
