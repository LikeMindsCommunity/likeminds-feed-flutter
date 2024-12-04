import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_notification_tile}
/// Notification Tile Widget,
/// Used to display the notification item in the notification feed.
/// {@endtemplate}
class LMFeedNotificationTile extends StatelessWidget {
  /// Notification Item View Data
  final LMNotificationFeedItemViewData notificationItemViewData;

  /// Style for the Notification Tile
  final LMFeedNotificationTileStyle? style;

  /// OnTap callback for the Notification Tile
  final VoidCallback? onTap;

  /// Rebuild notifier
  final ValueNotifier<bool> _rebuild = ValueNotifier(false);

  /// Profile Picture Builder
  final LMFeedProfilePictureBuilder? profilePictureBuilder;

  /// copyWith method for LMFeedNotificationTile
  LMFeedNotificationTile copyWith({
    LMNotificationFeedItemViewData? notificationItemViewData,
    LMFeedNotificationTileStyle? style,
    VoidCallback? onTap,
    LMFeedProfilePictureBuilder? profilePictureBuilder,
  }) {
    return LMFeedNotificationTile(
      notificationItemViewData:
          notificationItemViewData ?? this.notificationItemViewData,
      style: style ?? this.style,
      onTap: onTap ?? this.onTap,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
    );
  }

  /// {@macro lm_feed_notification_tile}
  LMFeedNotificationTile({
    super.key,
    required this.notificationItemViewData,
    this.style,
    this.onTap,
    this.profilePictureBuilder,
  });
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
            leading: _defProfilePicture(),
            title: RichText(
              text: TextSpan(
                children: LMFeedTaggingHelper.extractNotificationTags(
                  notificationItemViewData.activityText,
                  normalTextStyle: TextStyle(
                    color: _theme.onContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 0.15,
                  ),
                  tagTextStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: _theme.onContainer,
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
                  ),
                ),
              ),
            ));
      },
    );
  }

  LMFeedProfilePicture _defProfilePicture() {
    return LMFeedProfilePicture(
        imageUrl: notificationItemViewData.actionBy.last.imageUrl,
        fallbackText: notificationItemViewData.actionBy.last.name,
        style: LMFeedProfilePictureStyle(
          size: 35,
        ));
  }
}

/// {@template lm_feed_notification_tile_style}
/// Style for the Notification Tile
/// {@endtemplate}
class LMFeedNotificationTileStyle extends LMFeedTileStyle {
  /// Background Color for the active notification
  final Color? activeBackgroundColor;

  /// {@macro lm_feed_notification_tile_style}
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

  /// Basic Style for the Notification Tile
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
