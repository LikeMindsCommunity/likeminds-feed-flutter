import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

export 'package:likeminds_feed_ui_fl/src/widgets/post/style/post_footer_style.dart';

class LMPostFooter extends StatelessWidget {
  LMPostFooter({
    super.key,
    this.postFooterStyle,
    this.likeButtonBuilder,
    this.commentButtonBuilder,
    this.saveButtonBuilder,
    this.shareButtonBuilder,
  });

  final LMPostFooterStyle? postFooterStyle;

  final Widget Function(LMButton)? likeButtonBuilder;
  final Widget Function(LMButton)? commentButtonBuilder;
  final Widget Function(LMButton)? saveButtonBuilder;
  final Widget Function(LMButton)? shareButtonBuilder;

  final _footerChildren = const <Widget>[];

  @override
  Widget build(BuildContext context) {
    _populateButtonList();
    return Row(
      mainAxisAlignment: postFooterStyle?.alignment ?? MainAxisAlignment.start,
      children: _footerChildren,
    );
  }

  void _populateButtonList() {
    if (postFooterStyle == null) {
      _footerChildren.addAll([
        defLikeButton,
        defCommentButton,
        defSaveButton,
        defShareButton,
      ]);
    } else {
      if (postFooterStyle!.showLikeButton ?? true) {
        Widget lmButton =
            likeButtonBuilder?.call(defLikeButton) ?? defLikeButton;
        _footerChildren.add(lmButton);
      }

      if (postFooterStyle!.showCommentButton ?? true) {
        Widget lmButton =
            commentButtonBuilder?.call(defCommentButton) ?? defCommentButton;
        _footerChildren.add(lmButton);
      }

      if (postFooterStyle!.showSaveButton ?? true) {
        Widget lmButton =
            saveButtonBuilder?.call(defSaveButton) ?? defSaveButton;
        _footerChildren.add(lmButton);
      }

      if (postFooterStyle!.showShareButton ?? true) {
        Widget lmButton =
            shareButtonBuilder?.call(defShareButton) ?? defShareButton;
        _footerChildren.add(lmButton);
      }
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
