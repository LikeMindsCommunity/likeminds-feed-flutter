import 'package:flutter/material.dart';

/// {@template lm_feed_text}
/// A simple text widget to be used throughout the Feed experience
/// Provides high level customisability through [LMFeedTextStyle]
/// Also, can add onTap functionality
/// {@endtemplate}
class LMFeedText extends StatelessWidget {
  // text to be shown as [String]
  final String text;

  // onTap functionality by providing a [Function]
  final Function()? onTap;

  // style class to provide appearance customisability
  /// {@macro lm_feed_text_style}
  final LMFeedTextStyle? style;

  /// {@macro lm_feed_text}
  const LMFeedText({
    Key? key,
    required this.text,
    this.style,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LMFeedTextStyle inStyle = style ?? LMFeedTextStyle.basic();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: inStyle.margin,
        padding: inStyle.padding,
        color: Colors.transparent,
        child: Text(
          text,
          textAlign: inStyle.textAlign,
          overflow: inStyle.overflow ?? TextOverflow.ellipsis,
          maxLines: inStyle.maxLines,
          style: inStyle.textStyle,
        ),
      ),
    );
  }

  /// copyWith function to get a new object of [LMFeedText]
  /// with specific single values passed
  LMFeedText copyWith({
    String? text,
    LMFeedTextStyle? style,
    Function()? onTap,
  }) {
    return LMFeedText(
      text: text ?? this.text,
      style: style ?? this.style,
      onTap: onTap ?? this.onTap,
    );
  }
}

/// {@template lm_feed_text_style}
/// class representing style for a [LMFeedText]
/// {@endtemplate}
class LMFeedTextStyle {
  /// [bool] to determine whether the text is selectable or not
  final bool selectable;

  /// [int] describing maximum lines a text spans
  final int? maxLines;

  /// overflow behaviour for the text [TextOverflow]
  final TextOverflow? overflow;

  /// align behaviour for text [TextAlign]
  final TextAlign? textAlign;

  /// default Flutter styling class for changing look of the text [TextStyle]
  final TextStyle? textStyle;

  /// margin for the text [EdgeInsets]
  final EdgeInsets? margin;

  /// padding for the text [EdgeInsets]
  final EdgeInsets? padding;

  const LMFeedTextStyle({
    this.selectable = false,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.margin,
    this.padding,
  });

  factory LMFeedTextStyle.basic() {
    return const LMFeedTextStyle(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      textStyle: TextStyle(fontSize: 14),
    );
  }

  /// copyWith function to get a new object of [LMFeedTextStyle]
  /// with specific single values passed
  LMFeedTextStyle copyWith({
    bool? selectable,
    TextStyle? textStyle,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return LMFeedTextStyle(
      selectable: selectable ?? this.selectable,
      textStyle: textStyle ?? this.textStyle,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      textAlign: textAlign ?? this.textAlign,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
    );
  }
}
