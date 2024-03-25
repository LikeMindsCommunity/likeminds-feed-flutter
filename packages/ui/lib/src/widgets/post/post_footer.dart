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
    this.repostButtonBuilder,
    this.likeButton,
    this.commentButton,
    this.saveButton,
    this.shareButton,
    this.repostButton,
    this.showRepostButton = false,
  });

  final LMFeedPostFooterStyle? postFooterStyle;

  final Widget Function(LMFeedButton)? likeButtonBuilder;
  final Widget Function(LMFeedButton)? commentButtonBuilder;
  final Widget Function(LMFeedButton)? saveButtonBuilder;
  final Widget Function(LMFeedButton)? shareButtonBuilder;
  final Widget Function(LMFeedButton)? repostButtonBuilder;

  final LMFeedButton? likeButton;
  final LMFeedButton? commentButton;
  final LMFeedButton? saveButton;
  final LMFeedButton? shareButton;
  final LMFeedButton? repostButton;
  final bool showRepostButton;

  final _footerChildren = <Widget>[];

  @override
  Widget build(BuildContext context) {
    LMFeedPostFooterStyle footerStyle =
        postFooterStyle ?? LMFeedTheme.instance.theme.footerStyle;
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

    bool showLike = (postFooterStyle.showLikeButton ?? true);

    if (showLike) {
      LMFeedButton likeButton =
          this.likeButton ?? defLikeButton(postFooterStyle);
      Widget lmButton = likeButtonBuilder?.call(likeButton) ?? likeButton;
      _footerChildren.add(lmButton);
    }

    bool showComment = (postFooterStyle.showCommentButton ?? true);

    if (showComment) {
      if (postFooterStyle.alignment == MainAxisAlignment.spaceBetween) {
        _footerChildren.add(const Spacer());
      }
      LMFeedButton commentButton =
          this.commentButton ?? defCommentButton(postFooterStyle);
      Widget lmButton =
          commentButtonBuilder?.call(commentButton) ?? commentButton;
      _footerChildren.add(lmButton);
    }

    bool showSave = (postFooterStyle.showSaveButton ?? true);
    bool showShare = (postFooterStyle.showShareButton ?? true);
    bool showRepost = (postFooterStyle.showRepostButton ?? false);

    if (showSave || showShare) {
      if (postFooterStyle.alignment == MainAxisAlignment.start) {
        _footerChildren.add(const Spacer());
      }
      if (showSave) {
        if (postFooterStyle.alignment == MainAxisAlignment.spaceBetween) {
          _footerChildren.add(const Spacer());
        }
        LMFeedButton saveButton =
            this.saveButton ?? defSaveButton(postFooterStyle);
        Widget lmButton = saveButtonBuilder?.call(saveButton) ?? saveButton;
        _footerChildren.add(lmButton);
      }

      if (showShare) {
        if (postFooterStyle.alignment == MainAxisAlignment.spaceBetween) {
          _footerChildren.add(const Spacer());
        }
        LMFeedButton shareButton =
            this.shareButton ?? defShareButton(postFooterStyle);
        Widget lmButton = shareButtonBuilder?.call(shareButton) ?? shareButton;
        _footerChildren.add(lmButton);
      }
    }
    if (showRepostButton && showRepost) {
      LMFeedButton repostButton =
          this.repostButton ?? defRepostButton(postFooterStyle);
      _footerChildren
          .add(repostButtonBuilder?.call(repostButton) ?? repostButton);
    }
  }

  LMFeedButton defLikeButton(LMFeedPostFooterStyle postFooterStyle) =>
      LMFeedButton(
        text: const LMFeedText(text: "Like"),
        style: postFooterStyle.likeButtonStyle ??
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

  LMFeedButton defCommentButton(LMFeedPostFooterStyle postFooterStyle) =>
      LMFeedButton(
        text: const LMFeedText(text: "Comment"),
        style: postFooterStyle.commentButtonStyle ??
            const LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmCommentSvg,
              ),
              margin: 0,
            ),
        onTap: () {},
      );

  LMFeedButton defSaveButton(LMFeedPostFooterStyle postFooterStyle) =>
      LMFeedButton(
        text: const LMFeedText(text: "Save"),
        style: postFooterStyle.saveButtonStyle,
        onTap: () {},
      );

  LMFeedButton defShareButton(LMFeedPostFooterStyle postFooterStyle) =>
      LMFeedButton(
        text: const LMFeedText(text: "Share"),
        style: postFooterStyle.shareButtonStyle ??
            const LMFeedButtonStyle(
              margin: 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmShareSvg,
              ),
            ),
        onTap: () {},
      );

  LMFeedButton defRepostButton(LMFeedPostFooterStyle postFooterStyle) =>
      LMFeedButton(
        isActive: true,
        text: const LMFeedText(text: "Repost"),
        style: postFooterStyle.repostButtonStyle ??
            const LMFeedButtonStyle(
              margin: 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmRepostSvg,
              ),
            ),
        onTap: () {},
      );

  LMFeedPostFooter copyWith({
    LMFeedPostFooterStyle? postFooterStyle,
    Widget Function(LMFeedButton)? likeButtonBuilder,
    Widget Function(LMFeedButton)? commentButtonBuilder,
    Widget Function(LMFeedButton)? saveButtonBuilder,
    Widget Function(LMFeedButton)? shareButtonBuilder,
    Widget Function(LMFeedButton)? repostButtonBuilder,
    LMFeedButton? likeButton,
    LMFeedButton? commentButton,
    LMFeedButton? saveButton,
    LMFeedButton? shareButton,
    LMFeedButton? repostButton,
    bool? showRepostButton,
  }) {
    return LMFeedPostFooter(
      postFooterStyle: postFooterStyle ?? this.postFooterStyle,
      likeButtonBuilder: likeButtonBuilder ?? this.likeButtonBuilder,
      commentButtonBuilder: commentButtonBuilder ?? this.commentButtonBuilder,
      saveButtonBuilder: saveButtonBuilder ?? this.saveButtonBuilder,
      shareButtonBuilder: shareButtonBuilder ?? this.shareButtonBuilder,
      repostButtonBuilder: repostButtonBuilder ?? this.repostButtonBuilder,
      likeButton: likeButton ?? this.likeButton,
      commentButton: commentButton ?? this.commentButton,
      saveButton: saveButton ?? this.saveButton,
      shareButton: shareButton ?? this.shareButton,
      repostButton: repostButton ?? this.repostButton,
      showRepostButton: showRepostButton ?? this.showRepostButton,
    );
  }
}

