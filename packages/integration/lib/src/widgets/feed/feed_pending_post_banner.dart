import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_pending_post_banner}
/// `LMFeedPendingPostBanner` is a widget that displays a banner for pending posts in the feed.
/// It includes the number of pending posts, a style for the banner, and a callback for when the banner is pressed.
///
/// The banner is displayed only if there are pending posts.
/// In case there are no pending posts, the widget will not be displayed.
/// Example usage:
/// ```dart
/// LMFeedPendingPostBanner banner = LMFeedPendingPostBanner(
///   onPendingPostBannerPressed: () {
///     // Handle banner press
///   },
///   pendingPostCount: 5,
///   style: LMFeedPendingPostBannerStyle(),
/// );
/// ```
/// {@endtemplate}
class LMFeedPendingPostBanner extends StatelessWidget {
  /// Callback for when the pending post banner is pressed.
  final VoidCallback? onPendingPostBannerPressed;

  /// The number of pending posts.
  final int pendingPostCount;

  /// The style for the pending post banner.
  final LMFeedPendingPostBannerStyle? style;

  const LMFeedPendingPostBanner({
    this.onPendingPostBannerPressed,
    required this.pendingPostCount,
    this.style,
  });

  /// Creates a copy of this `LMFeedPendingPostBanner` but with the given fields replaced with the new values.
  ///
  /// Returns a new instance of [LMFeedPendingPostBanner] with the specified properties updated.
  ///
  /// The returned instance will have the same values as the current instance, except for the properties
  /// that are specified in the parameters. If a parameter is not specified, the corresponding property
  /// will remain unchanged in the returned instance.
  ///
  /// Example usage:
  /// ```dart
  /// LMFeedPendingPostBanner updatedBanner = banner.copyWith(
  ///   onPendingPostBannerPressed: newCallback,
  ///   pendingPostCount: newCount,
  ///   style: newStyle,
  /// );
  /// ```
  LMFeedPendingPostBanner copyWith({
    VoidCallback? onPendingPostBannerPressed,
    int? pendingPostCount,
    LMFeedPendingPostBannerStyle? style,
  }) {
    return LMFeedPendingPostBanner(
      onPendingPostBannerPressed:
          onPendingPostBannerPressed ?? this.onPendingPostBannerPressed,
      pendingPostCount: pendingPostCount ?? this.pendingPostCount,
      style: style ?? this.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;

    // Get the post title in all small singular form
    String postTitleSmallCap = LMFeedPostUtils.getPostTitle(
        LMFeedPluralizeWordAction.allSmallSingular);

    // Get the post title in all small singular form
    String postTitleSmallCapPlural =
        LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural);

    return pendingPostCount == 0
        ? const SizedBox()
        : InkWell(
            onTap: () {
              onPendingPostBannerPressed?.call();
            },
            splashFactory: InkRipple.splashFactory,
            child: Container(
              color: style?.backgroundColor == null ? Colors.white : null,
              child: Container(
                decoration: BoxDecoration(
                  color: style?.backgroundColor ??
                      feedThemeData.primaryColor.withOpacity(0.1),
                  borderRadius: style?.borderRadius,
                  border: style?.border,
                  boxShadow: style?.boxShadow,
                  gradient: style?.gradient,
                  shape: style?.shape ?? BoxShape.rectangle,
                ),
                padding: style?.padding ??
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                margin: style?.margin,
                height: style?.height,
                width: style?.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LMFeedText(
                      text:
                          "$pendingPostCount ${pendingPostCount == 1 ? postTitleSmallCap : postTitleSmallCapPlural} created by you ${pendingPostCount == 1 ? 'is' : 'are'} under review",
                      style: style?.textStyle ??
                          LMFeedTextStyle(
                            textStyle: TextStyle(
                              color: feedThemeData.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    ),
                    LMFeedIcon(
                      type: LMFeedIconType.icon,
                      icon: Icons.chevron_right,
                      style: style?.trailingIconStyle ??
                          LMFeedIconStyle(
                            color: feedThemeData.primaryColor,
                            size: 24,
                          ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

/// {@template lm_feed_pending_post_banner_style}
/// `LMFeedPendingPostBannerStyle` is a class that defines the style for the
/// pending post banner in the feed.
/// It includes styles for text, trailing icon, padding, margin, height, width,
/// border radius, and border.
///  /// Example usage:
/// ```dart
/// LMFeedPendingPostBannerStyle updatedStyle = style.copyWith(
///   textStyle: newTextStyle,
///   trailingIconStyle: newIconStyle,
///   padding: newPadding,
///   margin: newMargin,
///   height: newHeight,
///   width: newWidth,
///   borderRadius: newBorderRadius,
///   border: newBorder,
/// );
/// ```
/// {@endtemplate}
class LMFeedPendingPostBannerStyle {
  /// The style for the text in the banner.
  final LMFeedTextStyle? textStyle;

  /// The style for the trailing icon in the banner.
  final LMFeedIconStyle? trailingIconStyle;

  /// The padding for the banner.
  final EdgeInsets? padding;

  /// The margin for the banner.
  final EdgeInsets? margin;

  /// The height of the banner.
  final double? height;

  /// The width of the banner.
  final double? width;

  /// The border radius of the banner.
  final BorderRadius? borderRadius;

  /// The border of the banner.
  final Border? border;

  /// The background color of the banner.
  final Color? backgroundColor;

  /// The shape of the box.
  final BoxShape? shape;

  /// The gradient of the box.
  final Gradient? gradient;

  /// The list of box shadows for the box.
  final List<BoxShadow>? boxShadow;

  /// {@macro lm_feed_pending_post_banner_style}
  LMFeedPendingPostBannerStyle({
    this.textStyle,
    this.trailingIconStyle,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    this.shape,
    this.gradient,
    this.boxShadow,
  });

  /// {@template lm_feed_pending_post_banner_style_copywith}
  /// Creates a copy of this `LMFeedPendingPostBannerStyle` but with the given fields replaced with the new values.
  /// {@endtemplate}
  /// Returns a new instance of [LMFeedPendingPostBannerStyle] with the specified properties updated.
  ///
  /// The returned instance will have the same values as the current instance, except for the properties
  /// that are specified in the parameters. If a parameter is not specified, the corresponding property
  /// will remain unchanged in the returned instance.
  ///
  /// Example usage:
  /// ```dart
  /// LMFeedPendingPostBannerStyle updatedStyle = style.copyWith(
  ///   textStyle: newTextStyle,
  ///   trailingIconStyle: newIconStyle,
  ///   padding: newPadding,
  ///   margin: newMargin,
  ///   height: newHeight,
  ///   width: newWidth,
  ///   borderRadius: newBorderRadius,
  ///   border: newBorder,
  /// );
  /// ```
  LMFeedPendingPostBannerStyle copyWith({
    LMFeedTextStyle? textStyle,
    LMFeedIconStyle? trailingIconStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    Border? border,
    Color? backgroundColor,
    BoxShape? shape,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
  }) {
    return LMFeedPendingPostBannerStyle(
      textStyle: textStyle ?? this.textStyle,
      trailingIconStyle: trailingIconStyle ?? this.trailingIconStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      height: height ?? this.height,
      width: width ?? this.width,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shape: shape ?? this.shape,
      gradient: gradient ?? this.gradient,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}
