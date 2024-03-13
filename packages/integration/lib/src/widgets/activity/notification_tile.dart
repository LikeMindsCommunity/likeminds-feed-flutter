import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedNotificationTile extends StatelessWidget {
  final LMNotificationFeedItemViewData notificationItemViewData;
  final LMFeedNotificationTileStyle? style;
  final VoidCallback? onTap;
  ValueNotifier<bool> _rebuild = ValueNotifier(false);

  LMFeedNotificationTile({
    Key? key,
    required this.notificationItemViewData,
    this.style,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _theme = LMFeedCore.theme;
    debugPrint(_theme.contentStyle.headingStyle?.color?.value.toString());
    return ValueListenableBuilder(
        valueListenable: _rebuild,
        builder: (context, _, __) {
          return LMFeedTile(
              style: style?.copyWith(
                backgroundColor: notificationItemViewData.isRead
                    ? style?.backgroundColor
                    : style?.activeBackgroundColor,
              ),
              onTap: () {
                onTap?.call();
                notificationItemViewData.isRead = true;
                _rebuild.value = !_rebuild.value;
              },
              leading: LMFeedProfilePicture(
                  imageUrl: notificationItemViewData.actionBy.last.imageUrl,
                  fallbackText: notificationItemViewData.actionBy.last.name,
                  style: LMFeedProfilePictureStyle(
                    size: 35,
                  )),
              title: RichText(
                text: TextSpan(
                  children: LMFeedTaggingHelper.extractNotificationTags(
                    notificationItemViewData.activityText,
                    normalTextStyle: TextStyle(
                      color: _theme.contentStyle.headingStyle?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      height: 1.5,
                      letterSpacing: 0.15,
                    ),
                    tagTextStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: _theme.primaryColor,
                      height: 1.5,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 5),
                child: LMFeedText(
                  text: LMFeedTimeAgo.instance
                      .format(notificationItemViewData.updatedAt),
                  style: LMFeedTextStyle(
                    maxLines: 1,
                    textStyle: TextStyle(
                      color: Color(0xff5A6068),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ));
        });
  }
}

class LMFeedNotificationTileStyle extends LMFeedTileStyle {
  final Color? activeBackgroundColor;

  const LMFeedNotificationTileStyle({
    this.activeBackgroundColor,
    super.backgroundColor,
    super.border,
    super.borderRadius,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.padding,
    super.height,
    super.width,
    super.margin,
  });

  factory LMFeedNotificationTileStyle.basic() {
    final baseStyle = LMFeedTileStyle.basic();
    return LMFeedNotificationTileStyle(
      activeBackgroundColor: Colors.grey,
      backgroundColor: baseStyle.backgroundColor,
      border: baseStyle.border,
      borderRadius: baseStyle.borderRadius,
      mainAxisAlignment: baseStyle.mainAxisAlignment,
      crossAxisAlignment: baseStyle.crossAxisAlignment,
      padding: baseStyle.padding,
      height: baseStyle.height,
      width: baseStyle.width,
      margin: baseStyle.margin,
    );
  }

  LMFeedNotificationTileStyle copyWith({
    Color? activeBackgroundColor,
    Color? backgroundColor,
    Border? border,
    double? borderRadius,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    EdgeInsets? padding,
    double? height,
    double? width,
    double? margin,
  }) {
    return LMFeedNotificationTileStyle(
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
    );
  }
}
