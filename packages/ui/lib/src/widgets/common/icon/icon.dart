import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

export 'package:likeminds_feed_ui_fl/src/widgets/common/icon/style/icon_style.dart';

enum LMIconType { icon, svg, png }

class LMIcon extends StatelessWidget {
  final LMIconType type;
  final IconData? icon;
  // path to svg or png/jpeg
  final String? assetPath;
  // not required if the type is png
  final LMIconStyle? iconStyle;

  const LMIcon({
    super.key,
    required this.type,
    this.assetPath,
    this.icon,
    this.iconStyle,
  });

  getIconWidget() {
    switch (type) {
      case LMIconType.icon:
        return Icon(icon,
            color: iconStyle?.color, size: iconStyle?.size?.abs() ?? 24);
      case LMIconType.svg:
        return SizedBox(
          width: iconStyle?.size?.abs() ?? 24,
          height: iconStyle?.size?.abs() ?? 24,
          child: SvgPicture.asset(
            assetPath!,
            colorFilter: iconStyle?.color == null
                ? null
                : ColorFilter.mode(iconStyle!.color!, BlendMode.srcATop),
            fit: iconStyle?.fit ?? BoxFit.contain,
          ),
        );
      case LMIconType.png:
        return SizedBox(
          width: iconStyle?.size?.abs() ?? 24,
          height: iconStyle?.size?.abs() ?? 24,
          child: Image.asset(
            assetPath!,
            fit: BoxFit.contain,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(iconStyle?.boxPadding?.abs() ?? 0),
      child: Center(child: getIconWidget()),
    );
  }

  LMIcon copyWith(LMIcon icon) {
    return LMIcon(
      type: icon.type,
      icon: icon.icon ?? this.icon,
      assetPath: icon.assetPath ?? assetPath,
      iconStyle: iconStyle?.copyWith(icon.iconStyle!) ?? iconStyle,
    );
  }

  factory LMIcon.likeActive() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmLikeActiveSvg,
      iconStyle: LMIconStyle.activePreset(),
    );
  }

  factory LMIcon.likeInActive() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmLikeInActiveSvg,
      iconStyle: LMIconStyle.inActivePreset(),
    );
  }

  factory LMIcon.comment() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmCommentSvg,
      iconStyle: LMIconStyle.inActivePreset(),
    );
  }

  factory LMIcon.share() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmShareSvg,
      iconStyle: LMIconStyle.inActivePreset(),
    );
  }

  factory LMIcon.saveActive() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmSaveActiveSvg,
      iconStyle: LMIconStyle.activePreset(),
    );
  }

  factory LMIcon.saveInActive() {
    return LMIcon(
      type: LMIconType.svg,
      assetPath: lmSaveInactiveSvg,
      iconStyle: LMIconStyle.inActivePreset(),
    );
  }
}
