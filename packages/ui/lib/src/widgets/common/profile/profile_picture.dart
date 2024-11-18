import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedProfilePicture extends StatelessWidget {
  const LMFeedProfilePicture({
    super.key,
    this.imageUrl,
    this.filePath,
    this.bytes,
    required this.fallbackText,
    this.onTap,
    this.style,
  });

  final String? imageUrl;
  final String? filePath;
  final Uint8List? bytes;
  final String fallbackText;
  final Function()? onTap;
  final LMFeedProfilePictureStyle? style;

  @override
  Widget build(BuildContext context) {
    final inStyle = style ?? LMFeedProfilePictureStyle.basic();
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!();
      },
      child: Container(
        height: inStyle.size,
        width: inStyle.size,
        padding: inStyle.padding,
        margin: inStyle.margin,
        decoration: BoxDecoration(
          borderRadius: inStyle.boxShape == null
              ? BorderRadius.circular(inStyle.borderRadius ?? 0)
              : null,
          border: Border.all(
            color: Colors.white,
            width: inStyle.border ?? 0,
          ),
          shape: inStyle.boxShape ?? BoxShape.rectangle,
          color: imageUrl != null && imageUrl!.isNotEmpty
              ? Colors.grey.shade300
              : LMFeedTheme.instance.theme.primaryColor,
          image: bytes != null
              ? DecorationImage(
                  image: MemoryImage(bytes!),
                  fit: BoxFit.cover,
                )
              : filePath != null
                  ? DecorationImage(
                      image: FileImage(File(filePath!)),
                      fit: BoxFit.cover,
                    )
                  : imageUrl != null && imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
        ),
        child: (imageUrl == null || imageUrl!.isEmpty) && filePath == null
            ? Center(
                child: LMFeedText(
                  text: getInitials(fallbackText).toUpperCase(),
                  style: inStyle.fallbackTextStyle ??
                      LMFeedTextStyle(
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize:
                              inStyle.size != null ? inStyle.size! / 2 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              )
            : null,
      ),
    );
  }

  LMFeedProfilePicture copyWith({
    String? imageUrl,
    String? fallbackText,
    Function()? onTap,
    LMFeedProfilePictureStyle? style,
  }) {
    return LMFeedProfilePicture(
      fallbackText: fallbackText ?? this.fallbackText,
      imageUrl: imageUrl ?? this.imageUrl,
      onTap: onTap ?? this.onTap,
      style: style ?? this.style,
    );
  }
}

class LMFeedProfilePictureStyle {
  final double? size;
  final LMFeedTextStyle? fallbackTextStyle;
  final double? borderRadius;
  final double? border;
  final Color? backgroundColor;
  final BoxShape? boxShape;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const LMFeedProfilePictureStyle({
    this.size = 48,
    this.borderRadius = 24,
    this.border = 0,
    this.backgroundColor,
    this.boxShape,
    this.fallbackTextStyle,
    this.padding,
    this.margin,
  });

  factory LMFeedProfilePictureStyle.basic() {
    return const LMFeedProfilePictureStyle(
      backgroundColor: Colors.blue,
      boxShape: BoxShape.circle,
      fallbackTextStyle: LMFeedTextStyle(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  LMFeedProfilePictureStyle copyWith({
    double? size,
    LMFeedTextStyle? fallbackTextStyle,
    double? borderRadius,
    double? border,
    Color? backgroundColor,
    BoxShape? boxShape,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return LMFeedProfilePictureStyle(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShape: boxShape ?? this.boxShape,
      fallbackTextStyle: fallbackTextStyle ?? this.fallbackTextStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }
}
