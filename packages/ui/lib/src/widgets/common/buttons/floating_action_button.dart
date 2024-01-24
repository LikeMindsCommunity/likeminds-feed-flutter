import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedFloatingActionButton extends StatelessWidget {
  final bool isCollapsed;
  final String? text;

  final VoidCallback? onTap;

  const LMFeedFloatingActionButton({
    super.key,
    this.isCollapsed = false,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    );
  }
}

class LMFeedFloatingActionButtonStyle {
  final Color? backgroundColor;

  final double? collapsedHeight;
  final double? collapsedWidth;

  final double? expandedHeight;
  final double? expandedWidth;

  final LMFeedIcon? icon;

  final bool? showTextOnCollapsed;

  final bool? showTextOnExpanded;

  final Duration? animationDuration;

  final Curve? animationCurve;

  const LMFeedFloatingActionButtonStyle({
    this.backgroundColor,
    this.icon,
    this.collapsedHeight,
    this.collapsedWidth,
    this.expandedHeight,
    this.expandedWidth,
    this.showTextOnCollapsed,
    this.showTextOnExpanded,
    this.animationDuration,
    this.animationCurve,
  });

  LMFeedFloatingActionButtonStyle copyWith({
    Color? backgroundColor,
    LMFeedIcon? icon,
    double? collapsedHeight,
    double? collapsedWidth,
    double? expandedHeight,
    double? expandedWidth,
    bool? showTextOnCollapsed,
    bool? showTextOnExpanded,
  }) {
    return LMFeedFloatingActionButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
      collapsedHeight: collapsedHeight ?? this.collapsedHeight,
      collapsedWidth: collapsedWidth ?? this.collapsedWidth,
      expandedHeight: expandedHeight ?? this.expandedHeight,
      expandedWidth: expandedWidth ?? this.expandedWidth,
      showTextOnCollapsed: showTextOnCollapsed ?? this.showTextOnCollapsed,
      showTextOnExpanded: showTextOnExpanded ?? this.showTextOnExpanded,
    );
  }
}
