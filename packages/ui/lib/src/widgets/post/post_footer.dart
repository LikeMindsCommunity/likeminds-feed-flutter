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
        postFooterStyle ?? LMFeedTheme.of(context).footerStyle;
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
      LMFeedButton commentButton =
          this.commentButton ?? defCommentButton(postFooterStyle);
      Widget lmButton =
          commentButtonBuilder?.call(commentButton) ?? commentButton;
      _footerChildren.add(lmButton);
    }

    bool showSave = (postFooterStyle.showSaveButton ?? true);
    bool showShare = (postFooterStyle.showShareButton ?? true);

    if (showSave || showShare) {
      _footerChildren.add(const Spacer());

      if (showSave) {
        LMFeedButton saveButton =
            this.saveButton ?? defSaveButton(postFooterStyle);
        Widget lmButton = saveButtonBuilder?.call(saveButton) ?? saveButton;
        _footerChildren.add(lmButton);
      }

      if (showShare) {
        LMFeedButton shareButton =
            this.shareButton ?? defShareButton(postFooterStyle);
        Widget lmButton = shareButtonBuilder?.call(shareButton) ?? shareButton;
        _footerChildren.add(lmButton);
      }
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

  LMFeedPostFooter copyWith({
    LMFeedPostFooterStyle? postFooterStyle,
    Widget Function(LMFeedButton)? likeButtonBuilder,
    Widget Function(LMFeedButton)? commentButtonBuilder,
    Widget Function(LMFeedButton)? saveButtonBuilder,
    Widget Function(LMFeedButton)? shareButtonBuilder,
    LMFeedButton? likeButton,
    LMFeedButton? commentButton,
    LMFeedButton? saveButton,
    LMFeedButton? shareButton,
  }) {
    return LMFeedPostFooter(
      postFooterStyle: postFooterStyle ?? this.postFooterStyle,
      likeButtonBuilder: likeButtonBuilder ?? this.likeButtonBuilder,
      commentButtonBuilder: commentButtonBuilder ?? this.commentButtonBuilder,
      saveButtonBuilder: saveButtonBuilder ?? this.saveButtonBuilder,
      shareButtonBuilder: shareButtonBuilder ?? this.shareButtonBuilder,
      likeButton: likeButton ?? this.likeButton,
      commentButton: commentButton ?? this.commentButton,
      saveButton: saveButton ?? this.saveButton,
      shareButton: shareButton ?? this.shareButton,
    );
  }
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

  LMFeedPostFooterStyle copyWith({
    bool? showSaveButton,
    bool? showLikeButton,
    bool? showCommentButton,
    bool? showShareButton,
    MainAxisAlignment? alignment,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    LMFeedButtonStyle? likeButtonStyle,
    LMFeedButtonStyle? commentButtonStyle,
    LMFeedButtonStyle? saveButtonStyle,
    LMFeedButtonStyle? shareButtonStyle,
  }) {
    return LMFeedPostFooterStyle(
      showSaveButton: showSaveButton ?? showSaveButton,
      showLikeButton: showLikeButton ?? showLikeButton,
      showCommentButton: showCommentButton ?? showCommentButton,
      showShareButton: showShareButton ?? this.showShareButton,
      alignment: alignment ?? this.alignment,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      commentButtonStyle: commentButtonStyle ?? this.commentButtonStyle,
      likeButtonStyle: likeButtonStyle ?? this.likeButtonStyle,
      saveButtonStyle: saveButtonStyle ?? this.saveButtonStyle,
      shareButtonStyle: shareButtonStyle ?? this.shareButtonStyle,
    );
  }

  factory LMFeedPostFooterStyle.basic({Color? primaryColor}) =>
      LMFeedPostFooterStyle(
        showLikeButton: true,
        showCommentButton: true,
        showShareButton: true,
        showSaveButton: true,
        likeButtonStyle: LMFeedButtonStyle(
          padding: const EdgeInsets.only(right: 16.0),
          icon: const LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: primaryColor ?? LikeMindsTheme.errorColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        commentButtonStyle: const LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmCommentSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        shareButtonStyle: const LMFeedButtonStyle(
          showText: false,
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmShareSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        saveButtonStyle: LMFeedButtonStyle(
          showText: false,
          icon: const LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmSaveInactiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmSaveActiveSvg,
            style: LMFeedIconStyle(
              color: primaryColor ?? LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          padding: const EdgeInsets.only(right: 8.0),
        ),
        alignment: MainAxisAlignment.start,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
      );
}
