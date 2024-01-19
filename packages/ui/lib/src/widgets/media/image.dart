import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedPostImage extends StatefulWidget {
  const LMFeedPostImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.onError,
    this.style,
  }) : assert(imageUrl != null || imageFile != null);

  final String? imageUrl;
  final File? imageFile;

  final Function(String, StackTrace)? onError;

  final LMFeedPostImageStyle? style;

  @override
  State<LMFeedPostImage> createState() => _LMImageState();

  LMFeedPostImage copyWith({
    String? imageUrl,
    File? imageFile,
    LMFeedPostImageStyle? style,
    Function(String, StackTrace)? onError,
  }) {
    return LMFeedPostImage(
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      style: style ?? this.style,
      onError: onError ?? this.onError,
    );
  }
}

class _LMImageState extends State<LMFeedPostImage> {
  LMFeedPostImageStyle? style;

  @override
  Widget build(BuildContext context) {
    style = widget.style ?? LMFeedTheme.of(context).mediaStyle.imageStyle;
    return widget.imageUrl != null
        ? ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: style!.borderRadius ?? BorderRadius.zero,
            child: CachedNetworkImage(
              cacheKey: widget.imageUrl!,
              height: style!.height,
              width: style!.width,
              imageUrl: widget.imageUrl!,
              fit: style!.boxFit ?? BoxFit.contain,
              fadeInDuration: const Duration(
                milliseconds: 100,
              ),
              errorWidget: (context, url, error) {
                if (widget.onError != null) {
                  widget.onError!(error.toString(), StackTrace.empty);
                }
                return style!.errorWidget ??
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
                  style!.shimmerWidget ?? const LMPostMediaShimmer(),
            ),
          )
        : widget.imageFile != null
            ? ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: style!.borderRadius ?? BorderRadius.zero,
                child: Image.file(
                  widget.imageFile!,
                  height: style!.height,
                  width: style!.width,
                  fit: style!.boxFit ?? BoxFit.contain,
                ),
              )
            : const SizedBox();
  }
}

class LMFeedPostImageStyle {
  final double? height;
  final double? width;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final Color? borderColor;

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
    );
  }

  factory LMFeedPostImageStyle.basic({Color? primaryColor}) =>
      const LMFeedPostImageStyle(
        loaderWidget: LMPostMediaShimmer(),
      );
}
