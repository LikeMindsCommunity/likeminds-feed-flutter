import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';

// Topic Search Bottom Sheet
// This widget is used to search topics and select them
// on compose screen and edit post screen
// It is used to search level 1 topics
class LMTopicSearchBottomSheet extends StatefulWidget {
  final String parentTopicId;
  final String? searchTitle;
  final String? bottomSheetTitle;
  final List<LMTopicViewData> selectedTopics;

  const LMTopicSearchBottomSheet({
    super.key,
    this.bottomSheetTitle,
    this.searchTitle,
    required this.parentTopicId,
    required this.selectedTopics,
  });

  @override
  State<LMTopicSearchBottomSheet> createState() =>
      _LMTopicSearchBottomSheetState();
}

class _LMTopicSearchBottomSheetState extends State<LMTopicSearchBottomSheet> {
  ValueNotifier<bool> rebuildActionItems = ValueNotifier<bool>(false);
  LMFeedTopicBloc lmFeedTopicBloc = LMFeedTopicBloc();
  final int pageSize = 10;
  Timer? _debounce;
  TextEditingController searchController = TextEditingController();
  Set<String> selectedTopicIds = {};
  List<LMTopicViewData> selectedTopics = [];
  PagingController<int, LMTopicViewData> topicPagingController =
      PagingController<int, LMTopicViewData>(firstPageKey: 1);

  LMFeedThemeData lmFeedThemeData = LMFeedCore.theme;

  @override
  void initState() {
    super.initState();
    addPaginationListener();
    selectedTopicIds = widget.selectedTopics.map((e) => e.id).toSet();
    selectedTopics = [...widget.selectedTopics];
  }

  void addPaginationListener() {
    topicPagingController.addPageRequestListener((pageKey) {
      String searchText = searchController.text;

      GetTopicsRequestBuilder requestBuilder = GetTopicsRequestBuilder();

      requestBuilder
        ..isEnabled(true)
        ..pageSize(10)
        ..parentIds([widget.parentTopicId]);

      if (searchText.isNotEmpty) {
        requestBuilder.search(searchText);
        requestBuilder.searchType('name');
      }

      requestBuilder.page(pageKey);

      lmFeedTopicBloc.add(
          LMFeedGetTopicEvent(getTopicFeedRequest: requestBuilder.build()));
    });
  }

  void updatePagingController(LMFeedTopicLoadedState state) {
    if (state.getTopicFeedResponse.childTopics!.isEmpty) {
      topicPagingController.appendLastPage([]);
    } else {
      List<LMTopicViewData> listOfTopics = [];

      state.getTopicFeedResponse.childTopics?[widget.parentTopicId]
          ?.forEach((value) {
        listOfTopics.add(LMTopicViewDataConvertor.fromTopic(value));
      });

      final isLastPage =
          state.getTopicFeedResponse.childTopics!.length < pageSize;
      if (isLastPage) {
        topicPagingController.appendLastPage(listOfTopics);
      } else {
        final nextPageKey = state.page + 1;
        topicPagingController.appendPage(listOfTopics, nextPageKey);
      }
    }
  }

