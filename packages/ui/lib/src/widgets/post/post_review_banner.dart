import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template post_review_status}
/// An enum that defines the post review status.
/// [rejected] - Post is rejected and needs to be edited,
/// [pending] - Post is pending
/// {@endtemplate}
enum LMPostReviewStatus {
  rejected,
  pending,
}

/// {@template post_review_banner}
/// A widget that displays a post review banner.
/// Provide a style, onInfoIconClicked, postReviewStatus, reviewStatusIcon,
/// infoIcon, reviewStatusText
/// to customize the post review banner.
/// {@endtemplate}
class LMFeedPostReviewBanner extends StatelessWidget {
  // Optional
  // style class to customise the look and feel of the post review banner
  // Incase the style is not provided, the default theme is used
  final LMFeedPostReviewBannerStyle? style;

  // Optional
  // Action to perform after tapping on the info icon
  final VoidCallback? onInfoIconClicked;

  /// {@macro post_review_status}
  // Required variable
  // Defines the status of the post review
  final LMPostReviewStatus postReviewStatus;

  // Optional
  // Icon to be displayed in the post review banner
  final LMFeedIcon? reviewStatusIcon;

  // Optional
  // Icon to be displayed in the post review banner
  final LMFeedIcon? infoIcon;

  // Optional
  // Text to be displayed in the post review banner
  final LMFeedText? reviewStatusText;

  /// {@macro post_review_banner}
  const LMFeedPostReviewBanner({
    super.key,
    this.style,
    this.onInfoIconClicked,
    this.reviewStatusIcon,
    this.infoIcon,
    this.reviewStatusText,
    required this.postReviewStatus,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedTheme.instance.theme;
    LMFeedPostReviewBannerStyle postReviewStatusStyle = theme.reviewBannerStyle;
    return Container(
      color: style?.backgroundColor ?? postReviewStatusStyle.backgroundColor,
      padding: style?.padding ?? postReviewStatusStyle.padding,
      margin: style?.margin ?? postReviewStatusStyle.margin,
      child: Row(
        children: [
          reviewStatusIcon ??
              LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: postReviewStatus == LMPostReviewStatus.pending
                    ? lmWarningPendingPostSvg
                    : lmRejectPendingPostSvg,
                style: style?.reviewStatusIconStyle,
              ),
          const SizedBox(width: 8.0),
          reviewStatusText ??
              LMFeedText(
                text: postReviewStatus == LMPostReviewStatus.pending
                    ? "Under review"
                    : "Post rejected",
                style: style?.reviewStatusTextStyle,
              ),
          const Spacer(),
          LMFeedButton(
            onTap: () {
              print("print");
              onInfoIconClicked?.call();
            },
            style: LMFeedButtonStyle(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              margin: 0,
              icon: infoIcon ??
                  LMFeedIcon(
                    type: LMFeedIconType.svg,
                    assetPath: lmInfoPendingPostSvg,
                    style: style?.infoIconStyle,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a copy of this [LMFeedPostReviewBanner] but with the given fields
  LMFeedPostReviewBanner copyWith({
    LMFeedPostReviewBannerStyle? style,
    VoidCallback? onInfoIconClicked,
    LMPostReviewStatus? postReviewStatus,
    LMFeedIcon? reviewStatusIcon,
    LMFeedIcon? infoIcon,
    LMFeedText? reviewStatusText,
  }) {
    return LMFeedPostReviewBanner(
      style: style ?? this.style,
      onInfoIconClicked: onInfoIconClicked ?? this.onInfoIconClicked,
      postReviewStatus: postReviewStatus ?? this.postReviewStatus,
      reviewStatusIcon: reviewStatusIcon ?? this.reviewStatusIcon,
      infoIcon: infoIcon ?? this.infoIcon,
      reviewStatusText: reviewStatusText ?? this.reviewStatusText,
    );
  }
}

/// {@template post_review_banner_style}
/// A class that provides styling for [LMFeedPostReviewBanner].
/// Provide a reviewStatusTextStyle, reviewStatusIconStyle, infoIconStyle
/// to customize the [LMFeedPostReviewBanner].
/// {@endtemplate}
class LMFeedPostReviewBannerStyle {
  LMFeedTextStyle? reviewStatusTextStyle;
  LMFeedIconStyle? reviewStatusIconStyle;
  LMFeedIconStyle? infoIconStyle;
  EdgeInsets? padding;
  EdgeInsets? margin;
  Color? backgroundColor;

  /// {@macro post_review_banner_style}
  LMFeedPostReviewBannerStyle({
    this.reviewStatusTextStyle,
    this.reviewStatusIconStyle,
    this.infoIconStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  /// {@template post_review_banner_style_basic}
  /// Creates a copy of this [LMFeedPostReviewBannerStyle]
  /// but with the default theme
  /// {@endtemplate}
  factory LMFeedPostReviewBannerStyle.basic() {
    return LMFeedPostReviewBannerStyle(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: EdgeInsets.zero,
      backgroundColor: LikeMindsTheme.container,
      reviewStatusTextStyle: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: LikeMindsTheme.headingColor,
        ),
      ),
      infoIconStyle: const LMFeedIconStyle(
        size: 24,
        boxSize: 0,
      ),
      reviewStatusIconStyle: const LMFeedIconStyle(
        size: 24,
        boxSize: 0,
      ),
    );
  }
}
