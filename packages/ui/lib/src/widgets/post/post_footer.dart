import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedPostFooter extends StatelessWidget {
  LMFeedPostFooter({
    super.key,
    this.postFooterStyle,
    this.likeButtonBuilder,
    this.commentButtonBuilder,
    this.saveButtonBuilder,
    this.shareButtonBuilder,
    this.likeButton,
    this.commentButton,
    this.saveButton,
    this.shareButton,
  });

  final LMFeedPostFooterStyle? postFooterStyle;

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? commentButtonBuilder;
  final Widget Function(LMFeedButton)? saveButtonBuilder;
  final Widget Function(LMFeedButton)? shareButtonBuilder;

  final LMFeedButton? likeButton;
  final LMFeedButton? commentButton;
  final LMFeedButton? saveButton;
  final LMFeedButton? shareButton;

  final _footerChildren = <Widget>[];

  @override
  Widget build(BuildContext context) {
    LMFeedPostFooterStyle footerStyle =
        postFooterStyle ?? LMFeedTheme.of(context).postStyle.footerStyle;
    _populateButtonList(footerStyle);
    return Container(
      width: footerStyle.width,
      height: footerStyle.height,
      padding: footerStyle.padding,
      margin: footerStyle.margin,
      child: Row(
        mainAxisAlignment: footerStyle.alignment ?? MainAxisAlignment.start,
        children: _footerChildren,
      ),
    );
  }

  void _populateButtonList(LMFeedPostFooterStyle postFooterStyle) {
    _footerChildren.clear();

    if (postFooterStyle.showLikeButton ?? true) {
      LMFeedButton likeButton = this.likeButton ?? defLikeButton();
      Widget lmButton = likeButtonBuilder?.call(likeButton) ?? likeButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showCommentButton ?? true) {
      LMFeedButton commentButton = this.commentButton ?? defCommentButton();
      Widget lmButton =
          commentButtonBuilder?.call(commentButton) ?? commentButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showSaveButton ?? true) {
      LMFeedButton saveButton = this.saveButton ?? defSaveButton();
      Widget lmButton = saveButtonBuilder?.call(saveButton) ?? saveButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showShareButton ?? true) {
      LMFeedButton shareButton = this.shareButton ?? defShareButton();
      Widget lmButton = shareButtonBuilder?.call(shareButton) ?? shareButton;
      _footerChildren.add(lmButton);
    }
  }

  LMFeedButton defLikeButton() => LMFeedButton(
        text: const LMFeedText(text: "Like"),
        style: postFooterStyle?.likeButtonStyle ??
            const LMFeedButtonStyle(
              margin: 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmLikeInActiveSvg,
              ),
              activeIcon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmLikeActiveSvg,
              ),
            ),
        activeText: const LMFeedText(
          text: "Like",
        ),
        onTap: () {},
      );

  LMFeedButton defCommentButton() => LMFeedButton(
        text: const LMFeedText(text: "Comment"),
        style: postFooterStyle?.commentButtonStyle ??
            const LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmCommentSvg,
              ),
              margin: 0,
            ),
        onTap: () {},
      );

  LMFeedButton defSaveButton() => LMFeedButton(
        text: const LMFeedText(text: "Save"),
        style: postFooterStyle?.saveButtonStyle ??
            const LMFeedButtonStyle(
              margin: 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmSaveInactiveSvg,
              ),
              activeIcon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmSaveActiveSvg,
              ),
            ),
        onTap: () {},
      );

  LMFeedButton defShareButton() => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        style: postFooterStyle?.shareButtonStyle ??
            const LMFeedButtonStyle(
              margin: 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmShareSvg,
              ),
            ),
        onTap: () {},
      );
}

class LMFeedPostFooterStyle {
  final bool? showSaveButton;
  final bool? showLikeButton;
  final bool? showCommentButton;
  final bool? showShareButton;

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  final MainAxisAlignment? alignment;

  final LMFeedButtonStyle? likeButtonStyle;
  final LMFeedButtonStyle? commentButtonStyle;
  final LMFeedButtonStyle? saveButtonStyle;
  final LMFeedButtonStyle? shareButtonStyle;

  const LMFeedPostFooterStyle({
    this.showSaveButton,
    this.showLikeButton,
    this.showCommentButton,
    this.showShareButton,
    this.alignment,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.likeButtonStyle,
    this.commentButtonStyle,
    this.saveButtonStyle,
    this.shareButtonStyle,
  });

  LMFeedPostFooterStyle copyWith(LMFeedPostFooterStyle style) {
    return LMFeedPostFooterStyle(
      showSaveButton: style.showSaveButton ?? showSaveButton,
      showLikeButton: style.showLikeButton ?? showLikeButton,
      showCommentButton: style.showCommentButton ?? showCommentButton,
      showShareButton: style.showShareButton ?? showShareButton,
      alignment: style.alignment ?? alignment,
      width: style.width ?? width,
      height: style.height ?? height,
      padding: style.padding ?? padding,
      margin: style.margin ?? margin,
    );
  }
}