class LMFeedPostFooterStyle {
  final bool? showSaveButton;
  final bool? showLikeButton;
  final bool? showCommentButton;
  final bool? showShareButton;
  final bool? showRepostButton;

  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  final MainAxisAlignment? alignment;

  final LMFeedButtonStyle? likeButtonStyle;
  final LMFeedButtonStyle? commentButtonStyle;
  final LMFeedButtonStyle? saveButtonStyle;
  final LMFeedButtonStyle? shareButtonStyle;
  final LMFeedButtonStyle? repostButtonStyle;

  const LMFeedPostFooterStyle({
    this.showSaveButton,
    this.showLikeButton,
    this.showCommentButton,
    this.showShareButton,
    this.showRepostButton,
    this.alignment,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.likeButtonStyle,
    this.commentButtonStyle,
    this.saveButtonStyle,
    this.shareButtonStyle,
    this.repostButtonStyle,
  });

  LMFeedPostFooterStyle copyWith({
    bool? showSaveButton,
    bool? showLikeButton,
    bool? showCommentButton,
    bool? showShareButton,
    bool? showRepostButton,
    MainAxisAlignment? alignment,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    LMFeedButtonStyle? likeButtonStyle,
    LMFeedButtonStyle? commentButtonStyle,
    LMFeedButtonStyle? saveButtonStyle,
    LMFeedButtonStyle? shareButtonStyle,
    LMFeedButtonStyle? repostButtonStyle,
  }) {
    return LMFeedPostFooterStyle(
      showSaveButton: showSaveButton ?? showSaveButton,
      showLikeButton: showLikeButton ?? showLikeButton,
      showCommentButton: showCommentButton ?? showCommentButton,
      showShareButton: showShareButton ?? this.showShareButton,
      showRepostButton: showRepostButton ?? this.showRepostButton,
      alignment: alignment ?? this.alignment,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      commentButtonStyle: commentButtonStyle ?? this.commentButtonStyle,
      likeButtonStyle: likeButtonStyle ?? this.likeButtonStyle,
      saveButtonStyle: saveButtonStyle ?? this.saveButtonStyle,
      shareButtonStyle: shareButtonStyle ?? this.shareButtonStyle,
      repostButtonStyle: repostButtonStyle ?? this.repostButtonStyle,
    );
  }

  factory LMFeedPostFooterStyle.basic({Color? primaryColor}) =>
      LMFeedPostFooterStyle(
        showLikeButton: true,
        showCommentButton: true,
        showShareButton: true,
        showSaveButton: true,
        showRepostButton: false,
        likeButtonStyle: LMFeedButtonStyle.like(primaryColor: primaryColor),
        commentButtonStyle: LMFeedButtonStyle.comment(),
        shareButtonStyle: LMFeedButtonStyle.share(),
        saveButtonStyle: LMFeedButtonStyle.save(primaryColor: primaryColor),
        repostButtonStyle: LMFeedButtonStyle.repost(primaryColor: primaryColor),
        alignment: MainAxisAlignment.start,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
      );
}
