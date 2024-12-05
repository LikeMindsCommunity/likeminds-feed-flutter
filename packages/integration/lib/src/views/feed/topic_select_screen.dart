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
/// defaults to [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet]
/// if not provided
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

  const LMFeedTopicSelectScreen({
    Key? key,
    required this.onTopicSelected,
    required this.selectedTopics,
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
    if (selectedTopics.isEmpty) {
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
    }
    _addPaginationListener();
    topicsPagingController.itemList = selectedTopics;
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
    selectedTopics = widget.selectedTopics;
    topicsPagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    return widgetUtility.scaffold(
      source: LMFeedWidgetSource.topicSelectScreen,
      backgroundColor: feedThemeData.backgroundColor,
      floatingActionButton: FloatingActionButton(
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
      appBar: LMFeedAppBar(
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Topic",
                        style: TextStyle(
                          fontSize: 14,
                          color: feedThemeData.onContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      LikeMindsTheme.kVerticalPaddingSmall,
                      Text(
                        "${selectedTopics.length} selected",
                        style: TextStyle(
                          fontSize: 14,
                          color: feedThemeData.onContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
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
                    size: 18,
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
      ),
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
                      isSearching
                          ? const SizedBox()
                          : LMFeedTopicTile(
                              isSelected: selectedTopics.isEmpty,
                              height: 50,
                              topic: allTopics,
                              text: LMFeedText(
                                text: allTopics.name,
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    color: feedThemeData.onContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              backgroundColor: feedThemeData.container,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 16.0),
                              icon: Icon(
                                Icons.check_circle,
                                color: feedThemeData.primaryColor,
                              ),
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
                              height: 50,
                              text: LMFeedText(
                                text: item.name,
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    color: feedThemeData.onContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              backgroundColor: feedThemeData.container,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 16.0),
                              icon: Icon(
                                Icons.check_circle,
                                color: feedThemeData.primaryColor,
                              ),
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
}
