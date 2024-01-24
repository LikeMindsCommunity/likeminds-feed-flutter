import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

// This widget is used to display a topic feed bar
// A [LMFeedTopicFeedBar] displays a list of selected topics
// The [LMFeedTopicFeedBar] can be customized by passing in the required parameters
class LMFeedTopicFeedBar extends StatelessWidget {
  // Required parameters
  // List of selected topic [pass empty list if no topic is selected]
  final List<LMTopicViewData> selectedTopics;
  // Action to perform after tapping on the topic feed bar
  final Function onTap;

  final Function? onClear;
  final Function(LMTopicViewData)? onIconTap;
  final Widget? trailingIcon;
  final Function? onTrailingIconTap;
  // Whether to show divider below topic feed bar or not
  // defaults to true
  final bool showDivider;
  // Placeholder chip if no topic is selected
  final Widget? emptyTopicChip;

  /// height of topic feed bar
  final double? height;

  final LMFeedTopicChipStyle? style;

  const LMFeedTopicFeedBar({
    Key? key,
    required this.selectedTopics,
    this.onClear,
    this.onIconTap,
    required this.onTap,
    this.trailingIcon,
    this.onTrailingIconTap,
    this.showDivider = true,
    this.emptyTopicChip,
    this.style,
    this.height,
  }) : super(key: key);

  // Topic feed bar with selected topics
  // If a trailing icon is passed, it is displayed
  // at the end of the list of selected topics
  // If no trailing icon is passed, the topic
  // feed bar displays only the list of selected topics
  Widget selectedTopicsWidget(LMFeedThemeData feedTheme, double width) {
    return SizedBox(
      width: width,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: height ?? 30,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: trailingIcon == null
                      ? selectedTopics.length
                      : selectedTopics.length + 1,
                  itemBuilder: (context, index) {
                    if (index == selectedTopics.length &&
                        trailingIcon != null) {
                      return Container(
                        color: Colors.transparent,
                        child: LMFeedTopicChip(
                          topic: (LMTopicViewDataBuilder()
                                ..id("-1")
                                ..isEnabled(false)
                                ..name("name"))
                              .build(),
                          onIconTap: (tapped) {
                            onTap();
                          },
                          style: style ?? feedTheme.topicStyle.activeChipStyle,
                          isSelected: true,
                        ),
                      );
                    }
                    return Container(
                      color: Colors.transparent,
                      child: LMFeedTopicChip(
                        topic: selectedTopics[index],
                        onIconTap: onIconTap,
                        style: style,
                        isSelected: false,
                      ),
                    );
                  }),
            ),
          ),
          LikeMindsTheme.kHorizontalPaddingMedium,
          onClear == null
              ? const SizedBox()
              : GestureDetector(
                  onTap: () => onClear!(),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  // Topic feed bar with no topic selected [Placeholder chip]
  // If no placeholder chip is passed, a default placeholder chip is displayed`
  // The default placeholder chip displays "All topics" text
  Widget emptyTopicsWidget(LMFeedThemeData feedTheme) {
    return emptyTopicChip != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              emptyTopicChip!,
            ],
          )
        : Container(
            height: height,
            padding: const EdgeInsets.all(10.0),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'All topics',
                ),
                LikeMindsTheme.kHorizontalPaddingMedium,
                Icon(
                  Icons.arrow_downward,
                  size: 18,
                )
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: showDivider ? const EdgeInsets.only(bottom: 12.0) : null,
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    width: 0.1,
                    color: Colors.grey.withOpacity(0.05),
                  ),
                )
              : null,
        ),
        child: selectedTopics.isEmpty
            ? emptyTopicsWidget(feedTheme)
            : selectedTopicsWidget(feedTheme, screenSize.width),
      ),
    );
  }

  LMFeedTopicFeedBar copyWith({
    List<LMTopicViewData>? selectedTopics,
    Function? onTap,
    Function? onClear,
    Function(LMTopicViewData)? onIconTap,
    Widget? trailingIcon,
    Function? onTrailingIconTap,
    bool? showDivider,
    Widget? emptyTopicChip,
    double? height,
    LMFeedTopicChipStyle? style,
  }) {
    return LMFeedTopicFeedBar(
      selectedTopics: selectedTopics ?? this.selectedTopics,
      onTap: onTap ?? this.onTap,
      onClear: onClear ?? this.onClear,
      onIconTap: onIconTap ?? this.onIconTap,
      trailingIcon: trailingIcon ?? this.trailingIcon,
      onTrailingIconTap: onTrailingIconTap ?? this.onTrailingIconTap,
      showDivider: showDivider ?? this.showDivider,
      emptyTopicChip: emptyTopicChip ?? this.emptyTopicChip,
      height: height ?? this.height,
      style: style ?? this.style,
    );
  }
}
