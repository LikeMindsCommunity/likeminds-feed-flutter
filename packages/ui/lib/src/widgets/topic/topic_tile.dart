import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

// Displays a tile for a topic
// The tile can be customized by passing in the required parameters
// Tile has a text and an icon
// The tile can be tapped to perform an action
// Icon is displayed only if the tile is selected
class LMFeedTopicTile extends StatelessWidget {
  // Action to perform after tapping on the tile, required
  final Function(LMTopicViewData) onTap;
  // [LMTopicViewData], consists id, topic and isEnabled boolean, required
  final LMTopicViewData topic;
  // Style for the tile, required
  final LMFeedTopicTileStyle? style;

  /// Main Axis Alignment for the row
  /// Default is [MainAxisAlignment.spaceBetween]
  /// Can be customized by passing the required value
  final MainAxisAlignment? tileRowAlignment;

  /// Boolean value to check if the tile is selected
  final bool isSelected;

  final LMFeedTextBuilder? textBuilder;
  final LMFeedIconBuilder? iconBuilder;

  const LMFeedTopicTile({
    super.key,
    required this.topic,
    required this.onTap,
    this.style,
    this.tileRowAlignment,
    this.isSelected = false,
    this.textBuilder,
    this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LMFeedTheme.instance.theme;
    return InkWell(
      onTap: () => onTap(topic),
      child: Container(
        height: style?.height,
        padding: style?.padding,
        margin: style?.margin,
        decoration: style?.decoration,
        child: Row(
          mainAxisAlignment: tileRowAlignment ?? MainAxisAlignment.spaceBetween,
          children: [
            textBuilder?.call(context, _defText(theme)) ?? _defText(theme),
            LikeMindsTheme.kHorizontalPaddingLarge,
            if (isSelected)
              iconBuilder?.call(context, _defCheckIcon(theme)) ??
                  _defCheckIcon(theme),
          ],
        ),
      ),
    );
  }

  LMFeedIcon _defCheckIcon(LMFeedThemeData theme) {
    return LMFeedIcon(
      type: LMFeedIconType.icon,
      icon: Icons.check_circle,
      style: LMFeedIconStyle(
        color: theme.primaryColor,
        size: 24,
      ),
    );
  }

  LMFeedText _defText(LMFeedThemeData theme) {
    return LMFeedText(
      text: topic.name,
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 16,
          color: theme.onContainer,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// copyWith function to get a new object of [LMFeedTopicTile]
  /// with specific single values passed
  LMFeedTopicTile copyWith({
    Function(LMTopicViewData)? onTap,
    LMTopicViewData? topic,
    LMFeedTopicTileStyle? style,
  }) {
    return LMFeedTopicTile(
      onTap: onTap ?? this.onTap,
      topic: topic ?? this.topic,
      style: style ?? this.style,
    );
  }
}

/// {@template lm_feed_topic_tile_style}
/// Style for the [LMFeedTopicTile]
/// {@endtemplate}
class LMFeedTopicTileStyle {
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  const LMFeedTopicTileStyle({
    this.height,
    this.padding,
    this.margin,
    this.decoration,
  });

  /// copyWith function to get a new object of [LMFeedTopicTileStyle]
  /// with specific single values passed
  /// If no value is passed, the current value is used
  /// If a value is passed, the new value is used
  LMFeedTopicTileStyle copyWith({
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  }) {
    return LMFeedTopicTileStyle(
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
    );
  }

  /// factory function to get the
  /// basic style for the [LMFeedTopicTile]
  factory LMFeedTopicTileStyle.basic({
    Color? containerColor,
  }) {
    return LMFeedTopicTileStyle(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: containerColor,
      ),
    );
  }
}
