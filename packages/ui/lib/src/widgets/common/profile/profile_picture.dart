import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/widgets.dart';

class LMFeedProfilePicture extends StatelessWidget {
  const LMFeedProfilePicture({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.onTap,
    this.style,
  });

  final String? imageUrl;
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
              : LMFeedTheme.of(context).primaryColor,
          image: imageUrl != null && imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Center(
                child: LMFeedText(
                  text: getInitials(fallbackText),
                  style: inStyle.fallbackTextStyle ??
                      LMFeedTextStyle(
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

  LMProfilePicture copyWith(
    String? imageUrl,
    String? fallbackText,
    Function()? onTap,
    LMFeedProfilePictureStyle? style,
  ) {
    return LMProfilePicture(
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

  const LMFeedProfilePictureStyle({
    this.size = 48,
    this.borderRadius = 24,
    this.border = 0,
    this.backgroundColor,
    this.boxShape,
    this.fallbackTextStyle,
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
}
