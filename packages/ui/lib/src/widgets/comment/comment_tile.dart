import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedCommentTile extends StatefulWidget {
  const LMFeedCommentTile({
    super.key,
    required this.user,
    required this.comment,
    this.profilePicture,
    this.titleText,
    this.subtitleText,
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
    this.showRepliesButtonBuilder,
    this.likeButton,
    this.replyButton,
    this.showRepliesButton,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final LMFeedProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subtitleText;
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

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? replyButtonBuilder;
  final Widget Function(LMFeedButton)? showRepliesButtonBuilder;

  final LMFeedButton? likeButton;
  final LMFeedButton? replyButton;
  final LMFeedButton? showRepliesButton;

  @override
  State<LMFeedCommentTile> createState() => _LMCommentTileState();

  LMFeedCommentTile copyWith(LMFeedCommentTile comment) {
    return LMFeedCommentTile(
      user: comment.user,
      comment: comment.comment,
      profilePicture: comment.profilePicture,
      titleText: comment.titleText,
      subtitleText: comment.subtitleText,
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
      likeButton: comment.likeButton,
      likeButtonBuilder: comment.likeButtonBuilder,
      replyButton: comment.replyButton,
      replyButtonBuilder: comment.replyButtonBuilder,
      showRepliesButton: comment.showRepliesButton,
      showRepliesButtonBuilder: comment.showRepliesButtonBuilder,
    );
  }
}

class _LMCommentTileState extends State<LMFeedCommentTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
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
              children: [
                widget.likeButtonBuilder?.call(_defLikeCommentButton()) ??
                    _defLikeCommentButton(),
                kHorizontalPaddingMedium,
                Text(
                  '|',
                  style: TextStyle(
                    fontSize: kFontSmallMed,
                    color: Colors.grey.shade300,
                  ),
                ),
                kHorizontalPaddingMedium,
                widget.replyButtonBuilder?.call(_defReplyToCommentButton()) ??
                    _defReplyToCommentButton(),
                kHorizontalPaddingMedium,
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
                      fontSize: kFontSmallMed,
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
    return LMFeedButton(
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
    );
  }

  LMFeedButton _defReplyToCommentButton() {
    return LMFeedButton(
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
    return LMFeedButton(
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
