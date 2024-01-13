import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedCommentWidget extends StatefulWidget {
  const LMFeedCommentWidget({
    super.key,
    required this.user,
    required this.comment,
    this.profilePicture,
    this.titleText,
    this.subtitleText,
    required this.lmFeedMenuAction,
    required this.onTagTap,
    this.menu,
    this.likeButtonBuilder,
    this.replyButtonBuilder,
    this.showRepliesButtonBuilder,
    this.likeButton,
    this.replyButton,
    this.showRepliesButton,
    this.style,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final LMFeedProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subtitleText;

  final Function(String) onTagTap;

  final Widget Function(LMFeedMenu)? menu;
  final LMFeedMenuAction lmFeedMenuAction;

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? replyButtonBuilder;
  final Widget Function(LMFeedButton)? showRepliesButtonBuilder;

  final LMFeedButton? likeButton;
  final LMFeedButton? replyButton;
  final LMFeedButton? showRepliesButton;

  final LMFeedCommentStyle? style;

  @override
  State<LMFeedCommentWidget> createState() => _LMCommentTileState();

  LMFeedCommentWidget copyWith({
    LMUserViewData? user,
    LMCommentViewData? comment,
    LMFeedProfilePicture? profilePicture,
    LMFeedText? titleText,
    LMFeedText? subtitleText,
    Function(String)? onTagTap,
    Widget Function(LMFeedMenu)? menu,
    LMFeedMenuAction? lmFeedMenuAction,
    Widget Function(LMFeedButton)? likeButtonBuilder,
    Widget Function(LMFeedButton)? replyButtonBuilder,
    Widget Function(LMFeedButton)? showRepliesButtonBuilder,
    LMFeedButton? likeButton,
    LMFeedButton? replyButton,
    LMFeedButton? showRepliesButton,
    LMFeedCommentStyle? style,
  }) {
    return LMFeedCommentWidget(
      user: user ?? this.user,
      comment: comment ?? this.comment,
      profilePicture: profilePicture ?? this.profilePicture,
      titleText: titleText ?? this.titleText,
      subtitleText: subtitleText ?? this.subtitleText,
      onTagTap: onTagTap ?? this.onTagTap,
      menu: menu ?? this.menu,
      lmFeedMenuAction: lmFeedMenuAction ?? this.lmFeedMenuAction,
      likeButtonBuilder: likeButtonBuilder ?? this.likeButtonBuilder,
      replyButtonBuilder: replyButtonBuilder ?? this.replyButtonBuilder,
      showRepliesButtonBuilder:
          showRepliesButtonBuilder ?? this.showRepliesButtonBuilder,
      likeButton: likeButton ?? this.likeButton,
      replyButton: replyButton ?? this.replyButton,
      showRepliesButton: showRepliesButton ?? this.showRepliesButton,
      style: style ?? this.style,
    );
  }
}

class _LMCommentTileState extends State<LMFeedCommentWidget> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? Colors.white,
        borderRadius: widget.style?.borderRadius,
        boxShadow: widget.style?.boxShadow,
      ),
      margin: widget.style?.margin,
      width: widget.style?.width,
      padding: widget.style?.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.profilePicture ?? const SizedBox(),
              LikeMindsTheme.kHorizontalPaddingLarge,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: widget.style?.width != null
                        ? widget.style!.width! * 0.6
                        : null,
                    child: widget.titleText ??
                        LMFeedText(
                          text: widget.user.name,
                          style: const LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                          ),
                        ),
                  ),
                  widget.subtitleText != null
                      ? LikeMindsTheme.kVerticalPaddingSmall
                      : const SizedBox(),
                  widget.subtitleText ?? const SizedBox(),
                ],
              ),
              const Spacer(),
              widget.menu?.call(_defPostMenu()) ?? _defPostMenu()
            ],
          ),
          LikeMindsTheme.kVerticalPaddingMedium,
          Container(
            padding: widget.style?.actionsPadding ?? EdgeInsets.zero,
            child: ExpandableText(
              widget.comment.text,
              onTagTap: widget.onTagTap,
              expandText: "see more",
              animation: true,
              maxLines: 4,
              hashtagStyle: widget.style?.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: feedTheme.hashTagColor),
              linkStyle: widget.style?.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: feedTheme.linkColor),
              textAlign: TextAlign.left,
              style: widget.style?.textStyle ??
                  Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          LikeMindsTheme.kVerticalPaddingSmall,
          Padding(
            padding: widget.style?.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: [
                widget.likeButtonBuilder?.call(_defLikeCommentButton()) ??
                    _defLikeCommentButton(),
                LikeMindsTheme.kHorizontalPaddingMedium,
                Text(
                  '|',
                  style: TextStyle(
                    fontSize: LikeMindsTheme.kFontSmallMed,
                    color: Colors.grey.shade300,
                  ),
                ),
                LikeMindsTheme.kHorizontalPaddingMedium,
                widget.replyButtonBuilder?.call(_defReplyToCommentButton()) ??
                    _defReplyToCommentButton(),
                LikeMindsTheme.kHorizontalPaddingMedium,
                widget.comment.repliesCount > 0
                    ? widget.replyButtonBuilder
                            ?.call(_defShowRepliesButton()) ??
                        _defShowRepliesButton()
                    : Container(),
                const Spacer(),
                LMFeedText(
                  text: widget.comment.createdAt.timeAgo(),
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: LikeMindsTheme.kFontSmallMed,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LMFeedMenu _defPostMenu() {
    return LMFeedMenu(
      isFeed: false,
      menuItems: widget.comment.menuItems,
      action: widget.lmFeedMenuAction,
    );
  }

  LMFeedButton _defLikeCommentButton() {
    return widget.likeButton ??
        LMFeedButton(
          onTap: () {},
          text: LMFeedText(
            text: 'Like',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          style: LMFeedButtonStyle(
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.favorite_outline,
              style: LMFeedIconStyle(
                color: Colors.grey.shade200,
                size: 16,
              ),
            ),
            activeIcon: const LMFeedIcon(
              icon: Icons.favorite,
              type: LMFeedIconType.icon,
              style: LMFeedIconStyle(
                size: 16,
                color: Colors.blue,
              ),
            ),
          ),
        );
  }

  LMFeedButton _defReplyToCommentButton() {
    return widget.replyButton ??
        LMFeedButton(
          onTap: () {},
          text: LMFeedText(
            text: 'Reply',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade200,
              ),
            ),
          ),
        );
  }

  LMFeedButton _defShowRepliesButton() {
    return widget.showRepliesButton ??
        LMFeedButton(
          onTap: () {},
          text: LMFeedText(
            text: widget.comment.repliesCount > 1
                ? "${widget.comment.repliesCount}  replies"
                : "${widget.comment.repliesCount}  reply",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: Colors.grey.shade200,
                fontSize: 12,
              ),
            ),
          ),
        );
  }
}

class LMFeedCommentStyle {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final EdgeInsets? actionsPadding;
  final Color? backgroundColor;
  final Color? contentBackgroundColor;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;

  const LMFeedCommentStyle({
    this.textStyle,
    this.linkStyle,
    this.actionsPadding,
    this.backgroundColor,
    this.contentBackgroundColor,
    this.margin,
    this.borderRadius,
    this.width,
    this.boxShadow,
    this.padding,
  });

  LMFeedCommentStyle copyWith({
    TextStyle? textStyle,
    TextStyle? linkStyle,
    EdgeInsets? actionsPadding,
    Color? backgroundColor,
    Color? contentBackgroundColor,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    double? width,
    List<BoxShadow>? boxShadow,
    EdgeInsets? padding,
  }) {
    return LMFeedCommentStyle(
      textStyle: textStyle ?? this.textStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      actionsPadding: actionsPadding ?? this.actionsPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      contentBackgroundColor:
          contentBackgroundColor ?? this.contentBackgroundColor,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      width: width ?? this.width,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
    );
  }
}
