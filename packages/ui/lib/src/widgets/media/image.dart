import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template feed_image}
/// A widget to display an image in a post.
/// The image can be fetched from a URL or from a file.
/// The [LMFeedImage] can be customized by passing in the required parameters
/// and can be used in a post.
/// The image can be tapped to perform an action.
/// The image can be customized by passing in the required parameters
/// and can be used in a post.
/// {@endtemplate}
class LMFeedImage extends StatelessWidget {
  const LMFeedImage({
    super.key,
    required this.image,
    this.onError,
    this.style,
    this.onMediaTap,
    this.position = 0,
  });

  final LMAttachmentViewData image;

  /// {@macro feed_error_handler}
  final LMFeedErrorHandler? onError;

  final LMFeedPostImageStyle? style;

  final Function(int)? onMediaTap;

  final int position;

  @override
  Widget build(BuildContext context) {
    LMFeedPostImageStyle inStyle =
        style ?? LMFeedTheme.instance.theme.mediaStyle.imageStyle;

    if (image.attachmentMeta.url != null) {
      return _LMFeedCloudImage(
        image: image,
        onError: onError,
        style: inStyle,
        onMediaTap: onMediaTap,
        position: position,
      );
    }

    if (image.attachmentMeta.path != null ||
        image.attachmentMeta.bytes != null) {
      return _LMFeedLocalImage(
        image: image,
        style: inStyle,
        onMediaTap: onMediaTap,
        position: position,
        onError: onError,
      );
    }
    return const SizedBox();
  }

  LMFeedImage copyWith({
    LMAttachmentViewData? image,
    LMFeedPostImageStyle? style,
    Function(String, StackTrace)? onError,
    Function(int)? onMediaTap,
  }) {
    return LMFeedImage(
      image: image ?? this.image,
      style: style ?? this.style,
      onError: onError ?? this.onError,
      onMediaTap: onMediaTap ?? this.onMediaTap,
    );
  }
}

class _LMFeedLocalImage extends StatelessWidget {
  final LMAttachmentViewData image;

  /// {@macro feed_error_handler}
  final LMFeedErrorHandler? onError;

  final LMFeedPostImageStyle style;

  final Function(int)? onMediaTap;

  final int position;
  const _LMFeedLocalImage(
      {super.key,
      required this.image,
      this.onError,
      required this.style,
      this.onMediaTap,
      this.position = 0});

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;

    if (image.attachmentMeta.bytes != null) {
      imageWidget = Image.memory(
        image.attachmentMeta.bytes!,
        height: style.height,
        width: style.width,
        fit: style.boxFit ?? BoxFit.contain,
      );
    } else if (image.attachmentMeta.path != null) {
      imageWidget = Image.file(
        File(image.attachmentMeta.path!),
        height: style.height,
        width: style.width,
        fit: style.boxFit ?? BoxFit.contain,
      );
    }

    // If the image is null, return an empty container
    if (imageWidget == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () => onMediaTap?.call(position),
      child: Container(
        padding: style.padding,
        margin: style.margin,
        decoration: BoxDecoration(
          borderRadius: style.borderRadius ?? BorderRadius.zero,
          color: style.backgroundColor,
        ),
        child: imageWidget,
      ),
    );
  }
}

class _LMFeedCloudImage extends StatelessWidget {
  final LMAttachmentViewData image;

  /// {@macro feed_error_handler}
  final LMFeedErrorHandler? onError;

  final LMFeedPostImageStyle style;

  final Function(int)? onMediaTap;

  final int position;

  const _LMFeedCloudImage(
      {super.key,
      required this.image,
      this.onError,
      required this.style,
      this.onMediaTap,
      this.position = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onMediaTap?.call(position),
      child: Container(
        padding: style.padding,
        margin: style.margin,
        decoration: BoxDecoration(
            borderRadius: style.borderRadius ?? BorderRadius.zero,
            color: style.backgroundColor),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          cacheKey: image.attachmentMeta.url!,
          height: style.height,
          width: style.width,
          imageUrl: image.attachmentMeta.url!,
          fit: style.boxFit ?? BoxFit.contain,
          fadeInDuration: const Duration(
            milliseconds: 100,
          ),
          errorWidget: (context, url, error) {
            if (onError != null) {
              onError!(error.toString(), StackTrace.empty);
            }
            return style.errorWidget ??
                Container(
                  color: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LMFeedIcon(
                        type: LMFeedIconType.icon,
                        icon: Icons.error_outline,
                        style: LMFeedIconStyle(
                          size: 24,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const LMFeedText(
                        text: "An error occurred fetching media",
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
          },
          progressIndicatorBuilder: (context, url, progress) =>
              style.shimmerWidget ?? const LMPostMediaShimmer(),
        ),
      ),
    );
  }
}

class LMFeedPostImageStyle {
  final double? height;
  final double? width;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  final Widget? loaderWidget;
  final Widget? errorWidget;
  final Widget? shimmerWidget;

  final BoxFit? boxFit;

  const LMFeedPostImageStyle({
    this.height,
    this.width,
    this.aspectRatio,
    this.borderRadius,
    this.borderColor,
    this.loaderWidget,
    this.errorWidget,
    this.shimmerWidget,
    this.boxFit,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  LMFeedPostImageStyle copyWith({
    double? height,
    double? width,
    double? aspectRatio,
    BorderRadius? borderRadius,
    Color? borderColor,
    Widget? loaderWidget,
    Widget? errorWidget,
    Widget? shimmerWidget,
    BoxFit? boxFit,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
  }) {
    return LMFeedPostImageStyle(
      height: height ?? this.height,
      width: width ?? this.width,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      loaderWidget: loaderWidget ?? this.loaderWidget,
      errorWidget: errorWidget ?? this.errorWidget,
      shimmerWidget: shimmerWidget ?? this.shimmerWidget,
      boxFit: boxFit ?? this.boxFit,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  factory LMFeedPostImageStyle.basic({Color? primaryColor}) =>
      const LMFeedPostImageStyle(
        loaderWidget: LMPostMediaShimmer(),
      );
}
