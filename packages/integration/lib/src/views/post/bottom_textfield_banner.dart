import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedBottomTextFieldBanner extends StatelessWidget {
  const LMFeedBottomTextFieldBanner({
    super.key,
    required this.isEditing,
    required this.isReplyEditing,
    this.crossButtonBuilder,
    this.textBuilder,
    this.style,
  });
  final bool isEditing;
  final bool isReplyEditing;
  final LMFeedButtonBuilder? crossButtonBuilder;
  final LMFeedTextBuilder? textBuilder;
  final LMFeedBottomTextFieldBannerStyle? style;

  @override
  Widget build(BuildContext context) {
    final commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);
    final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance;
    final LMFeedCommentState state = _commentBloc.state;
    final String userName =
        state is LMFeedReplyingCommentState ? state.userName : "";
    final LMFeedThemeData feedTheme = LMFeedCore.theme;
    return Container(
      padding: style?.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: style?.height,
      width: style?.width,
      decoration: style?.boxDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textBuilder?.call(
                context,
                _defTextBuilder(
                    commentTitleSmallCapSingular, userName, feedTheme),
              ) ??
              _defTextBuilder(
                  commentTitleSmallCapSingular, userName, feedTheme),
          crossButtonBuilder?.call(
                _defButton(_commentBloc, feedTheme),
              ) ??
              _defButton(_commentBloc, feedTheme),
        ],
      ),
    );
  }

  LMFeedButton _defButton(
      LMFeedCommentBloc _commentBloc, LMFeedThemeData feedTheme) {
    return LMFeedButton(
      onTap: () {
        isEditing
            ? _commentBloc.add(LMFeedEditCommentCancelEvent())
            : _commentBloc.add(LMFeedReplyCancelEvent());
      },
      style: LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.close,
          style: LMFeedIconStyle(
            color: feedTheme.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }

  LMFeedText _defTextBuilder(String commentTitleSmallCapSingular,
      String userName, LMFeedThemeData feedTheme) {
    return LMFeedText(
      text: isEditing
          ? "Editing ${'$commentTitleSmallCapSingular'} "
          : isReplyEditing
              ? "Editing reply"
              : "Replying to $userName",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: feedTheme.onContainer,
        ),
      ),
    );
  }
}

class LMFeedBottomTextFieldBannerStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? boxDecoration;
  final Color? textColor;
  final double? width;
  final double? height;

  LMFeedBottomTextFieldBannerStyle({
    this.padding,
    this.margin,
    this.boxDecoration,
    this.textColor,
    this.width,
    this.height,
  });

  LMFeedBottomTextFieldBannerStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? boxDecoration,
    Color? textColor,
    double? width,
    double? height,
  }) {
    return LMFeedBottomTextFieldBannerStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      boxDecoration: boxDecoration ?? this.boxDecoration,
      textColor: textColor ?? this.textColor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
