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
    this.buttonSeparator,
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
  final Widget? buttonSeparator;

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
    Widget? buttonSeparator,
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
      buttonSeparator: buttonSeparator ?? this.buttonSeparator,
      style: style ?? this.style,
    );
  }
}

class _LMCommentTileState extends State<LMFeedCommentWidget> {
  LMFeedCommentStyle? style;

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    style = widget.style ?? feedTheme.commentStyle;
    return Container(
      decoration: BoxDecoration(
        color: style!.backgroundColor ?? Colors.white,
        borderRadius: style!.borderRadius,
        boxShadow: style!.boxShadow,
      ),
      margin: style!.margin,
      width: style!.width,
      padding: style!.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (style?.showProfilePicture ?? true)
                  ? Container(
                      padding: style?.profilePicturePadding,
                      child: widget.profilePicture ?? const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: style?.titlePadding,
                    width: style!.width != null ? style!.width! * 0.6 : null,
                    child: widget.titleText ??
                        LMFeedText(
                          text: widget.user.name,
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: style?.textStyle?.color ??
                                  feedTheme.onContainer,
                            ),
                            maxLines: 1,
                          ),
                        ),
                  ),
                  widget.subtitleText != null
                      ? Container(
                          padding: style?.subtitlePadding,
                          child: widget.subtitleText,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              const Spacer(),
              widget.menu?.call(_defPostMenu()) ?? _defPostMenu()
            ],
          ),
          LikeMindsTheme.kVerticalPaddingMedium,
          Container(
            padding: style!.actionsPadding ?? EdgeInsets.zero,
            child: LMFeedExpandableText(
              widget.comment.text,
              onTagTap: widget.onTagTap,
              expandText: "see more",
              animation: true,
              maxLines: 4,
              hashtagStyle: style!.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: feedTheme.hashTagColor),
              linkStyle: style!.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: feedTheme.linkColor),
              textAlign: TextAlign.left,
              style: style!.textStyle,
            ),
          ),
          LikeMindsTheme.kVerticalPaddingSmall,
          Padding(
            padding: style!.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: [
                Padding(
                    padding: style!.likeButtonStyle?.padding ??
                        const EdgeInsets.symmetric(horizontal: 8.0),
                    child: widget.likeButtonBuilder
                            ?.call(_defLikeCommentButton()) ??
                        _defLikeCommentButton()),
                widget.buttonSeparator ??
                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: LikeMindsTheme.kFontSmallMed,
                        color: Colors.grey.shade300,
                      ),
                    ),
                style!.showReplyButton
                    ? Padding(
                        padding: style!.replyButtonStyle?.padding ??
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.replyButtonBuilder
                                ?.call(_defReplyToCommentButton()) ??
                            _defReplyToCommentButton())
                    : const SizedBox.shrink(),
                style!.showRepliesButton
                    ? Padding(
                        padding: style!.showRepliesButtonStyle?.padding ??
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.comment.repliesCount > 0
                            ? widget.replyButtonBuilder
                                    ?.call(_defShowRepliesButton()) ??
                                _defShowRepliesButton()
                            : const SizedBox.shrink())
                    : const SizedBox.shrink(),
                if (style?.showTimestamp ?? true) ...[
                  const Spacer(),
                  LMFeedText(
                    text:
                        LMFeedTimeAgo.instance.format(widget.comment.createdAt),
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        fontSize: LikeMindsTheme.kFontSmallMed,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  LMFeedMenu _defPostMenu() {
    return LMFeedMenu(
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
          style: style!.likeButtonStyle ??
              LMFeedButtonStyle(
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
          style: style!.replyButtonStyle ??
              LMFeedButtonStyle(
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.comment_outlined,
                  style: LMFeedIconStyle(
                    color: Colors.grey.shade200,
                    size: 16,
                  ),
                ),
              ),
        );
  }

  LMFeedButton _defShowRepliesButton() {
    return widget.showRepliesButton ??
        LMFeedButton(
          onTap: () {},
          style: style!.showRepliesButtonStyle,
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
  final LMFeedButtonStyle? likeButtonStyle;
  final LMFeedButtonStyle? replyButtonStyle;
  final bool showReplyButton;
  final bool showRepliesButton;
  final LMFeedButtonStyle? showRepliesButtonStyle;

  final bool? showProfilePicture;
  final EdgeInsets? profilePicturePadding;

  final EdgeInsets? titlePadding;
  final EdgeInsets? subtitlePadding;

  final bool? showTimestamp;

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
    this.likeButtonStyle,
    this.replyButtonStyle,
    this.showRepliesButtonStyle,
    this.showReplyButton = true,
    this.showRepliesButton = true,
    this.showProfilePicture = true,
    this.profilePicturePadding,
    this.titlePadding,
    this.subtitlePadding,
    this.showTimestamp = true,
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
    LMFeedButtonStyle? likeButtonStyle,
    LMFeedButtonStyle? replyButtonStyle,
    LMFeedButtonStyle? showRepliesButtonStyle,
    bool? showReplyButton,
    bool? showRepliesButton,
    bool? showProfilePicture,
    EdgeInsets? profilePicturePadding,
    EdgeInsets? titlePadding,
    EdgeInsets? subtitlePadding,
    bool? showTimestamp,
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
      likeButtonStyle: likeButtonStyle ?? this.likeButtonStyle,
      replyButtonStyle: replyButtonStyle ?? this.replyButtonStyle,
      showRepliesButtonStyle:
          showRepliesButtonStyle ?? this.showRepliesButtonStyle,
      showRepliesButton: showRepliesButton ?? this.showRepliesButton,
      showReplyButton: showReplyButton ?? this.showReplyButton,
      showProfilePicture: showProfilePicture ?? this.showProfilePicture,
      profilePicturePadding:
          profilePicturePadding ?? this.profilePicturePadding,
      titlePadding: titlePadding ?? this.titlePadding,
      subtitlePadding: subtitlePadding ?? this.subtitlePadding,
      showTimestamp: showTimestamp ?? this.showTimestamp,
    );
  }

  factory LMFeedCommentStyle.basic(
      {Color? activeIconColor,
      Color? inActiveIconColor,
      bool isReply = false}) {
    if (!isReply) {
      return LMFeedCommentStyle._commentBasic(
          activeIconColor: activeIconColor,
          inActiveIconColor: inActiveIconColor);
    } else {
      return LMFeedCommentStyle._replyBasic(
          activeIconColor: activeIconColor,
          inActiveIconColor: inActiveIconColor);
    }
  }

  factory LMFeedCommentStyle._commentBasic(
          {Color? activeIconColor, Color? inActiveIconColor}) =>
      LMFeedCommentStyle(
        showProfilePicture: false,
        padding: const EdgeInsets.all(12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: inActiveIconColor ?? LikeMindsTheme.greyColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: activeIconColor ?? LikeMindsTheme.errorColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        replyButtonStyle: const LMFeedButtonStyle(),
        showRepliesButtonStyle: const LMFeedButtonStyle(),
      );

  factory LMFeedCommentStyle._replyBasic(
          {Color? activeIconColor, Color? inActiveIconColor}) =>
      LMFeedCommentStyle(
        showProfilePicture: false,
        padding: const EdgeInsets.only(
            left: 48.0, top: 12.0, bottom: 12, right: 12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: inActiveIconColor ?? LikeMindsTheme.greyColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: activeIconColor ?? LikeMindsTheme.errorColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        showRepliesButton: false,
        showReplyButton: false,
        replyButtonStyle: const LMFeedButtonStyle(),
      );
}
