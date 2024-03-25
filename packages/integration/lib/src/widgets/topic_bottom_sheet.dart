import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedTopicBottomSheet extends StatefulWidget {
  final List<LMTopicViewData> selectedTopics;
  final Function(List<LMTopicViewData>, LMTopicViewData) onTopicSelected;
  final bool? isEnabled;

  const LMFeedTopicBottomSheet({
    Key? key,
    required this.selectedTopics,
    required this.onTopicSelected,
    this.isEnabled,
  }) : super(key: key);

  @override
  State<LMFeedTopicBottomSheet> createState() => _TopicBottomSheetState();
}

class _TopicBottomSheetState extends State<LMFeedTopicBottomSheet> {
  LMFeedThemeData? feedTheme;
  List<LMTopicViewData> selectedTopics = [];
  bool paginationComplete = false;
  ScrollController controller = ScrollController();
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
  final int pageSize = 100;
  LMFeedTopicBloc topicBloc = LMFeedTopicBloc();
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
    selectedTopics = widget.selectedTopics;
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
    super.dispose();
  }

  void paginationListener() {
    if (controller.position.atEdge) {
      bool isTop = controller.position.pixels == 0;
      if (!isTop) {
        topicBloc.add(LMFeedGetTopicEvent(
          getTopicFeedRequest: (GetTopicsRequestBuilder()
                ..page(_page)
                ..isEnabled(widget.isEnabled)
                ..pageSize(pageSize)
                ..search(search)
                ..searchType(searchType))
              .build(),
        ));
      }
    }
  }

  _addPaginationListener() {
    controller.addListener(paginationListener);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    feedTheme = LMFeedCore.theme;
    return Container(
      width: screenSize.width,
      decoration: BoxDecoration(
        color: feedTheme?.container,
      ),
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.4,
        minHeight: screenSize.height * 0.2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 43.67,
              height: 7.23,
              decoration: ShapeDecoration(
                color: feedTheme?.onContainer.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<LMFeedTopicBloc, LMFeedTopicState>(
                bloc: topicBloc,
                buildWhen: (previous, current) {
                  if (_page > 1 && current is LMFeedTopicLoadingState) {
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
                      style: feedTheme?.loaderStyle,
                    );
                  }

                  if (state is LMFeedTopicLoadedState) {
                    return ValueListenableBuilder(
                        valueListenable: rebuildTopicsScreen,
                        builder: (context, _, __) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: LMFeedText(
                                  text: 'Topics',
                                  style: LMFeedTextStyle(
                                    textAlign: TextAlign.center,
                                    textStyle: TextStyle(
                                      color: feedTheme?.onContainer,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: controller,
                                  child: Wrap(
                                    children: topicsPagingController.itemList
                                            ?.map((e) {
                                          bool isTopicSelected =
                                              selectedTopicId.contains(e.id);
                                          return GestureDetector(
                                            onTap: () {
                                              if (isTopicSelected) {
                                                selectedTopicId.remove(e.id);
                                                selectedTopics.removeWhere(
                                                    (element) =>
                                                        element.id == e.id);
                                              } else {
                                                selectedTopicId.add(e.id);
                                                selectedTopics.add(e);
                                              }
                                              isTopicSelected =
                                                  !isTopicSelected;
                                              rebuildTopicsScreen.value =
                                                  !rebuildTopicsScreen.value;
                                              widget.onTopicSelected(
                                                  selectedTopics, e);
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8.0, bottom: 8.0),
                                              child: LMFeedTopicChip(
                                                topic: e,
                                                isSelected: isTopicSelected,
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
                    return Center(
                      child: Text(state.errorMessage),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
