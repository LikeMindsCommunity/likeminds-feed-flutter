import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:async/async.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_detail_screen.dart';

class LMQnASearchTopicListView extends StatefulWidget {
  const LMQnASearchTopicListView({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  State<LMQnASearchTopicListView> createState() =>
      LMQnASearchTopicListViewState();
}

class LMQnASearchTopicListViewState extends State<LMQnASearchTopicListView> {
  LMFeedThemeData? theme;
  ValueNotifier<bool> showCancelIcon = ValueNotifier<bool>(false);
  late TextEditingController searchController;
  CancelableOperation? _debounceOperation;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedTopicBloc topicBloc = LMFeedTopicBloc();
  ValueNotifier<bool> postUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier<bool>(false);
  final PagingController<int, LMTopicViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  int page = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    searchController = widget.searchController;

    addPageRequestListener();
    if (searchController.text.isNotEmpty) {
      _fetchSearchResults(searchController.text);
    }
    searchController.addListener(() {
      _onTextChanged(searchController.text);
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        topicBloc.add(LMFeedGetTopicEvent(
            getTopicFeedRequest: (GetTopicsRequestBuilder()
                  ..page(page)
                  ..pageSize(pageSize)
                  ..searchType("name")
                  ..search(searchController.text))
                .build()));
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedTopicLoadedState state) {
    final List<LMTopicViewData> topics = [];
    Map<String, LMWidgetViewData> widgets = state.getTopicFeedResponse.widgets
            ?.map((key, value) => MapEntry(
                key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
        {};

    state.getTopicFeedResponse.topics?.forEach((topic) {
      topics.add(LMTopicViewDataConvertor.fromTopic(topic, widgets: widgets));
    });
    if (topics.length < 10) {
      _pagingController.appendLastPage(topics);
    } else {
      _pagingController.appendPage(topics, page);
      page++;
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    page = 1;
  }

  @override
  void dispose() {
    _debounceOperation?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) {
      clearPagingController();
      topicBloc.add(LMFeedInitTopicEvent());
    }
    _debounceOperation?.cancel();
    _debounceOperation = CancelableOperation.fromFuture(
      Future.delayed(const Duration(milliseconds: 500)),
    );
    _debounceOperation?.value.then((_) {
      _fetchSearchResults(value);
    });
  }

  Future<void> _fetchSearchResults(String value) async {
    if (value.isEmpty) return;
    clearPagingController();
    topicBloc.add(LMFeedGetTopicEvent(
        getTopicFeedRequest: (GetTopicsRequestBuilder()
              ..page(page)
              ..pageSize(pageSize)
              ..searchType("name")
              ..search(searchController.text))
            .build()));
  }

  @override
  Widget build(BuildContext context) {
    theme = LMFeedCore.theme;
    return BlocConsumer<LMFeedTopicBloc, LMFeedTopicState>(
      bloc: topicBloc,
      buildWhen: (previous, current) {
        if (current is LMFeedTopicPaginationLoadingState &&
            (previous is LMFeedTopicLoadingState ||
                previous is LMFeedTopicLoadedState)) {
          return false;
        }
        if (previous is LMFeedTopicLoadedState &&
            current is LMFeedTopicLoadingState) {
          return false;
        }
        return true;
      },
      listener: (context, state) {
        if (state is LMFeedTopicErrorState) {
          LMFeedCore.showSnackBar(
            context,
            state.errorMessage,
            LMFeedWidgetSource.searchScreen,
          );
        }
        if (state is LMFeedTopicLoadedState) {
          updatePagingControllers(state);
        }
        if (state is LMFeedTopicInitialState) {
          clearPagingController();
        }
      },
      builder: (context, state) {
        if (state is LMFeedTopicLoadingState) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: LMFeedShimmer(),
            ),
          );
        }

        if (state is LMFeedTopicLoadedState) {
          return Column(
            children: [
              if (state.getTopicFeedResponse.topics?.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  color: theme?.container,
                  width: double.infinity,
                  child: LMFeedText(
                      text: 'Hashtags',
                      style: LMFeedTextStyle(
                          textAlign: TextAlign.left,
                          textStyle: TextStyle(
                              fontFamily: "Inter",
                              color: theme?.onContainer,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w600))),
                ),
              Expanded(
                child: PagedListView<int, LMTopicViewData>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate(
                      firstPageProgressIndicatorBuilder: (context) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: LMFeedShimmer(),
                      ),
                    );
                  }, noItemsFoundIndicatorBuilder: (context) {
                    return const SizedBox.shrink();
                  }, newPageProgressIndicatorBuilder: (context) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: LMFeedLoader(),
                      ),
                    );
                  }, itemBuilder: (context, post, index) {
                    return _defTopicTile(context, post);
                  }),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Padding _defTopicTile(BuildContext context, LMTopicViewData topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: ListTile(
          tileColor: theme?.container,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          // leading: const SizedBox.shrink(),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LMFeedText(
              text: topic.name,
              style: LMFeedTextStyle(
                  maxLines: 2,
                  textStyle: TextStyle(
                      fontFamily: "Inter",
                      color: theme?.onContainer,
                      fontSize: 14,
                      height: 1.66,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LMFeedTopicDetailsScreen(
                  topicViewData: topic,
                ),
              ),
            );
          }),
    );
  }
}
