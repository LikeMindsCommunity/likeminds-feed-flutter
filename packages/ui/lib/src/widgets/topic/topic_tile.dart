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
  // Alignment of the row of the tile, defaults to
  // MainAxisAlignment.spaceBetween
  final MainAxisAlignment? tileRowAlignment;
  // Background color of the tile, defaults to null
  final Color? backgroundColor;
  // Height of the tile, defaults to null
  final double? height;
  final Icon icon;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsets? padding;
  // Whether the tile is selected or not, required
  final bool isSelected;
  // Text to be displayed in the tile, required
  final LMFeedText text;
  // [LMTopicViewData], consists id, topic and isEnabled boolean, required
  final LMTopicViewData topic;

  const LMFeedTopicTile({
    Key? key,
    required this.topic,
    required this.icon,
    this.tileRowAlignment,
    this.height,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor,
    this.borderWidth,
    this.padding,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(topic),
      child: Container(
        height: height,
        padding: padding,
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: tileRowAlignment ?? MainAxisAlignment.spaceBetween,
          children: [
            text,
            kHorizontalPaddingLarge,
            isSelected ? icon : const SizedBox()
          ],
        ),
      ),
    );
  }
}
