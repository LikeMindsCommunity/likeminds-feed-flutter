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

  ///[LMFeedTextStyle] for poll info text
  final LMFeedTextStyle? pollInfoStyles;

  ///[LMFeedTextStyle] for poll answer text
  final LMFeedTextStyle? pollAnswerStyle;

  /// [LMFeedTextStyle] for time stamp text
  final LMFeedTextStyle? timeStampStyle;

  ///[LMFeedTextStyle] for percentage text
  final LMFeedTextStyle? percentageStyle;

  ///[LMFeedTextStyle] for edit poll options text
  final LMFeedTextStyle? editPollOptionsStyles;

  /// [LMFeedTextStyle] for submit poll text style
  final LMFeedTextStyle? submitPollTextStyle;

  /// [LMFeedButtonStyle] for submit poll button style
  final LMFeedButtonStyle? submitPollButtonStyle;

  /// [LMPollOptionStyle] for poll option style
  final LMFeedPollOptionStyle? pollOptionStyle;

  const LMFeedPollStyle({
    this.isComposable = false,
    this.margin,
    this.padding,
    this.decoration,
    this.backgroundColor,
    this.pollQuestionStyle,
    this.pollInfoStyles,
    this.pollAnswerStyle,
    this.timeStampStyle,
    this.percentageStyle,
    this.editPollOptionsStyles,
    this.submitPollTextStyle,
    this.submitPollButtonStyle,
    this.pollOptionStyle,
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

  factory LMFeedPollStyle.basic(
      {Color? primaryColor, Color? containerColor, Color? inActiveColor}) {
    return LMFeedPollStyle(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      backgroundColor: containerColor ?? Colors.white,
      decoration: BoxDecoration(
        color: containerColor ?? Colors.white,
      ),
      pollOptionStyle: LMFeedPollOptionStyle.basic(
          primaryColor: primaryColor, inActiveColor: inActiveColor),
    );
  }

  LMFeedPollStyle copyWith({
    bool? isComposable,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    Color? backgroundColor,
    LMFeedTextStyle? pollQuestionStyle,
    LMFeedTextStyle? pollInfoStyles,
    LMFeedTextStyle? pollAnswerStyle,
    LMFeedTextStyle? timeStampStyle,
    LMFeedTextStyle? votesCountStyles,
    LMFeedTextStyle? percentageStyle,
    LMFeedTextStyle? editPollOptionsStyles,
    LMFeedTextStyle? submitPollTextStyle,
    LMFeedButtonStyle? submitPollButtonStyle,
    LMFeedPollOptionStyle? pollOptionStyle,
  }) {
    return LMFeedPollStyle(
      isComposable: isComposable ?? this.isComposable,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pollQuestionStyle: pollQuestionStyle ?? this.pollQuestionStyle,
      pollInfoStyles: pollInfoStyles ?? this.pollInfoStyles,
      pollAnswerStyle: pollAnswerStyle ?? this.pollAnswerStyle,
      timeStampStyle: timeStampStyle ?? this.timeStampStyle,
      percentageStyle: percentageStyle ?? this.percentageStyle,
      editPollOptionsStyles:
          editPollOptionsStyles ?? this.editPollOptionsStyles,
      submitPollTextStyle: submitPollTextStyle ?? this.submitPollTextStyle,
      submitPollButtonStyle:
          submitPollButtonStyle ?? this.submitPollButtonStyle,
      pollOptionStyle: pollOptionStyle ?? this.pollOptionStyle,
    );
  }
}

class LMFeedPollOptionStyle {
  ///[Color] for poll option selected color
  final Color? pollOptionSelectedColor;

  ///[Color] for poll option other color
  final Color? pollOptionOtherColor;

  ///[Color] for tick in poll option selected
  final Color? pollOptionSelectedTickColor;

  ///[Color] for border of selected poll option
  final Color? pollOptionSelectedBorderColor;

  /// [Color] for text color of selected poll option
  final Color? pollOptionSelectedTextColor;

  /// [Color] for text color of other poll option
  final Color? pollOptionOtherTextColor;

  ///[LMFeedTextStyle] for votes count text
  final LMFeedTextStyle? votesCountStyles;

  ///[LMFeedTextStyle] for poll option text style
  final LMFeedTextStyle? pollOptionTextStyle;

  /// [BoxDecoration] for poll option decoration
  final BoxDecoration? pollOptionDecoration;

  const LMFeedPollOptionStyle({
    this.pollOptionSelectedColor,
    this.pollOptionOtherColor,
    this.pollOptionSelectedTickColor,
    this.pollOptionSelectedBorderColor,
    this.pollOptionSelectedTextColor,
    this.votesCountStyles,
    this.pollOptionOtherTextColor,
    this.pollOptionTextStyle,
    this.pollOptionDecoration,
  });

  /// copyWith method for [LMFeedPollOptionStyle]
  LMFeedPollOptionStyle copyWith({
    Color? pollOptionSelectedColor,
    Color? pollOptionOtherColor,
    Color? pollOptionSelectedTickColor,
    Color? pollOptionSelectedBorderColor,
    Color? pollOptionSelectedTextColor,
    Color? pollOptionOtherTextColor,
    LMFeedTextStyle? votesCountStyles,
    LMFeedTextStyle? pollOptionTextStyle,
    BoxDecoration? pollOptionDecoration,
  }) {
    return LMFeedPollOptionStyle(
      pollOptionSelectedColor:
          pollOptionSelectedColor ?? this.pollOptionSelectedColor,
      pollOptionOtherColor: pollOptionOtherColor ?? this.pollOptionOtherColor,
      pollOptionSelectedTickColor:
          pollOptionSelectedTickColor ?? this.pollOptionSelectedTickColor,
      pollOptionSelectedBorderColor:
          pollOptionSelectedBorderColor ?? this.pollOptionSelectedBorderColor,
      pollOptionSelectedTextColor:
          pollOptionSelectedTextColor ?? this.pollOptionSelectedTextColor,
      pollOptionOtherTextColor:
          pollOptionOtherTextColor ?? this.pollOptionOtherTextColor,
      votesCountStyles: votesCountStyles ?? this.votesCountStyles,
      pollOptionTextStyle: pollOptionTextStyle ?? this.pollOptionTextStyle,
      pollOptionDecoration: pollOptionDecoration ?? this.pollOptionDecoration,
    );
  }

  factory LMFeedPollOptionStyle.basic(
      {Color? primaryColor, Color? inActiveColor}) {
    return LMFeedPollOptionStyle(
      pollOptionSelectedColor: primaryColor?.withOpacity(0.2) ??
          LikeMindsTheme.primaryColor.withOpacity(0.2),
      pollOptionOtherColor:
          inActiveColor ?? const Color.fromRGBO(230, 235, 245, 1),
    );
  }
}
