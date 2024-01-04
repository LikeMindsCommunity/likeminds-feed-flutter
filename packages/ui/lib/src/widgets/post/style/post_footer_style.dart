import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/buttons/style/button_style.dart';

class LMPostFooterStyle {
  LMButtonStyle? likeButtonStyle;
  LMButtonStyle? commentButtonStyle;
  LMButtonStyle? shareButtonStyle;
  LMButtonStyle? saveButtonStyle;

  Color? activeColor;
  Color? inactiveColor;

  bool? showSaveButton;
  bool? showLikeButton;
  bool? showCommentButton;
  bool? showShareButton;

  MainAxisAlignment alignment;

  LMPostFooterStyle({
    this.likeButtonStyle,
    this.commentButtonStyle,
    this.shareButtonStyle,
    this.saveButtonStyle,
    this.activeColor,
    this.inactiveColor,
    this.showSaveButton,
    this.showLikeButton,
    this.showCommentButton,
    this.showShareButton,
    this.alignment = MainAxisAlignment.start,
  });
}
