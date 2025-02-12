import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMPostUploadingBanner extends StatelessWidget {
  const LMPostUploadingBanner({
    super.key,
    required this.onRetry,
    required this.onCancel,
    this.isUploading = false,
    this.uploadingMessage,
    this.style,
    this.textBuilder,
    this.retryButtonBuilder,
    this.cancelButtonBuilder,
    this.loaderBuilder,
  });

  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final bool isUploading;
  final String? uploadingMessage;
  final LMPostUploadingBannerStyle? style;
  final Widget Function(
      BuildContext context, LMFeedText text, bool isUploading)? textBuilder;
  final LMFeedButtonBuilder? retryButtonBuilder;
  final LMFeedButtonBuilder? cancelButtonBuilder;
  final LMFeedLoaderBuilder? loaderBuilder;

  @override
  Widget build(BuildContext context) {
    final feedThemeData = LMFeedTheme.instance.theme;
    return Container(
      height: style?.height ?? 72,
      decoration: style?.decoration ??
          BoxDecoration(
            color: feedThemeData.container,
          ),
      margin: style?.margin ?? const EdgeInsets.only(bottom: 16),
      alignment: Alignment.center,
      padding: style?.padding ??
          const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          textBuilder?.call(context, _defText(feedThemeData), isUploading) ??
              _defText(feedThemeData),
          const Spacer(),
          if (!isUploading)
            Row(
              children: [
                retryButtonBuilder?.call(_defRetryButton()) ??
                    _defRetryButton(),
                LikeMindsTheme.kHorizontalPaddingLarge,
                cancelButtonBuilder?.call(_defCancelButton()) ??
                    _defCancelButton(),
              ],
            ),
          if (isUploading)
            loaderBuilder?.call(
                  context,
                ) ??
                _defLoader(),
        ],
      ),
    );
  }

  LMFeedLoader _defLoader() {
    return LMFeedLoader(
      style: style?.loaderStyle ??
          const LMFeedLoaderStyle(
            height: 26,
            width: 26,
          ),
    );
  }

  LMFeedButton _defCancelButton() {
    return LMFeedButton(
      onTap: onCancel,
      style: const LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.close,
        ),
      ),
    );
  }

  LMFeedButton _defRetryButton() {
    return LMFeedButton(
      onTap: onRetry,
      style: const LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.refresh_rounded,
        ),
      ),
    );
  }

  LMFeedText _defText(LMFeedThemeData feedThemeData) {
    return LMFeedText(
      text: isUploading
          ? uploadingMessage ?? "Posting"
          : "Upload failed... try again",
      style: LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: isUploading
              ? feedThemeData.onContainer
              : feedThemeData.errorColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class LMPostUploadingBannerStyle {
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final LMFeedLoaderStyle? loaderStyle;

  const LMPostUploadingBannerStyle({
    this.decoration,
    this.textStyle,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.loaderStyle,
  });
  LMPostUploadingBannerStyle copyWith({
    BoxDecoration? decoration,
    TextStyle? textStyle,
    double? height,
    double? width,
    EdgeInsets? margin,
    EdgeInsets? padding,
    LMFeedLoaderStyle? loaderStyle,
  }) {
    return LMPostUploadingBannerStyle(
      decoration: decoration ?? this.decoration,
      textStyle: textStyle ?? this.textStyle,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      loaderStyle: loaderStyle ?? this.loaderStyle,
    );
  }
}
