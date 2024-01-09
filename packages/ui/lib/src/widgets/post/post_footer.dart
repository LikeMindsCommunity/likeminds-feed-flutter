import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/widgets.dart';

class LMFeedPostFooter extends StatelessWidget {
  LMFeedPostFooter({
    super.key,
    this.postFooterStyle = const LMFeedPostFooterStyle(),
    this.likeButtonBuilder,
    this.commentButtonBuilder,
    this.saveButtonBuilder,
    this.shareButtonBuilder,
  });

  final LMFeedPostFooterStyle postFooterStyle;

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? commentButtonBuilder;
  final Widget Function(LMFeedButton)? saveButtonBuilder;
  final Widget Function(LMFeedButton)? shareButtonBuilder;

  final _footerChildren = <Widget>[];

  @override
  Widget build(BuildContext context) {
    _populateButtonList();
    return Container(
      width: postFooterStyle.width,
      height: postFooterStyle.height,
      padding: postFooterStyle.padding,
      margin: postFooterStyle.margin,
      child: Row(
        mainAxisAlignment: postFooterStyle.alignment,
        children: _footerChildren,
      ),
    );
  }

  void _populateButtonList() {
    _footerChildren.clear();

    if (postFooterStyle.showLikeButton ?? true) {
      Widget lmButton = likeButtonBuilder?.call(defLikeButton) ?? defLikeButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showCommentButton ?? true) {
      Widget lmButton =
          commentButtonBuilder?.call(defCommentButton) ?? defCommentButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showSaveButton ?? true) {
      Widget lmButton = saveButtonBuilder?.call(defSaveButton) ?? defSaveButton;
      _footerChildren.add(lmButton);
    }

    if (postFooterStyle.showShareButton ?? true) {
      Widget lmButton =
          shareButtonBuilder?.call(defShareButton) ?? defShareButton;
      _footerChildren.add(lmButton);
    }
  }

  final LMFeedButton defLikeButton = LMFeedButton(
    text: const LMFeedText(text: "Like"),
    style: const LMFeedButtonStyle(
      margin: 0,
    ),
    activeText: const LMFeedText(
      text: "Like",
    ),
    onTap: () {},
    icon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmLikeInActiveSvg,
    ),
    activeIcon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmLikeActiveSvg,
    ),
  );

  final LMFeedButton defCommentButton = LMFeedButton(
    text: const LMFeedText(text: "Comment"),
    style: const LMFeedButtonStyle(
      margin: 0,
    ),
    onTap: () {},
    icon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmCommentSvg,
    ),
  );

  final LMFeedButton defSaveButton = LMFeedButton(
    text: const LMFeedText(text: "Save"),
    style: const LMFeedButtonStyle(
      margin: 0,
    ),
    onTap: () {},
    icon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmSaveInactiveSvg,
    ),
    activeIcon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmSaveActiveSvg,
    ),
  );

  final LMFeedButton defShareButton = LMFeedButton(
    text: const LMFeedText(text: "Share"),
    style: const LMFeedButtonStyle(
      margin: 0,
    ),
    onTap: () {},
    icon: const LMFeedIcon(
      type: LMIconType.svg,
      assetPath: lmShareSvg,
    ),
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

  final MainAxisAlignment alignment;

  const LMFeedPostFooterStyle({
    this.showSaveButton,
    this.showLikeButton,
    this.showCommentButton,
    this.showShareButton,
    this.alignment = MainAxisAlignment.start,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  LMFeedPostFooterStyle copyWith(LMFeedPostFooterStyle style) {
    return LMFeedPostFooterStyle(
      showSaveButton: style.showSaveButton ?? showSaveButton,
      showLikeButton: style.showLikeButton ?? showLikeButton,
      showCommentButton: style.showCommentButton ?? showCommentButton,
      showShareButton: style.showShareButton ?? showShareButton,
      alignment: style.alignment,
      width: style.width ?? width,
      height: style.height ?? height,
      padding: style.padding ?? padding,
      margin: style.margin ?? margin,
    );
  }
}
