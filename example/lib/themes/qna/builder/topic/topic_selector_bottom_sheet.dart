import 'dart:async';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_search_bottom_sheet.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';

// This bottom sheet is render upon clicking the
// select tags fab on create post and edit post screen
// It show the selected topic and also allow user to
// select more topics
// Clicking on more button opens topic search bottom sheet
class LMFeedTopicSelectBottomSheet extends StatefulWidget {
  final LMFeedBottomSheetStyle? style;
  final List<LMTopicViewData> selectedTopics;

  const LMFeedTopicSelectBottomSheet({
    super.key,
    this.style,
    this.selectedTopics = const [],
  });

  @override
  State<LMFeedTopicSelectBottomSheet> createState() =>
      _LMFeedTopicSelectBottomSheetState();
}

class _LMFeedTopicSelectBottomSheetState
    extends State<LMFeedTopicSelectBottomSheet> {
  Set<String> selectedTopicIds = {};
  List<LMTopicViewData> selectedTopics = [];
  ValueNotifier<bool> chipBuilderNotifier = ValueNotifier(false);

  Future<GetTopicsResponse>? getParentTopics;
  Future<GetTopicsResponse>? getChildTopics;
  LMFeedThemeData feedTheme = LMFeedCore.theme;

  @override
  void initState() {
    super.initState();
    selectedTopics = [...widget.selectedTopics];
    selectedTopicIds = widget.selectedTopics.map((e) => e.id).toSet();
    getParentTopics = LMQnAFeedUtils.getParentTopicsFromCache()
      ..then((value) {
        if (value.success) {
          List<String> parentIds = value.topics!.map((e) => e.id).toList();

          getChildTopics = LMQnAFeedUtils.getChildTopics(parentIds)
            ..then((value) {
              if (!value.success) {
                LMFeedCore.showSnackBar(
                  context,
                  value.errorMessage ?? '',
                  LMFeedWidgetSource.topicSelectScreen,
                );
              }
              return value;
            });
        }
        return value;
      });
  }

  @override
  void didUpdateWidget(covariant LMFeedTopicSelectBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedTopics = [...widget.selectedTopics];
    selectedTopicIds = widget.selectedTopics.map((e) => e.id).toSet();
    getParentTopics = LMQnAFeedUtils.getParentTopicsFromCache()
      ..then((value) {
        if (value.success) {
          List<String> parentIds = value.topics!.map((e) => e.id).toList();

          getChildTopics = LMQnAFeedUtils.getChildTopics(parentIds)
            ..then((value) {
              if (!value.success) {
                LMFeedCore.showSnackBar(
                  context,
                  value.errorMessage ?? '',
                  LMFeedWidgetSource.topicSelectScreen,
                );
              }
              return value;
            });
        }
        return value;
      });
  }

  @override
  void dispose() {
    chipBuilderNotifier.dispose();
    super.dispose();
  }

  void addOrRemoveTopic(LMTopicViewData topic) {
    if (selectedTopicIds.contains(topic.id)) {
      selectedTopics.removeWhere((e) => e.id == topic.id);
      selectedTopicIds.remove(topic.id);
    } else {
      selectedTopics.add(topic);
      selectedTopicIds.add(topic.id);
    }

    chipBuilderNotifier.value = !chipBuilderNotifier.value;
  }

  bool checkIfTopicSelected(LMTopicViewData topic) =>
      selectedTopicIds.contains(topic.id);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: false,
            pinned: true,
            backgroundColor: feedTheme.container,
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: LMFeedText(
                text: "Select Tags",
                style: LMFeedTextStyle(
                  textAlign: TextAlign.left,
                  textStyle: TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    color: feedTheme.onContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            actions: [
              ValueListenableBuilder(
                valueListenable: chipBuilderNotifier,
                builder: (context, _, __) {
                  if (selectedTopics.isNotEmpty) {
                    return LMFeedButton(
                      onTap: () {
                        selectedTopics.clear();
                        selectedTopicIds.clear();
                        chipBuilderNotifier.value = !chipBuilderNotifier.value;
                      },
                      text: LMFeedText(
                        text: "Deselect All",
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: feedTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 15),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder(
                future: getParentTopics,
                builder: (context, parentTopicSnapshot) {
                  if (parentTopicSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LMFeedLoader();
                  } else if (parentTopicSnapshot.connectionState ==
                          ConnectionState.done &&
                      parentTopicSnapshot.data != null &&
                      parentTopicSnapshot.data!.success) {
                    List<LMTopicViewData> parentTopics = parentTopicSnapshot
                            .data!.topics
                            ?.map((e) => LMTopicViewDataConvertor.fromTopic(e))
                            .toList() ??
                        [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (parentTopics.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LMFeedText(
                                text: parentTopics.first.name,
                                style: const LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              FutureBuilder(
                                  future: getChildTopics,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const LMFeedLoader();
                                    } else if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null &&
                                        snapshot.data!.success) {
                                      LMTopicViewData parentTopic =
                                          parentTopics.first;

                                      List<LMTopicViewData> childTopics =
                                          snapshot.data!
                                                  .childTopics![parentTopic.id]
                                                  ?.map((e) =>
                                                      LMTopicViewDataConvertor
                                                          .fromTopic(e))
                                                  .toList() ??
                                              [];

                                      return ValueListenableBuilder<bool>(
                                          valueListenable: chipBuilderNotifier,
                                          builder: (context,
                                              changedSelectedTopics, child) {
                                            List<LMTopicViewData> allTopics = [
                                              ...selectedTopics.where(
                                                  (element) =>
                                                      element.parentId ==
                                                      parentTopic.id)
                                            ];
                                            allTopics.addAll(childTopics.where(
                                                (element) => !selectedTopicIds
                                                    .contains(element.id)));

                                            return Wrap(children: [
                                              ...allTopics
                                                  .map((e) => topicChip(e))
                                                  .take(6),
                                              if (parentTopic.totalChildCount! >
                                                  6)
                                                loadMoreTopicSearchSheetOpenButton(
                                                    parentTopics.first.id,
                                                    "Destination",
                                                    "Search Country")
                                            ]);
                                          });
                                    }

                                    return const SizedBox();
                                  }),
                            ],
                          ),
                        const SizedBox(height: 15),
                        if (parentTopics.length >= 2)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LMFeedText(
                                text: parentTopics[1].name,
                                style: const LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              FutureBuilder(
                                  future: getChildTopics,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const LMFeedLoader();
                                    } else if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null &&
                                        snapshot.data!.success) {
                                      GetTopicsResponse response =
                                          snapshot.data!;

                                      LMTopicViewData parentTopic =
                                          parentTopics[1];

                                      List<LMTopicViewData> childTopics =
                                          response.childTopics![parentTopic.id]
                                                  ?.map((e) =>
                                                      LMTopicViewDataConvertor
                                                          .fromTopic(e))
                                                  .toList() ??
                                              [];

                                      return ValueListenableBuilder(
                                          valueListenable: chipBuilderNotifier,
                                          builder:
                                              (context, changedTopics, child) {
                                            List<LMTopicViewData> allTopics = [
                                              ...selectedTopics.where(
                                                  (element) =>
                                                      element.parentId ==
                                                      parentTopic.id)
                                            ];
                                            allTopics.addAll(childTopics.where(
                                                (element) => !selectedTopicIds
                                                    .contains(element.id)));

                                            return Wrap(
                                              children: [
                                                ...allTopics
                                                    .map((e) => topicChip(e))
                                                    .take(6),
                                                if (parentTopic
                                                        .totalChildCount! >
                                                    6)
                                                  loadMoreTopicSearchSheetOpenButton(
                                                      parentTopics.last.id,
                                                      "Interest",
                                                      "Search Interest")
                                              ],
                                            );
                                          });
                                    }
                                    return const SizedBox();
                                  }),
                            ],
                          )
                      ],
                    );
                  }
                  return const SizedBox();
                }),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 15),
          ),
          SliverToBoxAdapter(
            child: LMFeedButton(
              onTap: () {
                widget.selectedTopics.clear();
                widget.selectedTopics.addAll(selectedTopics);

                Navigator.of(context).pop();
              },
              style: const LMFeedButtonStyle(
                  padding: EdgeInsets.all(15.0),
                  backgroundColor: Colors.black87,
                  borderRadius: 50.0),
              text: const LMFeedText(
                text: "Done",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showTopicSearchBottomSheet(
      String parentTopicId, String parentTitle, String searchTitle) async {
    List<LMTopicViewData>? topics = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: LMTopicSearchBottomSheet(
            parentTopicId: parentTopicId,
            selectedTopics: selectedTopics,
            bottomSheetTitle: parentTitle,
            searchTitle: searchTitle,
          ),
        );
      },
    );

    if (topics != null) {
      selectedTopics = [...topics];
      selectedTopicIds = selectedTopics.map((e) => e.id).toSet();
    }

    chipBuilderNotifier.value = !chipBuilderNotifier.value;
  }

  // child topic chip
  Widget topicChip(LMTopicViewData topic) {
    bool isTopicSelected = checkIfTopicSelected(topic);

    EdgeInsets chipMargin = const EdgeInsets.only(bottom: 10.0, right: 5.0);
    EdgeInsets chipPadding =
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    TextStyle chipTextStyle = const TextStyle(
        color: textPrimary, fontSize: 12, fontWeight: FontWeight.w400);

    return LMFeedTopicChip(
      topic: topic,
      isSelected: isTopicSelected,
      onTap: (context, _) {
        addOrRemoveTopic(topic);
      },
      style: isTopicSelected
          ? feedTheme.topicStyle.activeChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
              borderColor: feedTheme.primaryColor,
              showBorder: true,
            )
          : feedTheme.topicStyle.inactiveChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
            ),
    );
  }

  Widget loadMoreTopicSearchSheetOpenButton(
      String parentTopicId, String parentTitle, String searchTitle) {
    EdgeInsets chipMargin = const EdgeInsets.only(bottom: 10.0, right: 5.0);
    EdgeInsets chipPadding =
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    TextStyle chipTextStyle = const TextStyle(
        color: textPrimary, fontSize: 12, fontWeight: FontWeight.w400);

    return GestureDetector(
      onTap: () {
        showTopicSearchBottomSheet(parentTopicId, parentTitle, searchTitle);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: feedTheme.disabledColor,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: chipPadding,
        margin: chipMargin,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: textPrimary,
              size: 12,
            ),
            LMFeedText(
              text: "More",
              style: LMFeedTextStyle(
                textStyle: chipTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