  void searchTextWatcher() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      topicPagingController.itemList?.clear();
      topicPagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, widget.selectedTopics);
        return Future.value(false);
      },
      child: Container(
        color: lmFeedThemeData.container,
        padding: const EdgeInsets.all(20.0),
        child: BlocListener(
          bloc: lmFeedTopicBloc,
          listener: (context, state) {
            if (state is LMFeedTopicLoadedState) {
              updatePagingController(state);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: lmFeedThemeData.container,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.bottomSheetTitle != null)
                      LMFeedText(
                        text: widget.bottomSheetTitle!,
                        style: const LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder(
                      valueListenable: rebuildActionItems,
                      builder: (context, _, __) => selectedTopicIds.isEmpty
                          ? const SizedBox.shrink()
                          : LMFeedButton(
                              onTap: () {
                                selectedTopicIds.clear();
                                selectedTopics.clear();
                                rebuildActionItems.value =
                                    !rebuildActionItems.value;
                              },
                              text: LMFeedText(
                                text: "Clear All",
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    color: lmFeedThemeData.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: lmFeedThemeData.disabledColor,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0),
                    child: Row(
                      children: [
                        LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: CupertinoIcons.search,
                          style: LMFeedIconStyle(
                            color: lmFeedThemeData.onContainer,
                            size: 20,
                            boxPadding: 0,
                            boxSize: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              searchTextWatcher();
                            },
                            decoration: lmFeedThemeData
                                .textFieldStyle.decoration
                                ?.copyWith(
                                    hintText: widget.searchTitle ?? "Search"),
                          ),
                        ),
                      ],
                    ),
                  )),
              ValueListenableBuilder(
                valueListenable: rebuildActionItems,
                builder: (context, _, __) {
                  if (selectedTopicIds.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  List<LMTopicViewData> topics = selectedTopics
                      .where(
                          (element) => element.parentId == widget.parentTopicId)
                      .toList();

                  return Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 10,
                        );
                      },
                      itemCount: topics.length,
                      itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: lmFeedThemeData.disabledColor, width: 1.5),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            LMFeedText(
                              text: topics[index].name,
                              style: const LMFeedTextStyle(
                                  textStyle: TextStyle(
                                color: textPrimary,
                              )),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            LMFeedButton(
                              onTap: () {
                                selectedTopicIds.remove(topics[index].id);
                                selectedTopics.removeWhere(
                                  (element) => element.id == topics[index].id,
                                );

                                rebuildActionItems.value =
                                    !rebuildActionItems.value;
                              },
                              style: const LMFeedButtonStyle(
                                icon: LMFeedIcon(
                                  type: LMFeedIconType.icon,
                                  icon: CupertinoIcons.xmark,
                                  style: LMFeedIconStyle(
                                    color: textPrimary,
                                    size: 14,
                                    boxPadding: 0,
                                    boxSize: 14,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 275,
                child: ValueListenableBuilder(
                    valueListenable: rebuildActionItems,
                    builder: (context, _, __) {
                      return PagedListView.separated(
                        separatorBuilder: (context, index) {
                          return const Divider(
                            height: 1.5,
                            color: dividerLight,
                          );
                        },
                        pagingController: topicPagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<LMTopicViewData>(
                          firstPageProgressIndicatorBuilder: (context) =>
                              const LMFeedLoader(),
                          itemBuilder: (context, item, index) {
                            bool isSelected =
                                selectedTopicIds.contains(item.id);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedTopicIds.remove(item.id);
                                    selectedTopics.removeWhere(
                                        (element) => element.id == item.id);
                                  } else {
                                    selectedTopicIds.add(item.id);
                                    selectedTopics.add(item);
                                  }

                                  setState(() {});
                                });
                              },
                              leading: Checkbox(
                                value: isSelected,
                                side: isSelected
                                    ? null
                                    : const BorderSide(
                                        color: textPrimary, width: 1.5),
                                activeColor: lmFeedThemeData.primaryColor,
                                checkColor: lmFeedThemeData.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedTopicIds.remove(item.id);
                                      selectedTopics.removeWhere(
                                          (element) => element.id == item.id);
                                    } else {
                                      selectedTopicIds.add(item.id);
                                      selectedTopics.add(item);
                                    }
                                    // rebuildActionItems.value =
                                    //     !rebuildActionItems.value;

                                    setState(() {});
                                  });
                                },
                              ),
                              title: LMFeedText(
                                text: item.name,
                                style: const LMFeedTextStyle(
                                    textStyle: TextStyle(
                                  color: textPrimary,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: LMFeedButton(
                        onTap: () {
                          Navigator.pop(context, widget.selectedTopics);
                        },
                        style: LMFeedButtonStyle(
                          borderRadius: 50.0,
                          border: Border.all(
                            color: lmFeedThemeData.onContainer,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.all(15.0),
                        ),
                        text: LMFeedText(
                          text: "Cancel",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              color: lmFeedThemeData.onContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: LMFeedButton(
                      onTap: () {
                        Navigator.pop(context, selectedTopics);
                      },
                      style: LMFeedButtonStyle(
                        borderRadius: 50.0,
                        backgroundColor: lmFeedThemeData.onContainer,
                        padding: const EdgeInsets.all(15.0),
                      ),
                      text: LMFeedText(
                        text: "Apply",
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: lmFeedThemeData.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
