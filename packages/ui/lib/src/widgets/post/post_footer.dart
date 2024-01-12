import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMFeedPostFooter extends StatelessWidget {
  LMFeedPostFooter({
    super.key,
    this.postFooterStyle,
    this.likeButtonBuilder,
    this.commentButtonBuilder,
    this.saveButtonBuilder,
    this.shareButtonBuilder,
  });

  final LMFeedPostFooterStyle? postFooterStyle;

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? commentButtonBuilder;
  final Widget Function(LMFeedButton)? saveButtonBuilder;
  final Widget Function(LMFeedButton)? shareButtonBuilder;

  final _footerChildren = <Widget>[];

  @override
  Widget build(BuildContext context) {
    _populateButtonList();
    return Container(
      width: postFooterStyle?.width,
      height: postFooterStyle?.height,
      padding: postFooterStyle?.padding,
      margin: postFooterStyle?.margin,
      child: Row(
        mainAxisAlignment:
            postFooterStyle?.alignment ?? MainAxisAlignment.start,
        children: _footerChildren,
      ),
    );
  }

  void _populateButtonList() {
    _footerChildren.clear();

    if (postFooterStyle?.showLikeButton ?? true) {
      Widget lmButton =
          likeButtonBuilder?.call(defLikeButton()) ?? defLikeButton();
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle?.showCommentButton ?? true) {
      Widget lmButton =
          commentButtonBuilder?.call(defCommentButton()) ?? defCommentButton();
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle?.showSaveButton ?? true) {
      Widget lmButton =
          saveButtonBuilder?.call(defSaveButton()) ?? defSaveButton();
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle?.showShareButton ?? true) {
      Widget lmButton =
          shareButtonBuilder?.call(defShareButton()) ?? defShareButton();
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
