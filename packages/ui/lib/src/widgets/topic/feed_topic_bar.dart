import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedTopicBar extends StatelessWidget {
  final List<LMTopicViewData> selectedTopics;
  final VoidCallback openTopicSelector;
  final Function(LMTopicViewData)? removeTopicFromSelection;

  const LMFeedTopicBar({
    super.key,
    required this.selectedTopics,
    required this.openTopicSelector,
    this.removeTopicFromSelection,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedTheme.of(context);
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: GestureDetector(
        onTap: openTopicSelector,
        child: Row(
          children: [
            selectedTopics.isEmpty
                ? LMFeedTopicChip(
                    topic: (LMTopicViewDataBuilder()
                          ..id("0")
                          ..isEnabled(true)
                          ..name("All Topic"))
                        .build(),
                    style: feedThemeData.topicStyle.inactiveChipStyle,
                    isSelected: false,
                  )
                : selectedTopics.length == 1
                    ? LMFeedTopicChip(
                        topic: (LMTopicViewDataBuilder()
                              ..id(selectedTopics.first.id)
                              ..isEnabled(selectedTopics.first.isEnabled)
                              ..name(selectedTopics.first.name))
                            .build(),
                        style: feedThemeData.topicStyle.inactiveChipStyle,
                        isSelected: false,
                      )
                    : LMFeedTopicChip(
                        topic: (LMTopicViewDataBuilder()
                              ..id("0")
                              ..isEnabled(true)
                              ..name("Topics"))
                            .build(),
                        isSelected: false,
                        style: feedThemeData.topicStyle.inactiveChipStyle
                            ?.copyWith(
                          icon: Row(
                            children: [
                              LikeMindsTheme.kHorizontalPaddingXSmall,
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                child: LMFeedText(
                                  text: selectedTopics.length.toString(),
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      color: feedThemeData.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              LikeMindsTheme.kHorizontalPaddingSmall,
                              LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: CupertinoIcons.chevron_down,
                                style: LMFeedIconStyle(
                                  size: 16,
                                  color: feedThemeData.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
