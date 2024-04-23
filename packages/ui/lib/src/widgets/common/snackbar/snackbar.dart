import 'package:flutter/material.dart';

class LMFeedSnackBar extends SnackBar {
  final LMFeedSnackBarStyle? style;

  LMFeedSnackBar({
    super.key,
    this.style,
    required super.content,
  }) : super(
          action: style?.action,
          backgroundColor: style?.backgroundColor,
          behavior: style?.behavior,
          elevation: style?.elevation,
          margin: style?.margin,
          padding: style?.padding,
          shape: style?.shape,
          duration: style?.duration ?? const Duration(seconds: 4),
          animation: style?.animation,
          onVisible: style?.onVisible,
          clipBehavior: style?.clipBehavior ?? Clip.hardEdge,
          actionOverflowThreshold: style?.actionOverflowThreshold,
          closeIconColor: style?.closeIconColor,
          dismissDirection: style?.dismissDirection ?? DismissDirection.down,
          showCloseIcon: style?.showCloseIcon,
          width: style?.width,
        );

  LMFeedSnackBar copyWith({
    LMFeedSnackBarStyle? style,
    Widget? content,
  }) {
    return LMFeedSnackBar(
      style: style ?? this.style,
      content: content ?? this.content,
    );
  }
}

class LMFeedSnackBarStyle {
  final SnackBarAction? action;
  final Color? backgroundColor;
  final SnackBarBehavior? behavior;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final Duration? duration;
  final Animation<double>? animation;
  final VoidCallback? onVisible;
  final double? actionOverflowThreshold;
  final Clip? clipBehavior;
  final Color? closeIconColor;
  final DismissDirection? dismissDirection;
  final bool? showCloseIcon;
  final double? width;

  const LMFeedSnackBarStyle({
    this.action,
    this.backgroundColor,
    this.behavior,
    this.elevation,
    this.margin,
    this.padding,
    this.shape,
    this.duration,
    this.animation,
    this.onVisible,
    this.actionOverflowThreshold,
    this.clipBehavior,
    this.closeIconColor,
    this.dismissDirection,
    this.showCloseIcon,
    this.width,
  });

  LMFeedSnackBarStyle copyWith({
    SnackBarAction? action,
    Color? backgroundColor,
    SnackBarBehavior? behavior,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Duration? duration,
    Animation<double>? animation,
    VoidCallback? onVisible,
    double? actionOverflowThreshold,
    Clip? clipBehavior,
    Color? closeIconColor,
    DismissDirection? dismissDirection,
    bool? showCloseIcon,
    double? width,
  }) {
    return LMFeedSnackBarStyle(
      action: action ?? this.action,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      behavior: behavior ?? this.behavior,
      elevation: elevation ?? this.elevation,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      shape: shape ?? this.shape,
      duration: duration ?? this.duration,
      animation: animation ?? this.animation,
      onVisible: onVisible ?? this.onVisible,
      actionOverflowThreshold:
          actionOverflowThreshold ?? this.actionOverflowThreshold,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      dismissDirection: dismissDirection ?? this.dismissDirection,
      showCloseIcon: showCloseIcon ?? this.showCloseIcon,
      width: width ?? this.width,
    );
  }
}
