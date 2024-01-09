import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';

class LMFeedImage extends StatefulWidget {
  const LMFeedImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.height,
    this.width,
    this.aspectRatio,
    this.borderRadius,
    this.borderColor,
    this.loaderWidget,
    this.errorWidget,
    this.shimmerWidget,
    this.boxFit,
    this.onError,
  }) : assert(imageUrl != null || imageFile != null);

  final String? imageUrl;
  final File? imageFile;

  final double? height;
  final double? width;
  final double? aspectRatio;
  final double? borderRadius;
  final Color? borderColor;

  final Widget? loaderWidget;
  final Widget? errorWidget;
  final Widget? shimmerWidget;

  final BoxFit? boxFit;
  final Function(String, StackTrace)? onError;

  @override
  State<LMFeedImage> createState() => _LMImageState();
}

class _LMImageState extends State<LMFeedImage> {
  @override
  Widget build(BuildContext context) {
    return widget.imageUrl != null
        ? ClipRRect(
            child: CachedNetworkImage(
              cacheKey: widget.imageUrl!,
              height: widget.height,
              width: widget.width,
              imageUrl: widget.imageUrl!,
              fit: widget.boxFit ?? BoxFit.contain,
              fadeInDuration: const Duration(
                milliseconds: 100,
              ),
              errorWidget: (context, url, error) {
                if (widget.onError != null) {
                  widget.onError!(error.toString(), StackTrace.empty);
                }
                return widget.errorWidget ??
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
                  widget.shimmerWidget ?? const LMPostMediaShimmer(),
            ),
          )
        : widget.imageFile != null
            ? ClipRRect(
                child: Image.file(
                  widget.imageFile!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.boxFit ?? BoxFit.contain,
                ),
              )
            : const SizedBox();
  }
}
