import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedReplyWidget extends StatefulWidget {
  const LMFeedReplyWidget({
    super.key,
    required this.user,
    required this.comment,
    this.profilePicture,
    this.titleText,
    this.subtitleText,
    required this.lmFeedMenuAction,
    required this.onTagTap,
    this.menu,
    this.style,
    this.likeButton,
    this.likeButtonBuilder,
  });

  final LMUserViewData user;
  final LMCommentViewData comment;

  final LMFeedProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subtitleText;

  final LMFeedMenuAction lmFeedMenuAction;
  final Function(String) onTagTap;

  final Widget? menu;

  final LMFeedReplyStyle? style;

  final LMFeedButton? likeButton;

  final Widget Function(LMFeedButton)? likeButtonBuilder;

  @override
  State<LMFeedReplyWidget> createState() => _LMReplyTileState();
}

class _LMReplyTileState extends State<LMFeedReplyWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? Colors.white,
        borderRadius: widget.style?.borderRadius,
      ),
      width: widget.style?.width,
      margin: widget.style?.margin,
      padding: const EdgeInsets.symmetric(
        horizontal: LikeMindsTheme.kPaddingLarge,
        vertical: LikeMindsTheme.kPaddingSmall,
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
                            ),
                          ),
                    ),
                    widget.subtitleText != null
                        ? LikeMindsTheme.kVerticalPaddingSmall
                        : const SizedBox(),
                    widget.subtitleText ?? const SizedBox(),
                    Container(
                      width: widget.style?.width == null
                          ? 240
                          : widget.style!.width! * 0.6,
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: ExpandableText(
                        widget.comment.text,
                        onTagTap: widget.onTagTap,
                        expandText: "see more",
                        animation: true,
                        maxLines: 4,
                        hashtagStyle: widget.style?.linkStyle ??
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: feedTheme.hashTagColor,
                                ),
                        linkStyle: widget.style?.linkStyle ??
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: feedTheme.linkColor,
                                ),
                        textAlign: TextAlign.left,
                        style: widget.style?.textStyle ??
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
            padding: widget.style?.actionsPadding ?? EdgeInsets.zero,
            child: Row(
              children: [
                widget.likeButtonBuilder?.call(_defLikeButton()) ??
                    _defLikeButton(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      // kVerticalPaddingMedium,
    );
  }

  LMFeedButton _defLikeButton() =>
      widget.likeButton ??
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
        style: widget.style?.likeButtonStyle ??
            LMFeedTheme.of(context).postStyle.footerStyle.likeButtonStyle,
      );
}

class LMFeedReplyStyle {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final EdgeInsets? actionsPadding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final double? width;

  final LMFeedButtonStyle? likeButtonStyle;
  final LMFeedButtonStyle? replyButtonStyle;

  final bool showLikeButton;
  final bool showReplyButton;

  const LMFeedReplyStyle({
    this.textStyle,
    this.linkStyle,
    this.actionsPadding,
    this.backgroundColor,
    this.borderRadius,
    this.margin,
    this.width,
    this.likeButtonStyle,
    this.replyButtonStyle,
    this.showLikeButton = true,
    this.showReplyButton = false,
  });
}
