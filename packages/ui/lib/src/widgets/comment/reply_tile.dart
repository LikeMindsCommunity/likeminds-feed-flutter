import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';

class LMFeedReplyTile extends StatefulWidget {
  const LMFeedReplyTile({
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
    this.borderRadius,
    this.margin,
    this.width,
    this.menu,
    this.textStyle,
    this.linkStyle,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final LMFeedProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subtitleText;
  final List<Widget>? commentActions;
  final EdgeInsets? actionsPadding;
  final LMFeedMenuAction lmFeedMenuAction;
  final Function(String) onTagTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final double? width;
  final Widget? menu;

  @override
  State<LMFeedReplyTile> createState() => _LMReplyTileState();
}

class _LMReplyTileState extends State<LMFeedReplyTile> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: widget.borderRadius,
      ),
      width: widget.width,
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(
        horizontal: kPaddingLarge,
        vertical: kPaddingSmall,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
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
                            ),
                          ),
                    ),
                    widget.subtitleText != null
                        ? kVerticalPaddingSmall
                        : const SizedBox(),
                    widget.subtitleText ?? const SizedBox(),
                    Container(
                      width: widget.width == null ? 240 : widget.width! * 0.6,
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
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
                        style: widget.textStyle ??
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                widget.menu ??
                    LMFeedMenu(
                      isFeed: false,
                      menuItems: widget.comment.menuItems,
                      action: widget.lmFeedMenuAction,
                    ),
              ],
            ),
          ),
          Padding(
            padding: widget.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: widget.commentActions ??
                  [
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
                    const Spacer(),
                  ],
            ),
          ),
        ],
      ),
      // kVerticalPaddingMedium,
    );
  }
}
