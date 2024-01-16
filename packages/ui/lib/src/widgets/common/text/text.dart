import 'package:flutter/material.dart';

/// A simple text widget to be used throughout the Feed experience
/// Provides high level customisability through [LMFeedTextStyle]
/// Also, can add onTap functionality
class LMFeedText extends StatelessWidget {
  /// text to be shown as [String]
  final String text;

  /// onTap functionality by providing a [Function]
  final Function()? onTap;

  /// style class to provide appearance customisability
  final LMFeedTextStyle? style;

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
      child: Container(
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

/// class representing style for a [LMFeedText]
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

  const LMFeedTextStyle({
    this.selectable = false,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
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
  }) {
    return LMFeedTextStyle(
      selectable: selectable ?? this.selectable,
      textStyle: textStyle ?? this.textStyle,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}
