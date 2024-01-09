import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/commons.dart';

// This widget is used to display a text button
// The [LMFeedButton] can be customized by passing in the required parameters
class LMFeedButton extends StatefulWidget {
  const LMFeedButton({
    super.key,
    this.icon,
    this.text,
    required this.onTap,
    this.activeIcon,
    this.activeText,
    this.isActive = false,
    this.style,
  });

  /// Required parameter, defines whether the button is active or disabled
  final bool isActive;

  /// style class to customise the look and feel of the button
  final LMFeedButtonStyle? style;

  /// Icon to be displayed in the button
  final LMFeedIcon? icon;

  /// Text to be displayed in the button
  final LMFeedText? text;

  /// Action to perform after tapping on the button
  final Function() onTap;

  /// Icon to be displayed in the button if the button is active
  final LMFeedIcon? activeIcon;

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
        height: inStyle.height ?? 32,
        width: inStyle.width,
        padding: inStyle.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: inStyle.backgroundColor,
          borderRadius: BorderRadius.circular(inStyle.borderRadius ?? 0),
          border: inStyle.border,
        ),
        child: Row(
          mainAxisAlignment:
              inStyle.mainAxisAlignment ?? MainAxisAlignment.center,
          children: [
            inStyle.placement == LMIconPlacement.start
                ? widget.isActive
                    ? widget.activeIcon ?? const SizedBox()
                    : widget.icon ?? const SizedBox()
                : const SizedBox(),
            inStyle.placement == LMIconPlacement.start
                ? (widget.icon != null || widget.activeIcon != null)
                    ? SizedBox(width: inStyle.margin ?? 8)
                    : const SizedBox()
                : const SizedBox(),
            widget.isActive
                ? widget.activeText ?? widget.text ?? const SizedBox()
                : widget.text ?? const SizedBox(),
            inStyle.placement == LMIconPlacement.end
                ? (widget.icon != null || widget.activeIcon != null)
                    ? SizedBox(width: inStyle.margin ?? 8)
                    : const SizedBox()
                : const SizedBox(),
            inStyle.placement == LMIconPlacement.end
                ? widget.isActive
                    ? widget.activeIcon ?? const SizedBox()
                    : widget.icon ?? const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _defText() {
    return const LMFeedText(text: "Button");
  }

  Widget _defIcon() {
    return const LMFeedIcon(
      type: LMIconType.icon,
      icon: Icons.done_all,
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
  final LMIconPlacement? placement;

  /// axis alignment for setting button's icon and text spacing
  final MainAxisAlignment? mainAxisAlignment;

  /// margin between the text and icon
  final double? margin;

  const LMFeedButtonStyle({
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.width,
    this.placement,
    this.margin,
    this.mainAxisAlignment,
  });

  factory LMFeedButtonStyle.basic() {
    return LMFeedButtonStyle(
      padding: const EdgeInsets.all(4),
      backgroundColor: Colors.transparent,
      border: Border.all(color: Colors.blue),
      borderRadius: 8,
      height: 42,
      width: 72,
      placement: LMIconPlacement.start,
      margin: 4,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}
