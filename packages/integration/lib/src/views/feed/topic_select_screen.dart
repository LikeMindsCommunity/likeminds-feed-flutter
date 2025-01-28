import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template topic_selection_widget_type}
/// [LMFeedTopicSelectionWidgetType] to select the type of topic selection widget
/// to be shown
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet] to show a
/// bottom sheet with a list of topics
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionScreen] to show a
/// screen with a list of topics
/// {@endtemplate}
enum LMFeedTopicSelectionWidgetType {
  showTopicSelectionBottomSheet,
  showTopicSelectionScreen,
}

class LMFeedTopicSelectScreen extends StatefulWidget {
  static const String route = "/topicSelectScreen";

  final Function(List<LMTopicViewData>) onTopicSelected;
  final bool? isEnabled;
  final List<LMTopicViewData> selectedTopics;
  final bool showAllTopicsTile;

  const LMFeedTopicSelectScreen({
    Key? key,
    required this.onTopicSelected,
    required this.selectedTopics,
    this.showAllTopicsTile = true,
    this.isEnabled,
  }) : super(key: key);

  @override
  State<LMFeedTopicSelectScreen> createState() =>
      _LMFeedTopicSelectScreenState();
}

class _LMFeedTopicSelectScreenState extends State<LMFeedTopicSelectScreen> {
  late Size screenSize;
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  LMFeedWidgetBuilderDelegate widgetUtility =
      LMFeedCore.config.widgetBuilderDelegate;
  List<LMTopicViewData> selectedTopics = [];
  FocusNode keyboardNode = FocusNode();
  Set<String> selectedTopicId = {};
  TextEditingController searchController = TextEditingController();
  String searchType = "";
  String search = "";
  LMTopicViewData allTopics = (LMTopicViewDataBuilder()
        ..id("0")
        ..isEnabled(true)
        ..name("All Topics"))
      .build();
  final int pageSize = 20;
  LMFeedTopicBloc topicBloc = LMFeedTopicBloc();
  bool isSearching = false;
  ValueNotifier<bool> rebuildTopicsScreen = ValueNotifier<bool>(false);
  PagingController<int, LMTopicViewData> topicsPagingController =
      PagingController(firstPageKey: 1);

  int _page = 1;

  Timer? _debounce;

