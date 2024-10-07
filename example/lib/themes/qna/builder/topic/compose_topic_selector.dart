import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_selector_bottom_sheet.dart';

// FAB on compose screen and edit post screen
// to select tags
// if there are topics that are already selected
// then it will show the selected topics
class LMFeedQnAComposeScreenTopicSelector extends StatefulWidget {
  final List<LMTopicViewData> selectedTopics;

  const LMFeedQnAComposeScreenTopicSelector(
      {super.key, required this.selectedTopics});

  @override
  State<LMFeedQnAComposeScreenTopicSelector> createState() =>
      _LMFeedQnAComposeScreenTopicSelectorState();
}

class _LMFeedQnAComposeScreenTopicSelectorState
    extends State<LMFeedQnAComposeScreenTopicSelector> {
  final LMFeedThemeData feedThemeData = LMFeedCore.theme;
  List<LMTopicViewData> selectedTopics = [];

  @override
  void initState() {
    super.initState();
    selectedTopics = [...widget.selectedTopics];
  }

  @override
  void didUpdateWidget(
      covariant LMFeedQnAComposeScreenTopicSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.selectedTopics, oldWidget.selectedTopics)) {
      selectedTopics = [...widget.selectedTopics];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 90,
        width: 120,
        color: feedThemeData.container,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        margin: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LMFeedText(
                  text: "Tags",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                        color: feedThemeData.onContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.75,
                        letterSpacing: 0.25),
                  ),
                ),
                selectedTopics.isEmpty
                    ? const SizedBox.shrink()
                    : LMFeedButton(
                        onTap: () {
                          showTopicSelectorBottomSheet(context);
                        },
                        text: LMFeedText(
                          text: "Edit",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                                color: feedThemeData.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.75,
                                letterSpacing: 0.25),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 5),
            selectedTopics.isEmpty
                ? LMFeedButton(
                    style: const LMFeedButtonStyle(
                        mainAxisAlignment: MainAxisAlignment.start),
                    onTap: () {
                      if (widget.selectedTopics.isEmpty) {
                        showTopicSelectorBottomSheet(context);
                      }
                    },
                    text: const LMFeedText(text: "Select Tags"),
                  )
                : SizedBox(
                    height: 30,
                    child: ListView.builder(
                      itemCount: selectedTopics.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => LMFeedTopicChip(
                        topic: selectedTopics[index],
                        isSelected: true,
                        style: feedThemeData.topicStyle.activeChipStyle
                            ?.copyWith(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 3.0)),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void showTopicSelectorBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: 200),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        backgroundColor: feedThemeData.container,
        useRootNavigator: true,
        enableDrag: true,
        useSafeArea: true,
        builder: (context) {
          return LMFeedTopicSelectBottomSheet(
            style: feedThemeData.bottomSheetStyle,
            selectedTopics: selectedTopics,
          );
        });

    setState(() {});

    LMFeedComposeBloc.instance.selectedTopics = selectedTopics;
  }
}
