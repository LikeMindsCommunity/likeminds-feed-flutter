import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedPollStyle {
  ///[bool] to check if the poll is composable
  final bool isComposable;

  ///[EdgeInsets] for margin
  final EdgeInsets? margin;

  ///[EdgeInsets] for padding
  final EdgeInsets? padding;

  ///[BoxDecoration] for decoration
  final BoxDecoration? decoration;

  ///[Color] for background color of the poll
  final Color? backgroundColor;

  ///[LMFeedTextStyle] for poll question text
  final LMFeedTextStyle? pollQuestionStyle;

  ///[LMFeedTextStyle] for poll option text
  final LMFeedTextStyle? pollOptionStyle;

  ///[LMFeedTextStyle] for poll info text
  final LMFeedTextStyle? pollInfoStyles;

  ///[LMFeedTextStyle] for votes count text
  final LMFeedTextStyle? votesCountStyles;

  ///[LMFeedTextStyle] for percentage text
  final LMFeedTextStyle? percentageStyle;

  ///[LMFeedTextStyle] for edit poll options text
  final LMFeedTextStyle? editPollOptionsStyles;

  ///[Color] for poll option selected color
  final Color? pollOptionSelectedColor;

  ///[Color] for poll option other color
  final Color? pollOptionOtherColor;

  const LMFeedPollStyle({
    this.isComposable = false,
    this.margin,
    this.padding,
    this.decoration,
    this.backgroundColor,
    this.pollQuestionStyle,
    this.pollOptionStyle,
    this.pollInfoStyles,
    this.votesCountStyles,
    this.percentageStyle,
    this.editPollOptionsStyles,
    this.pollOptionSelectedColor,
    this.pollOptionOtherColor,
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

  LMFeedPollStyle copyWith({
    bool? isComposable,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    Color? backgroundColor,
    LMFeedTextStyle? pollQuestionStyle,
    LMFeedTextStyle? pollOptionStyle,
    LMFeedTextStyle? pollInfoStyles,
    LMFeedTextStyle? votesCountStyles,
    LMFeedTextStyle? percentageStyle,
    LMFeedTextStyle? editPollOptionsStyles,
    Color? pollOptionSelectedColor,
    Color? pollOptionOtherColor,
  }) {
    return LMFeedPollStyle(
      isComposable: isComposable ?? this.isComposable,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pollQuestionStyle: pollQuestionStyle ?? this.pollQuestionStyle,
      pollOptionStyle: pollOptionStyle ?? this.pollOptionStyle,
      pollInfoStyles: pollInfoStyles ?? this.pollInfoStyles,
      votesCountStyles: votesCountStyles ?? this.votesCountStyles,
      percentageStyle: percentageStyle ?? this.percentageStyle,
      editPollOptionsStyles:
          editPollOptionsStyles ?? this.editPollOptionsStyles,
      pollOptionSelectedColor:
          pollOptionSelectedColor ?? this.pollOptionSelectedColor,
      pollOptionOtherColor: pollOptionOtherColor ?? this.pollOptionOtherColor,
    );
  }
}
