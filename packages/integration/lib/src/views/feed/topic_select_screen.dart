import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedTopicSelectScreen extends StatefulWidget {
  static const String route = "/topicSelectScreen";

  final Function(List<LMTopicViewData>) onTopicSelected;
  final bool? isEnabled;

  const LMFeedTopicSelectScreen({
    Key? key,
    required this.onTopicSelected,
    this.isEnabled,
  }) : super(key: key);

  @override
  State<LMFeedTopicSelectScreen> createState() =>
      _LMFeedTopicSelectScreenState();
}

class _LMFeedTopicSelectScreenState extends State<LMFeedTopicSelectScreen> {
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  LMFeedWidgetUtility widgetUtility = LMFeedWidgetUtility.instance;
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
    selectedTopics = [...LMFeedBloc.instance.selectedTopics];
    for (LMTopicViewData topic in selectedTopics) {
      selectedTopicId.add(topic.id);
    }
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
    _addPaginationListener();
  }

  @override
  void dispose() {
    searchController.dispose();
    topicBloc.close();
    keyboardNode.dispose();
    _debounce?.cancel();
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
    selectedTopics = [...LMFeedBloc.instance.selectedTopics];
  }

  @override
  Widget build(BuildContext context) {
    return widgetUtility.scaffold(
      source: LMFeedWidgetSource.topicSelectScreen,
      backgroundColor: feedThemeData.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onTopicSelected(selectedTopics);
          //locator<NavigationService>().goBack();
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
      body: BlocConsumer<LMFeedTopicBloc, LMFeedTopicState>(
        bloc: topicBloc,
        buildWhen: (previous, current) {
          if (current is LMFeedTopicLoadingState && _page != 1) {
            return false;
          }
          return true;
        },
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
        builder: (context, state) {
          if (state is LMFeedTopicLoadingState) {
            return const LMFeedLoader();
          }

          if (state is LMFeedTopicLoadedState) {
            return ValueListenableBuilder(
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
                });
          } else if (state is LMFeedTopicErrorState) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
