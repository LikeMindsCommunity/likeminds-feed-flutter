import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPendingPostDialog extends StatelessWidget {
  final String pendingPostId;
  final String title;
  final String description;

  final LMFeedTextStyle? headingTextStyles;
  final LMFeedTextStyle? dialogMessageTextStyles;
  final LMFeedButtonStyle? editPostButtonStyles;
  final LMFeedButtonStyle? cancelButtonStyles;

  final VoidCallback? onEditButtonClicked;
  final VoidCallback? onCancelButtonClicked;

  final LMFeedDialogStyle? dialogStyle;

  LMFeedPendingPostDialog({
    Key? key,
    required this.pendingPostId,
    required this.title,
    required this.description,
    this.headingTextStyles,
    this.dialogMessageTextStyles,
    this.editPostButtonStyles = const LMFeedButtonStyle.basic(),
    this.cancelButtonStyles = const LMFeedButtonStyle.basic(),
    this.dialogStyle,
    this.onEditButtonClicked,
    this.onCancelButtonClicked,
  });

  LMFeedPendingPostDialog copyWith({
    String? pendingPostId,
    String? title,
    String? description,
    LMFeedTextStyle? headingTextStyles,
    LMFeedTextStyle? dialogMessageTextStyles,
    LMFeedButtonStyle? editPostButtonStyles,
    LMFeedButtonStyle? cancelButtonStyles,
    LMFeedDialogStyle? dialogStyle,
    VoidCallback? onEditButtonClicked,
    VoidCallback? onCancelButtonClicked,
  }) {
    return LMFeedPendingPostDialog(
      pendingPostId: pendingPostId ?? this.pendingPostId,
      title: title ?? this.title,
      description: description ?? this.description,
      headingTextStyles: headingTextStyles ?? this.headingTextStyles,
      dialogMessageTextStyles:
          dialogMessageTextStyles ?? this.dialogMessageTextStyles,
      editPostButtonStyles: editPostButtonStyles ?? this.editPostButtonStyles,
      cancelButtonStyles: cancelButtonStyles ?? this.cancelButtonStyles,
      dialogStyle: dialogStyle ?? this.dialogStyle,
      onEditButtonClicked: onEditButtonClicked ?? this.onEditButtonClicked,
      onCancelButtonClicked:
          onCancelButtonClicked ?? this.onCancelButtonClicked,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizedBox kPaddingXLarge = LikeMindsTheme.kVerticalPaddingXLarge;

    return LMFeedDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          getTitleText(),
          kPaddingXLarge,
          getBodyText(),
          const SizedBox(height: 44),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              getCancelButton(),
              LikeMindsTheme.kHorizontalPaddingXLarge,
              getEditButton()
            ],
          )
        ],
      ),
      dialogStyle: dialogStyle ?? theme.dialogStyle,
    );
  }

  LMFeedText getTitleText() {
    return LMFeedText(
      text: title,
      style: headingTextStyles ??
          LMFeedTextStyle(
            maxLines: 1,
            textStyle: TextStyle(
              fontSize: 16,
              color: theme.onContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  LMFeedText getBodyText() {
    return LMFeedText(
      text: description,
      style: dialogMessageTextStyles ??
          LMFeedTextStyle(
            overflow: TextOverflow.visible,
            textStyle: TextStyle(
              fontSize: 16,
              color: theme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
    );
  }

  LMFeedButton getCancelButton() {
    return LMFeedButton(
      onTap: () {
        onCancelButtonClicked?.call();
      },
      text: LMFeedText(
        text: "CLOSE",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 14,
            color: theme.inActiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      style: cancelButtonStyles ?? LMFeedButtonStyle.basic(),
    );
  }

  LMFeedButton getEditButton() {
    return LMFeedButton(
      onTap: () {
        onEditButtonClicked?.call();
      },
      style: editPostButtonStyles ?? LMFeedButtonStyle.basic(),
      text: LMFeedText(
        text: "EDIT $postTitleAllCaps",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 14,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Propertiess
  final LMFeedThemeData theme = LMFeedCore.theme;
  final String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  final String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);
  final String postTitleAllCaps = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.allCapitalSingular);
}
