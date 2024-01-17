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

  final VoidCallback? onTap;
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
        height: inStyle.height,
        width: inStyle.width,
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
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
            SizedBox(width: inStyle.margin ?? 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title ??
                      Container(
                        height: 14,
                        width: 120,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                      ),
                  subtitle ?? const SizedBox(),
                ],
              ),
            ),
            trailing ?? const SizedBox()
          ],
        ),
      ),
    );
  }

  LMFeedTile copyWith(
    Function()? onTap,
    LMFeedTileStyle? style,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
  ) {
    return LMFeedTile(
      onTap: onTap ?? this.onTap,
      style: style ?? this.style,
      leading: leading ?? this.leading,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      trailing: trailing ?? this.trailing,
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

  final double? height;
  final double? width;
  final double? margin;

  const LMFeedTileStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.mainAxisAlignment,
    this.padding,
    this.height,
    this.width,
    this.margin,
  });

  LMFeedTileStyle copyWith({
    Color? backgroundColor,
    Border? border,
    double? borderRadius,
    MainAxisAlignment? mainAxisAlignment,
    EdgeInsets? padding,
    double? height,
    double? width,
    double? margin,
  }) {
    return LMFeedTileStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
    );
  }

  factory LMFeedTileStyle.basic() {
    return const LMFeedTileStyle(
      backgroundColor: Colors.transparent,
      borderRadius: 0,
      mainAxisAlignment: MainAxisAlignment.start,
      padding: EdgeInsets.all(12),
      width: double.infinity,
      margin: 12,
    );
  }
}
