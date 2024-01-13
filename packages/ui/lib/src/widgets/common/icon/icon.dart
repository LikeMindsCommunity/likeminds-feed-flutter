import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:flutter_svg/svg.dart';

/// A simple icon widget to be used throughout the feed
/// Represents three types of icons - icon, png, svg
/// Provides customisability through [LMFeedIconStyle]
class LMFeedIcon extends StatelessWidget {
  /// enum describing the type of icon to be shown
  final LMFeedIconType type;

  /// if [LMFeedIconType.icon] then pass icon of type [IconData]
  final IconData? icon;

  /// if [LMFeedIconType.png] or [LMFeedIconType.svg] then pass path of icon [String]
  final String? assetPath;

  /// style class for styling the icon [LMFeedIconStyle]
  final LMFeedIconStyle? style;

  /// either the icon [IconData] or asset path [String] must be provided
  const LMFeedIcon({
    super.key,
    required this.type,
    this.assetPath,
    this.icon,
    this.style,
  }) : assert(icon != null || assetPath != null);

  getIconWidget(LMFeedIconStyle style) {
    switch (type) {
      case LMFeedIconType.icon:
        return Icon(
          icon,
          color: style.color,
          size: style.size?.abs() ?? 24,
        );
      case LMFeedIconType.svg:
        return SizedBox(
          width: style.size?.abs() ?? 24,
          height: style.size?.abs() ?? 24,
          child: SvgPicture.asset(
            assetPath!,
            colorFilter: style.color == null
                ? null
                : ColorFilter.mode(
                    style.color!,
                    BlendMode.srcATop,
                  ),
            fit: style.fit ?? BoxFit.contain,
          ),
        );
      case LMFeedIconType.png:
        return SizedBox(
          width: style.size?.abs() ?? 24,
          height: style.size?.abs() ?? 24,
          child: Image.asset(
            assetPath!,
            fit: BoxFit.contain,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inStyle = style ?? LMFeedIconStyle.basic();
    return Container(
      padding: EdgeInsets.all(
        inStyle.boxPadding?.abs() ?? 0,
      ),
      decoration: BoxDecoration(
        color: inStyle.backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(inStyle.boxBorderRadius ?? 0),
        ),
      ),
      child: Center(
        child: getIconWidget(inStyle),
      ),
    );
  }
}

class LMFeedIconStyle {
  /// color of the icon, not applicable on [LMFeedIconType.png]
  final Color? color;

  /// square size of the icon
  final double? size;

  /// square size of the box surrounding the icon
  final double? boxSize;

  /// weight of the border around the box
  final double? boxBorder;

  /// radius of the box around the icon
  final double? boxBorderRadius;

  /// padding around icon with respect to the box
  final double? boxPadding;

  /// color of the box, or background color of icon
  final Color? backgroundColor;

  /// fit inside the box for icon
  final BoxFit? fit;

  const LMFeedIconStyle({
    this.color,
    this.size,
    this.boxSize,
    this.boxBorder,
    this.boxBorderRadius,
    this.boxPadding,
    this.backgroundColor,
    this.fit,
  });

  factory LMFeedIconStyle.basic() {
    return const LMFeedIconStyle(
      color: Colors.black,
      size: 28,
      boxSize: 36,
      boxPadding: 8,
      fit: BoxFit.contain,
    );
  }
}
