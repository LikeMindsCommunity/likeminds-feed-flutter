import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:async/async.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';

class LMQnASearchPostListView extends StatefulWidget {
  const LMQnASearchPostListView({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  State<LMQnASearchPostListView> createState() =>
      LMQnASearchPostListViewState();
}

class LMQnASearchPostListViewState extends State<LMQnASearchPostListView> {
  LMFeedThemeData theme = LMFeedCore.theme;

  String postTitle = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);

  ValueNotifier<bool> showCancelIcon = ValueNotifier<bool>(false);
  late TextEditingController searchController;
  CancelableOperation? _debounceOperation;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedSearchBloc searchBloc = LMFeedSearchBloc();
  ValueNotifier<bool> postUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier<bool>(false);
  final PagingController<int, LMPostViewData> _pagingController =
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
        searchBloc.add(
          LMFeedGetSearchEvent(
            query: searchController.text,
            page: page,
            pageSize: pageSize,
            type: 'heading',
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedSearchLoadedState state) {
    if (state.posts.length < 10) {
      _pagingController.appendLastPage(state.posts);
    } else {
      _pagingController.appendPage(state.posts, page);
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
      searchBloc.add(LMFeedClearSearchEvent());
      return;
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
    searchBloc.add(
      LMFeedGetSearchEvent(
        query: value,
        page: page,
        pageSize: pageSize,
        type: 'heading',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LMFeedSearchBloc, LMFeedSearchState>(
      bloc: searchBloc,
      buildWhen: (previous, current) {
        if (current is LMFeedSearchPaginationLoadingState &&
            (previous is LMFeedSearchLoadingState ||
                previous is LMFeedSearchLoadedState)) {
          return false;
        }
        return true;
      },
      listener: (context, state) {
        if (state is LMFeedSearchErrorState) {
          LMFeedCore.showSnackBar(
            context,
            state.message,
            LMFeedWidgetSource.searchScreen,
          );
        }
        if (state is LMFeedSearchLoadedState) {
          updatePagingControllers(state);
        }
        if (state is LMFeedInitialSearchState) {
          clearPagingController();
        }
      },
      builder: (context, state) {
        if (state is LMFeedSearchLoadingState) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: LMFeedShimmer(),
            ),
          );
        }

        if (state is LMFeedSearchLoadedState) {
          return Column(
            children: [
              if (state.posts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  color: theme.container,
                  width: double.infinity,
                  child: LMFeedText(
                      text: postTitle,
                      style: LMFeedTextStyle(
                          textAlign: TextAlign.left,
                          textStyle: TextStyle(
                              fontFamily: "Inter",
                              color: theme.onContainer,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w600))),
                ),
              Expanded(
                child: PagedListView<int, LMPostViewData>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate(
                      firstPageProgressIndicatorBuilder: (context) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: LMFeedLoader(),
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
                    return _defPostTile(context, post);
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

  Padding _defPostTile(BuildContext context, LMPostViewData post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        tileColor: theme.container,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LMFeedText(
            text: post.heading ?? "",
            style: LMFeedTextStyle(
                maxLines: 2,
                textStyle: TextStyle(
                    fontFamily: "Inter",
                    color: theme.onContainer,
                    fontSize: 14,
                    height: 1.66,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        subtitle: Row(children: [
          LMFeedText(
              text: LMFeedPostUtils.getLikeCountTextWithCount(post.likeCount),
              style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                color: textSecondary,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                height: 1.66,
                letterSpacing: 0.2,
                fontSize: 12,
              ))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: LMFeedText(
                text: "•",
                style: LMFeedTextStyle(
                    textStyle: TextStyle(
                  color: textSecondary,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  height: 1.66,
                  letterSpacing: 0.2,
                  fontSize: 12,
                ))),
          ),
          LMFeedText(
            text:
                "${post.commentCount} ${LMFeedPostUtils.getCommentCountText(post.commentCount)}",
            style: const LMFeedTextStyle(
                textStyle: TextStyle(
              color: textSecondary,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              height: 1.66,
              letterSpacing: 0.2,
              fontSize: 12,
            )),
          ),
        ]),
        onTap: () {
          // navigate to post details
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LMFeedPostDetailScreen(
                        postId: post.id,
                      )));
        },
      ),
    );
  }
}
