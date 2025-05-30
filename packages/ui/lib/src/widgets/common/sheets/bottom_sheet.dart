import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedBottomSheet extends StatefulWidget {
  final LMFeedText? title;
  final List<Widget> children;
  final LMFeedBottomSheetStyle? style;

  const LMFeedBottomSheet({
    Key? key,
    required this.children,
    this.style,
    this.title,
  }) : super(key: key);

  @override
  State<LMFeedBottomSheet> createState() => _LMBottomSheetState();

  LMFeedBottomSheet copyWith({
    LMFeedText? title,
    List<Widget>? children,
    LMFeedBottomSheetStyle? style,
  }) {
    return LMFeedBottomSheet(
      title: title ?? this.title,
      style: style ?? this.style,
      children: children ?? this.children,
    );
  }
}

class _LMBottomSheetState extends State<LMFeedBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData theme = LMFeedTheme.instance.theme;
    return Container(
      width: screenSize.width,
      height: widget.style?.maxHeight,
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? theme.container,
        borderRadius: widget.style?.borderRadius,
        boxShadow: widget.style?.boxShadow,
      ),
      constraints: BoxConstraints(
        maxHeight: widget.style?.maxHeight ?? screenSize.height * 0.8,
        minHeight: widget.style?.minHeight ?? 0,
      ),
      margin: widget.style?.margin,
      padding:
          widget.style?.padding ?? const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.style?.dragBar ??
              Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 8,
                    decoration: ShapeDecoration(
                      color: widget.style?.dragBarColor ??
                          theme.disabledColor.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
          widget.title != null
              ? Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: widget.title)
              : const SizedBox.shrink(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => widget.children[index],
              itemCount: widget.children.length,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class LMFeedBottomSheetStyle {
  final LMFeedTextStyle? titleStyle;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final double? maxHeight;
  final double? minHeight;
  final double? elevation;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final Widget? dragBar;
  final Color? dragBarColor;

  const LMFeedBottomSheetStyle({
    this.titleStyle,
    this.backgroundColor,
    this.borderRadius,
    this.maxHeight,
    this.minHeight,
    this.elevation,
    this.padding,
    this.margin,
    this.boxShadow,
    this.dragBar,
    this.dragBarColor,
  });

  LMFeedBottomSheetStyle copyWith({
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    double? maxHeight,
    double? minHeight,
    double? elevation,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? boxShadow,
    Widget? dragBar,
    Color? dragBarColor,
    LMFeedTextStyle? titleStyle,
  }) {
    return LMFeedBottomSheetStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      boxShadow: boxShadow ?? this.boxShadow,
      dragBar: dragBar ?? this.dragBar,
      dragBarColor: dragBarColor ?? this.dragBarColor,
    );
  }
}
