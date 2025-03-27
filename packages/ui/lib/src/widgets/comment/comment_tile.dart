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
    this.profilePictureBuilder,
    this.titleText,
    this.titleTextBuilder,
    this.subtitleText,
    this.subtitleTextBuilder,
    this.editedText,
    this.editedTextBuilder,
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
    this.subTextSeparator,
    this.subTextStyle,
    this.customTitle,
    this.customTitleBuilder,
    this.onProfileNameTap,
    this.contentBuilder,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final LMFeedProfilePicture? profilePicture;
  final Widget Function(BuildContext, LMFeedProfilePicture?)?
      profilePictureBuilder;
  final LMFeedText? titleText;
  final LMFeedTextBuilder? titleTextBuilder;
  final LMFeedText? subtitleText;
  final Widget? Function(BuildContext, LMFeedText?)? subtitleTextBuilder;
  final Widget? subTextSeparator;
  final LMFeedText? customTitle;
  final Widget Function(LMFeedText?)? customTitleBuilder;
  final LMFeedText? editedText;
  final LMFeedTextBuilder? editedTextBuilder;

  /// {@macro feed_on_tag_tap}
  final LMFeedOnTagTap onTagTap;
  final Function()? onProfileNameTap;

  final Widget Function(LMFeedMenu)? menu;
  final LMFeedMenuAction lmFeedMenuAction;

  /// {@macro feed_button_builder}
  final LMFeedButtonBuilder? likeButtonBuilder;
  final LMFeedButtonBuilder? replyButtonBuilder;
  final LMFeedButtonBuilder? showRepliesButtonBuilder;

  final LMFeedButton? likeButton;
  final LMFeedButton? replyButton;
  final LMFeedButton? showRepliesButton;
  final Widget? buttonSeparator;

  final LMFeedCommentStyle? style;
  final LMFeedTextStyle? subTextStyle;
  final Widget Function(BuildContext, LMFeedExpandableText)? contentBuilder;

  @override
  State<LMFeedCommentWidget> createState() => _LMCommentTileState();

  LMFeedCommentWidget copyWith({
    LMUserViewData? user,
    LMCommentViewData? comment,
    LMFeedProfilePicture? profilePicture,
    Widget Function(BuildContext, LMFeedProfilePicture?)? profilePictureBuilder,
    LMFeedText? titleText,
    LMFeedTextBuilder? titleTextBuilder,
    LMFeedText? subtitleText,
    Widget Function(BuildContext, LMFeedText?)? subtitleTextBuilder,
    LMFeedText? editedText,
    LMFeedTextBuilder? editedTextBuilder,
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
    Widget? subTextSeparator,
    LMFeedTextStyle? subTextStyle,
    LMFeedText? customTitle,
    Widget Function(LMFeedText?)? customTitleBuilder,
    Function()? onProfileNameTap,
    Widget Function(BuildContext, LMFeedExpandableText)? contentBuilder,
  }) {
    return LMFeedCommentWidget(
      user: user ?? this.user,
      comment: comment ?? this.comment,
      profilePicture: profilePicture ?? this.profilePicture,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      titleText: titleText ?? this.titleText,
      titleTextBuilder: titleTextBuilder ?? this.titleTextBuilder,
      subTextSeparator: subTextSeparator ?? this.subTextSeparator,
      subtitleText: subtitleText ?? this.subtitleText,
      subtitleTextBuilder: subtitleTextBuilder ?? this.subtitleTextBuilder,
      editedText: editedText ?? this.editedText,
      editedTextBuilder: editedTextBuilder ?? this.editedTextBuilder,
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
      subTextStyle: subTextStyle ?? this.subTextStyle,
      customTitle: customTitle ?? this.customTitle,
      customTitleBuilder: customTitleBuilder ?? this.customTitleBuilder,
      onProfileNameTap: onProfileNameTap ?? this.onProfileNameTap,
      contentBuilder: contentBuilder ?? this.contentBuilder,
    );
  }
}

