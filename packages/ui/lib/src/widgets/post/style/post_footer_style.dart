import 'package:flutter/material.dart';

class LMPostFooterStyle {
  bool? showSaveButton;
  bool? showLikeButton;
  bool? showCommentButton;
  bool? showShareButton;

  MainAxisAlignment alignment;

  LMPostFooterStyle({
    this.showSaveButton,
    this.showLikeButton,
    this.showCommentButton,
    this.showShareButton,
    this.alignment = MainAxisAlignment.start,
  });

  LMPostFooterStyle copyWith(LMPostFooterStyle style) {
    return LMPostFooterStyle(
      showSaveButton: style.showSaveButton ?? showSaveButton,
      showLikeButton: style.showLikeButton ?? showLikeButton,
      showCommentButton: style.showCommentButton ?? showCommentButton,
      showShareButton: style.showShareButton ?? showShareButton,
      alignment: style.alignment,
    );
  }
}
