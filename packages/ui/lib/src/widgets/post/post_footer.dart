import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

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

  final Widget Function(LMButton)? likeButtonBuilder;
  final Widget Function(LMButton)? commentButtonBuilder;
  final Widget Function(LMButton)? saveButtonBuilder;
  final Widget Function(LMButton)? shareButtonBuilder;

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

  final LMButton defLikeButton = LMButton(
    text: const LMTextView(text: "Like"),
    margin: 0,
    activeText: const LMTextView(
      text: "Like",
    ),
    onTap: () {},
    icon: LMIcon.likeInActive(),
    activeIcon: LMIcon.likeActive(),
  );

  final LMButton defCommentButton = LMButton(
    text: const LMTextView(text: "Comment"),
    margin: 0,
    onTap: () {},
    icon: LMIcon.comment(),
  );

  final LMButton defSaveButton = LMButton(
    text: const LMTextView(text: "Save"),
    margin: 0,
    onTap: () {},
    icon: LMIcon.saveInActive(),
    activeIcon: LMIcon.saveActive(),
  );

  final LMButton defShareButton = LMButton(
    text: const LMTextView(text: "Share"),
    margin: 0,
    onTap: () {},
    icon: LMIcon.share(),
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
