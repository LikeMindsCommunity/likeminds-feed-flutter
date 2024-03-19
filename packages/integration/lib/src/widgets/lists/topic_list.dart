import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedTopicList extends StatefulWidget {
  final List<LMTopicViewData> selectedTopics;
  final Function(List<LMTopicViewData>, LMTopicViewData) onTopicSelected;
  final bool? isEnabled;

  final Color? backgroundColor;

  final BorderRadius? borderRadius;

  final Widget Function()? listViewBuilder;

  const LMFeedTopicList({
    super.key,
    required this.selectedTopics,
    required this.onTopicSelected,
    this.listViewBuilder,
    this.backgroundColor,
    this.borderRadius,
    this.isEnabled,
  });

  @override
  State<LMFeedTopicList> createState() => _LMFeedTopicListState();
}

class _LMFeedTopicListState extends State<LMFeedTopicList> {
  List<LMTopicViewData> selectedTopics = [];
  bool paginationComplete = false;
  ScrollController controller = ScrollController();
  Set<String> selectedTopicId = {};
  LMTopicViewData allTopics = (LMTopicViewDataBuilder()
        ..id("0")
        ..isEnabled(true)
        ..name("All Topics"))
      .build();
  final int pageSize = 100;
  LMFeedTopicBloc topicBloc = LMFeedTopicBloc();
  ValueNotifier<bool> rebuildTopicsScreen = ValueNotifier<bool>(false);
  PagingController<int, LMTopicViewData> topicsPagingController =
      PagingController(firstPageKey: 1);

  int _page = 1;

  bool checkSelectedTopicExistsInList(LMTopicViewData topic) {
    return selectedTopicId.contains(topic.id);
  }

  @override
  void initState() {
    super.initState();
    selectedTopics = [...widget.selectedTopics];
    for (LMTopicViewData topic in selectedTopics) {
      selectedTopicId.add(topic.id);
    }
    topicsPagingController.itemList = selectedTopics;
    topicBloc.add(
      LMFeedGetTopicEvent(
        getTopicFeedRequest: (GetTopicsRequestBuilder()
              ..page(_page)
              ..isEnabled(widget.isEnabled)
              ..pageSize(pageSize))
            .build(),
      ),
    );
    _addPaginationListener();
  }

  @override
  void dispose() {
    topicBloc.close();
    super.dispose();
  }

  _addPaginationListener() {
    controller.addListener(
      () {
        if (controller.position.atEdge) {
          bool isTop = controller.position.pixels == 0;
          if (!isTop) {
            topicBloc.add(LMFeedGetTopicEvent(
              getTopicFeedRequest: (GetTopicsRequestBuilder()
                    ..page(_page)
                    ..isEnabled(widget.isEnabled)
                    ..pageSize(pageSize))
                  .build(),
            ));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: min(screenSize.width, 180),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? LMFeedCore.theme.container,
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(8.0),
      child: BlocConsumer<LMFeedTopicBloc, LMFeedTopicState>(
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
            return LMFeedLoader(
              style: LMFeedCore.theme.loaderStyle,
            );
          }

          if (state is LMFeedTopicLoadedState) {
            return ValueListenableBuilder(
                valueListenable: rebuildTopicsScreen,
                builder: (context, _, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: topicsPagingController.itemList?.map((e) {
                                  bool isTopicSelected =
                                      selectedTopicId.contains(e.id);
                                  return GestureDetector(
                                    onTap: () {
                                      if (isTopicSelected) {
                                        selectedTopicId.remove(e.id);
                                        selectedTopics.removeWhere(
                                            (element) => element.id == e.id);
                                      } else {
                                        selectedTopicId.add(e.id);
                                        selectedTopics.add(e);
                                      }
                                      isTopicSelected = !isTopicSelected;
                                      rebuildTopicsScreen.value =
                                          !rebuildTopicsScreen.value;
                                      widget.onTopicSelected(selectedTopics, e);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: isTopicSelected
                                            ? LMFeedCore.theme.primaryColor
                                            : LMFeedCore.theme.container,
                                      ),
                                      alignment: Alignment.topLeft,
                                      clipBehavior: Clip.hardEdge,
                                      margin: const EdgeInsets.only(
                                          right: 8.0, bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: LMFeedText(
                                              text: e.name,
                                              style: LMFeedTextStyle(
                                                maxLines: 2,
                                                textStyle: TextStyle(
                                                  color: isTopicSelected
                                                      ? LMFeedCore
                                                          .theme.onPrimary
                                                      : LMFeedCore
                                                          .theme.onContainer,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
                      ),
                    ],
                  );
                });
          } else if (state is LMFeedTopicErrorState) {
            return const Center(
              child: Text("Unable to fetch topics, Please try again later"),
            );
          }

          // Error state
          else if (state is LMFeedTopicErrorState) {
            return const Center(
              child: LMFeedText(
                text: "Unable to fetch topics, Please try again later",
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _defaultListBuilder() {
    return SingleChildScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: topicsPagingController.itemList?.map((e) {
              bool isTopicSelected = selectedTopicId.contains(e.id);
              return GestureDetector(
                onTap: _selectTopic(isTopicSelected, e),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: isTopicSelected
                        ? LMFeedCore.theme.secondaryColor
                        : Colors.white,
                  ),
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: LMFeedText(
                          text: e.name,
                          style: LMFeedTextStyle(
                            maxLines: 2,
                            textStyle: TextStyle(
                              color: isTopicSelected
                                  ? Colors.grey
                                  : LMFeedCore.theme.secondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList() ??
            [],
      ),
    );
  }

  _selectTopic(isTopicSelected, topic) {
    if (isTopicSelected) {
      selectedTopicId.remove(topic.id);
      selectedTopics.removeWhere((element) => element.id == topic.id);
    } else {
      selectedTopicId.add(topic.id);
      selectedTopics.add(topic);
    }
    isTopicSelected = !isTopicSelected;
    rebuildTopicsScreen.value = !rebuildTopicsScreen.value;
    widget.onTopicSelected(selectedTopics, topic);
  }
}
