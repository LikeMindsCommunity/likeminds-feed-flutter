import 'package:flutter/material.dart';

class LMFeedPollStyle {
  final bool isComposable;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const LMFeedPollStyle({
    this.isComposable = false,
    this.margin,
    this.padding,
    this.decoration,
  });

  static LMFeedPollStyle composable() {
    return LMFeedPollStyle(
      isComposable: true,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
    );
  }

  static LMFeedPollStyle inFeed() {
    return const LMFeedPollStyle(
        margin: EdgeInsets.symmetric(
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
        ));
  }
}
