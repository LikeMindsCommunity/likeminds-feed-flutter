import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/common/commons.dart';

// This widget is used to display a text button
// The [LMFeedButton] can be customized by passing in the required parameters
class LMFeedButton extends StatefulWidget {
  const LMFeedButton({
    super.key,
    this.text,
    required this.onTap,
    this.activeText,
    this.isActive = false,
    this.style,
  });

  /// Required parameter, defines whether the button is active or disabled
  final bool isActive;

  /// style class to customise the look and feel of the button
  final LMFeedButtonStyle? style;

  /// Text to be displayed in the button
  final LMFeedText? text;

  /// Action to perform after tapping on the button
  final Function() onTap;

  /// Text to be displayed in the button if the button is active
  final LMFeedText? activeText;

  @override
  State<LMFeedButton> createState() => _LMButtonState();
}

class _LMButtonState extends State<LMFeedButton> {
  bool _active = false;

  @override
  void initState() {
    _active = widget.isActive;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inStyle = widget.style ?? LMFeedButtonStyle.basic();
    return GestureDetector(
      onTap: () {
        setState(() {
          _active = !_active;
        });
        widget.onTap();
      },
      child: Container(
        height: inStyle.height,
        width: inStyle.width,
        padding: inStyle.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: inStyle.backgroundColor,
          borderRadius: BorderRadius.circular(inStyle.borderRadius ?? 0),
          border: inStyle.border,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment:
                inStyle.mainAxisAlignment ?? MainAxisAlignment.center,
            children: [
              inStyle.placement == LMFeedIconButtonPlacement.start
                  ? _active
                      ? ((inStyle.activeIcon ?? inStyle.icon) ??
                          const SizedBox.shrink())
                      : inStyle.icon ?? const SizedBox.shrink()
                  : const SizedBox.shrink(),
              inStyle.placement == LMFeedIconButtonPlacement.start
                  ? (inStyle.icon != null || inStyle.activeIcon != null)
                      ? SizedBox(width: inStyle.margin ?? 8)
                      : const SizedBox.shrink()
                  : const SizedBox.shrink(),
              inStyle.showText
                  ? _active
                      ? widget.activeText ??
                          widget.text ??
                          const SizedBox.shrink()
                      : widget.text ?? const SizedBox.shrink()
                  : const SizedBox.shrink(),
              inStyle.placement == LMFeedIconButtonPlacement.end
                  ? (inStyle.icon != null || inStyle.activeIcon != null)
                      ? SizedBox(width: inStyle.margin ?? 8)
                      : const SizedBox.shrink()
                  : const SizedBox.shrink(),
              inStyle.placement == LMFeedIconButtonPlacement.end
                  ? _active
                      ? inStyle.activeIcon ??
                          inStyle.icon ??
                          const SizedBox.shrink()
                      : inStyle.icon ?? const SizedBox.shrink()
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class LMFeedButtonStyle {
  /// padding of the button, defaults to zero
  final EdgeInsets? padding;

  /// background color of the button, defaults to transparent
  final Color? backgroundColor;

  /// border radius of the button container
  final double? borderRadius;

  /// height of the button
  final double? height;

  /// width of the button
  final double? width;

  /// border of the button
  final Border? border;

  /// placement of the icon in the button
  final LMFeedIconButtonPlacement placement;

  /// axis alignment for setting button's icon and text spacing
  final MainAxisAlignment? mainAxisAlignment;

  /// margin between the text and icon
  final double? margin;

  final bool showText;

  /// Icon to be displayed in the button
  final LMFeedIcon? icon;

  /// Icon to be displayed in the button if the button is active
  final LMFeedIcon? activeIcon;

  const LMFeedButtonStyle({
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.width,
    this.placement = LMFeedIconButtonPlacement.start,
    this.margin,
    this.mainAxisAlignment,
    this.showText = true,
    this.icon,
    this.activeIcon,
  });

  factory LMFeedButtonStyle.basic() {
    return const LMFeedButtonStyle(
      padding: EdgeInsets.all(4),
      backgroundColor: Colors.transparent,
      borderRadius: 8,
      height: 28,
      margin: 4,
    );
  }
}