class _LMCommentTileState extends State<LMFeedCommentWidget> {
  LMFeedCommentStyle? style;

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;
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
                  ? widget.profilePictureBuilder
                          ?.call(context, widget.profilePicture) ??
                      const SizedBox.shrink()
                  : const SizedBox.shrink(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => widget.onProfileNameTap?.call(),
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: style?.titlePadding,
                          width:
                              style!.width != null ? style!.width! * 0.6 : null,
                          child: widget.titleTextBuilder
                                  ?.call(context, _defTitleText(feedTheme)) ??
                              _defTitleText(feedTheme),
                        ),
                      ),
                      widget.customTitleBuilder?.call(widget.customTitle) ??
                          const SizedBox.shrink(),
                    ],
                  ),
                  getCommentSubtitleText(),
                ],
              ),
              const Spacer(),
              style!.showMenu
                  ? widget.menu?.call(_defCommentMenu()) ?? _defCommentMenu()
                  : const SizedBox.shrink(),
            ],
          ),
          Container(
            padding: style!.contentPadding ?? const EdgeInsets.only(top: 8),
            color: style!.contentBackgroundColor ?? Colors.white,
            child: widget.contentBuilder?.call(
                  context,
                  _defContent(context, feedTheme),
                ) ??
                _defContent(context, feedTheme),
          ),
          Padding(
            padding: style!.actionsPadding ?? const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                widget.likeButtonBuilder?.call(_defLikeCommentButton()) ??
                    _defLikeCommentButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: widget.buttonSeparator ??
                      const Text(
                        '|',
                        style: TextStyle(
                          fontSize: LikeMindsTheme.kFontSmallMed,
                          color: LikeMindsTheme.greyColor,
                        ),
                      ),
                ),
                style!.showReplyButton
                    ? widget.replyButtonBuilder
                            ?.call(_defReplyToCommentButton()) ??
                        _defReplyToCommentButton()
                    : const SizedBox.shrink(),
                if (style!.showRepliesButton &&
                    widget.comment.repliesCount > 0) ...[
                  if (style!.showReplyButton)
                    const Text(
                      ' · ',
                      style: TextStyle(
                        fontSize: LikeMindsTheme.kFontSmallMed,
                        color: LikeMindsTheme.greyColor,
                      ),
                    ),
                  widget.showRepliesButtonBuilder
                          ?.call(_defShowRepliesButton()) ??
                      _defShowRepliesButton()
                ],
                const Spacer(),
                if (widget.comment.isEdited)
                  widget.editedTextBuilder
                          ?.call(context, _defEditedText(feedTheme)) ??
                      _defEditedText(feedTheme),
                if (style?.showTimestamp ?? true)
                  LMFeedText(
                    text:
                        LMFeedTimeAgo.instance.format(widget.comment.createdAt),
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        fontSize: LikeMindsTheme.kFontSmall,
                        color: feedTheme.inActiveColor,
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

  LMFeedExpandableText _defContent(
      BuildContext context, LMFeedThemeData feedTheme) {
    return LMFeedExpandableText(
      widget.comment.text,
      onTagTap: widget.onTagTap,
      expandText: style!.expandText ?? "see more",
      collapseText: style!.collapseText ?? "view less",
      animation: true,
      maxLines: 4,
      prefixStyle: style!.expandTextStyle,
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
    );
  }

  LMFeedText _defEditedText(LMFeedThemeData feedTheme) {
    return widget.editedText ??
        LMFeedText(
          text: 'Edited ${(style?.showTimestamp ?? true) ? " · " : ""}',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: LikeMindsTheme.kFontSmall,
              color: feedTheme.inActiveColor,
            ),
          ),
        );
  }

  LMFeedText _defTitleText(LMFeedThemeData feedTheme) {
    return widget.titleText ??
        LMFeedText(
          text: widget.user.name,
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: style?.textStyle?.color ?? feedTheme.onContainer,
            ),
            maxLines: 1,
          ),
        );
  }

  Widget getCommentSubtitleText() {
    return Container(
      padding: style?.subtitlePadding,
      child: widget.subtitleTextBuilder?.call(context, widget.subtitleText),
    );
  }

  LMFeedMenu _defCommentMenu() {
    return LMFeedMenu(
      menuItems: widget.comment.menuItems,
      action: widget.lmFeedMenuAction,
    );
  }

  LMFeedButton _defLikeCommentButton() {
    return widget.likeButton ??
        LMFeedButton(
          onTap: () {},
          text: const LMFeedText(
            text: 'Like',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                color: LikeMindsTheme.greyColor,
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
                    color: LikeMindsTheme.errorColor,
                  ),
                ),
              ),
        );
  }

  LMFeedButton _defReplyToCommentButton() {
    return widget.replyButton ??
        LMFeedButton(
          onTap: () {},
          text: const LMFeedText(
            text: 'Reply',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                color: LikeMindsTheme.greyColor,
              ),
            ),
          ),
          style: style!.replyButtonStyle ??
              const LMFeedButtonStyle(
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.comment_outlined,
                  style: LMFeedIconStyle(
                    color: LikeMindsTheme.greyColor,
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
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                color: LikeMindsTheme.greyColor,
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
  final EdgeInsets? contentPadding;
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
  final bool showMenu;
  final LMFeedButtonStyle? showRepliesButtonStyle;

  final bool? showProfilePicture;
  final EdgeInsets? profilePicturePadding;

  final EdgeInsets? titlePadding;
  final EdgeInsets? subtitlePadding;

  final TextStyle? expandTextStyle;
  final String? expandText;
  final String? collapseText;

  final bool? showTimestamp;

  const LMFeedCommentStyle({
    this.textStyle,
    this.linkStyle,
    this.contentPadding,
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
    this.showMenu = true,
    this.expandTextStyle,
    this.expandText,
    this.collapseText,
  });

  LMFeedCommentStyle copyWith({
    TextStyle? textStyle,
    TextStyle? linkStyle,
    EdgeInsets? contentPadding,
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
    TextStyle? expandTextStyle,
    String? expandText,
    bool? showMenu,
    String? collapseText,
  }) {
    return LMFeedCommentStyle(
      textStyle: textStyle ?? this.textStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      contentPadding: contentPadding ?? this.contentPadding,
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
      expandText: expandText ?? this.expandText,
      expandTextStyle: expandTextStyle ?? this.expandTextStyle,
      showMenu: showMenu ?? this.showMenu,
      collapseText: collapseText ?? this.collapseText,
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
        replyButtonStyle: const LMFeedButtonStyle(),
      );
}
