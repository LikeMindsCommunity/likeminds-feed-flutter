import 'package:flutter/material.dart';

extension LMFeedContainerExtension on Container {
  /// Creates a copy of this container but with the given fields replaced with
  /// the new values. If the new values are null, the old values are used.
  /// Please note that height and width are not included in this extension.
  /// to change the height and width of the container, use the constraints field
  /// in the copyWith method.
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///  color: Colors.red,
  /// child: Text('Hello World'),
  /// ).copyWith(
  ///  color: Colors.blue,
  ///  constraints: BoxConstraints.tightFor(height: 100, width: 100),
  /// );
  Container copyWith({
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Widget? child,
    Clip? clipBehavior,
  }) {
    return Container(
      key: key ?? this.key,
      alignment: alignment ?? this.alignment,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      decoration: decoration ?? this.decoration,
      foregroundDecoration: foregroundDecoration ?? this.foregroundDecoration,
      constraints: constraints ?? this.constraints,
      margin: margin ?? this.margin,
      transform: transform ?? this.transform,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      child: child ?? this.child,
    );
  }
}
