import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/packages/expandable_text/expandable_text.dart';

class LMCommentTile extends StatefulWidget {
  const LMCommentTile({
    super.key,
    required this.user,
    required this.comment,
    this.profilePicture,
    this.titleText,
    this.subtitleText,
    this.commentActions,
    this.actionsPadding,
    required this.lmFeedMenuAction,
    required this.onTagTap,
    this.backgroundColor,
    this.contentBackgroundColor,
    this.margin,
    this.borderRadius,
    this.width,
    this.menu,
    this.textStyle,
    this.linkStyle,
    this.boxShadow,
    this.padding,
    this.likeButtonBuilder,
    this.replyButtonBuilder,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final LMProfilePicture? profilePicture;
  final LMTextView? titleText;
  final LMTextView? subtitleText;
  final List<Widget>? commentActions;
  final EdgeInsets? actionsPadding;
  final Function(String) onTagTap;
  final Color? backgroundColor;
  final Color? contentBackgroundColor;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final Widget Function(LMFeedMenu)? menu;
  final LMFeedMenuAction lmFeedMenuAction;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;

  final Widget Function(LMButton)? likeButtonBuilder;
  final Widget Function(LMButton)? replyButtonBuilder;

  @override
  State<LMCommentTile> createState() => _LMCommentTileState();

  LMCommentTile copyWith(LMCommentTile comment) {
    return LMCommentTile(
      user: comment.user,
      comment: comment.comment,
      profilePicture: comment.profilePicture,
      titleText: comment.titleText,
      subtitleText: comment.subtitleText,
      commentActions: comment.commentActions,
      actionsPadding: comment.actionsPadding,
      lmFeedMenuAction: comment.lmFeedMenuAction,
      onTagTap: comment.onTagTap,
      backgroundColor: comment.backgroundColor,
      contentBackgroundColor: comment.contentBackgroundColor,
      margin: comment.margin,
      borderRadius: comment.borderRadius,
      width: comment.width,
      menu: comment.menu,
      textStyle: comment.textStyle,
      linkStyle: comment.linkStyle,
      boxShadow: comment.boxShadow,
      padding: comment.padding,
    );
  }
}

class _LMCommentTileState extends State<LMCommentTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? kWhiteColor,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      margin: widget.margin,
      width: widget.width,
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.profilePicture ?? const SizedBox(),
              kHorizontalPaddingLarge,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: widget.width != null ? widget.width! * 0.6 : null,
                    child: widget.titleText ??
                        LMTextView(
                          text: widget.user.name,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                  ),
                  widget.subtitleText != null
                      ? kVerticalPaddingSmall
                      : const SizedBox(),
                  widget.subtitleText ?? const SizedBox(),
                ],
              ),
              const Spacer(),
              widget.menu?.call(_defPostMenu()) ?? _defPostMenu()
            ],
          ),
          kVerticalPaddingMedium,
          Container(
            padding: widget.actionsPadding ?? EdgeInsets.zero,
            child: ExpandableText(
              widget.comment.text,
              onTagTap: widget.onTagTap,
              expandText: "see more",
              animation: true,
              maxLines: 4,
              hashtagStyle: widget.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: theme.colorScheme.primary),
              linkStyle: widget.linkStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: theme.colorScheme.primary),
              textAlign: TextAlign.left,
              style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          kVerticalPaddingSmall,
          Padding(
            padding: widget.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: widget.commentActions ??
                  [
                    widget.likeButtonBuilder?.call(_defLikeCommentButton()) ??
                        _defLikeCommentButton(),
                    kHorizontalPaddingMedium,
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: kFontSmallMed,
                        color: kGrey3Color,
                      ),
                    ),
                    kHorizontalPaddingMedium,
                    widget.replyButtonBuilder
                            ?.call(_defReplyToCommentButton()) ??
                        _defReplyToCommentButton(),
                    kHorizontalPaddingMedium,
                    widget.comment.repliesCount > 0
                        ? _defShowRepliesButton()
                        : Container(),
                    const Spacer(),
                    LMTextView(
                      text: widget.comment.createdAt.timeAgo(),
                      textStyle: const TextStyle(
                        fontSize: kFontSmallMed,
                        color: kGrey3Color,
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

  LMButton _defLikeCommentButton() {
    return LMButton(
      onTap: () {},
      text: const LMTextView(
        text: 'Like',
        textStyle: TextStyle(
          fontSize: 14,
          color: kGrey2Color,
        ),
      ),
      icon: const LMIcon(
        type: LMIconType.icon,
        icon: Icons.favorite_outline,
        iconStyle: LMIconStyle(
          color: kGrey2Color,
          size: 16,
        ),
      ),
      activeIcon: const LMIcon(
        icon: Icons.favorite,
        type: LMIconType.icon,
        iconStyle: LMIconStyle(
          size: 16,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  LMButton _defReplyToCommentButton() {
    return LMButton(
      onTap: () {},
      text: const LMTextView(
        text: 'Reply',
        textStyle: TextStyle(
          fontSize: 14,
          color: kGrey2Color,
        ),
      ),
    );
  }

  LMButton _defShowRepliesButton() {
    return LMButton(
        text: LMTextView(
      text: widget.comment.repliesCount > 1
          ? "${widget.comment.repliesCount}  replies"
          : "${widget.comment.repliesCount}  reply",
      textStyle: const TextStyle(
        color: kGrey2Color,
        fontSize: 12,
      ),
      onTap: () {},
    ));
  }
}
