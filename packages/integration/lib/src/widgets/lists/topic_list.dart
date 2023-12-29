import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/topic/topic_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMTopicList extends StatefulWidget {
  final List<LMTopicViewData> selectedTopics;
  final Function(List<LMTopicViewData>, LMTopicViewData) onTopicSelected;
  final bool? isEnabled;

  const LMTopicList({
    super.key,
    required this.selectedTopics,
    required this.onTopicSelected,
    this.isEnabled,
  });

  @override
  State<LMTopicList> createState() => _LMTopicListState();
}

class _LMTopicListState extends State<LMTopicList> {
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
  LMTopicBloc topicBloc = LMTopicBloc();
  bool isSearching = false;
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
      LMGetTopic(
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
            topicBloc.add(LMGetTopic(
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
    ThemeData theme = LMFeedTheme.of(context);
    return Container(
      width: min(screenSize.width, 265),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(8.0),
      child: BlocConsumer<LMTopicBloc, LMTopicState>(
        bloc: topicBloc,
        buildWhen: (previous, current) {
          if (current is LMTopicLoading && _page != 1) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is LMTopicLoaded) {
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
          } else if (state is LMTopicError) {
            topicsPagingController.error = state.errorMessage;
          }
        },
        builder: (context, state) {
          if (state is LMTopicLoading) {
            return const Center(
              child: LMLoader(
                color: kPrimaryColor,
              ),
            );
          }

          if (state is LMTopicLoaded) {
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
                                            ? kPrimaryColor
                                            : kWhiteColor,
                                      ),
                                      alignment: Alignment.topLeft,
                                      clipBehavior: Clip.hardEdge,
                                      margin: const EdgeInsets.only(
                                          right: 8.0, bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: LMTextView(
                                              text: e.name,
                                              maxLines: 2,
                                              textStyle: TextStyle(
                                                color: isTopicSelected
                                                    ? theme
                                                        .colorScheme.secondary
                                                    : Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                height: 1.30,
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
          } else if (state is LMTopicError) {
            return const Center(
              child: Text("Unable to fetch topics, Please try again later"),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