  void _onTextChanged(String p0) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _page = 1;
      searchType = "name";
      search = p0;
      topicsPagingController.itemList?.clear();
      topicsPagingController.itemList = selectedTopics;
      topicBloc.add(
        LMFeedGetTopicEvent(
          getTopicFeedRequest: (GetTopicsRequestBuilder()
                ..page(_page)
                ..isEnabled(widget.isEnabled)
                ..pageSize(pageSize)
                ..search(search)
                ..searchType(searchType))
              .build(),
        ),
      );
    });
  }

  bool checkSelectedTopicExistsInList(LMTopicViewData topic) {
    return selectedTopicId.contains(topic.id);
  }

  @override
  void initState() {
    super.initState();
    selectedTopics = widget.selectedTopics;
    for (LMTopicViewData topic in selectedTopics) {
      selectedTopicId.add(topic.id);
    }
    if (selectedTopicId.isNotEmpty) {
      topicsPagingController.itemList = selectedTopics;
    }
    _addPaginationListener();
  }

  @override
  void dispose() {
    searchController.dispose();
    topicBloc.close();
    keyboardNode.dispose();
    _debounce?.cancel();
    topicsPagingController.dispose();
    super.dispose();
  }

  _addPaginationListener() {
    topicsPagingController.addPageRequestListener(
      (pageKey) {
        topicBloc.add(LMFeedGetTopicEvent(
          getTopicFeedRequest: (GetTopicsRequestBuilder()
                ..page(pageKey)
                ..isEnabled(widget.isEnabled)
                ..pageSize(pageSize)
                ..search(search)
                ..searchType(searchType))
              .build(),
        ));
      },
    );
  }

  @override
  void didUpdateWidget(LMFeedTopicSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedTopics = oldWidget.selectedTopics;
    for (LMTopicViewData topic in selectedTopics) {
      selectedTopicId.add(topic.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    return widgetUtility.scaffold(
      source: LMFeedWidgetSource.topicSelectScreen,
      backgroundColor: feedThemeData.backgroundColor,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          widget.onTopicSelected(selectedTopics);
          Navigator.of(context).pop();
        },
        backgroundColor: feedThemeData.primaryColor,
        child: Icon(
          Icons.arrow_forward,
          color: feedThemeData.onPrimary,
        ),
      ),
      appBar: _defAppBar(context),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: min(
              screenSize.width, LMFeedCore.config.webConfiguration.maxWidth),
          child: BlocListener<LMFeedTopicBloc, LMFeedTopicState>(
            bloc: topicBloc,
            listener: (context, state) {
              if (state is LMFeedTopicLoadedState) {
                _page++;
                if (state.getTopicFeedResponse.topics!.isEmpty) {
                  topicsPagingController.appendLastPage([]);
                } else {
                  state.getTopicFeedResponse.topics?.removeWhere(
                      (element) => selectedTopicId.contains(element.id));
                  topicsPagingController.appendPage(
                    state.getTopicFeedResponse.topics!
                        .map((e) => LMTopicViewDataConvertor.fromTopic(e))
                        .toList(),
                    _page,
                  );
                }
              } else if (state is LMFeedTopicErrorState) {
                topicsPagingController.error = state.errorMessage;
              }
            },
            child: ValueListenableBuilder(
                valueListenable: rebuildTopicsScreen,
                builder: (context, _, __) {
                  return Column(
                    children: [
                      if (!isSearching && widget.showAllTopicsTile)
                        LMFeedTopicTile(
                          isSelected: selectedTopics.isEmpty,
                          topic: allTopics,
                          onTap: (LMTopicViewData tappedTopic) {
                            selectedTopics.clear();
                            selectedTopicId.clear();
                            rebuildTopicsScreen.value =
                                !rebuildTopicsScreen.value;
                          },
                        ),
                      Expanded(
                        child: PagedListView(
                          pagingController: topicsPagingController,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          builderDelegate:
                              PagedChildBuilderDelegate<LMTopicViewData>(
                            noItemsFoundIndicatorBuilder: (context) =>
                                const Center(
                                    child: Text(
                              "Opps, no topics found!",
                            )),
                            itemBuilder: (context, item, index) =>
                                LMFeedTopicTile(
                              isSelected: checkSelectedTopicExistsInList(item),
                              topic: item,
                              style: LMFeedTopicTileStyle.basic(
                                  containerColor: feedThemeData.container),
                              onTap: (LMTopicViewData tappedTopic) {
                                int index = selectedTopics.indexWhere(
                                    (element) => element.id == tappedTopic.id);
                                if (index != -1) {
                                  selectedTopics.removeAt(index);
                                  selectedTopicId.remove(tappedTopic.id);
                                } else {
                                  selectedTopics.add(tappedTopic);
                                  selectedTopicId.add(tappedTopic.id);
                                }
                                rebuildTopicsScreen.value =
                                    !rebuildTopicsScreen.value;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar(BuildContext context) {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: feedThemeData.container,
        height: 60,
      ),
      title: ValueListenableBuilder(
        valueListenable: rebuildTopicsScreen,
        builder: (context, _, __) {
          return isSearching
              ? Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: keyboardNode,
                    cursorColor: feedThemeData.primaryColor,
                    decoration: feedThemeData.textFieldStyle.decoration ??
                        const InputDecoration(border: InputBorder.none),
                    onChanged: (p0) {
                      _onTextChanged(p0);
                    },
                  ),
                )
              : AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    mainAxisAlignment: selectedTopics.isNotEmpty
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center, 
                    children: [
                      Text(
                        "Select Topic",
                        style: TextStyle(
                          fontSize: 16,
                          color: feedThemeData.onContainer,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if(selectedTopics.isNotEmpty)
                      ...[
                        SizedBox(height: 2),
                        Text(
                          "${selectedTopics.length} selected",
                          style: TextStyle(
                            fontSize: 12,
                            color: feedThemeData.secondaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ]
                    ],
                  ),
              );
        },
      ),
      trailing: [
        ValueListenableBuilder(
          valueListenable: rebuildTopicsScreen,
          builder: (context, _, __) {
            return GestureDetector(
              onTap: () {
                if (isSearching) {
                  if (keyboardNode.hasFocus) {
                    keyboardNode.unfocus();
                  }
                  searchController.clear();
                  search = "";
                  searchType = "";
                  _page = 1;
                  topicsPagingController.itemList?.clear();
                  topicsPagingController.itemList = selectedTopics;
                  topicBloc.add(
                    LMFeedGetTopicEvent(
                      getTopicFeedRequest: (GetTopicsRequestBuilder()
                            ..page(_page)
                            ..isEnabled(widget.isEnabled)
                            ..pageSize(pageSize)
                            ..search(search)
                            ..searchType(searchType))
                          .build(),
                    ),
                  );
                } else {
                  if (keyboardNode.canRequestFocus) {
                    keyboardNode.requestFocus();
                  }
                }
                isSearching = !isSearching;
                rebuildTopicsScreen.value = !rebuildTopicsScreen.value;
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  isSearching ? CupertinoIcons.xmark : Icons.search,
                  size: 24,
                  color: feedThemeData.onContainer,
                ),
              ),
            );
          },
        ),
      ],
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.transparent,
          margin: const EdgeInsets.only(right: 24),
          child: Icon(
            Icons.arrow_back,
            color: feedThemeData.onContainer,
          ),
        ),
      ),
    );
  }
}
