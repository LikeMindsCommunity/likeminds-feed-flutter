import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/saved_post/saved_post_bloc.dart';

class LMFeedSavedPostListView extends StatefulWidget {
  const LMFeedSavedPostListView({
    super.key,
    this.postBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;
  // Builder for error view while loading a new page
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;
  // Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  @override
  State<LMFeedSavedPostListView> createState() =>
      _LMFeedSavedPostListViewState();
}

class _LMFeedSavedPostListViewState extends State<LMFeedSavedPostListView> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.savedPostScreen;
  LMFeedThemeData _theme = LMFeedCore.theme;
  Size? screenSize;
  PagingController<int, LMPostViewData> _pagingController =
      PagingController<int, LMPostViewData>(
    firstPageKey: 1,
  );
  LMFeedSavedPostBloc _savePostBloc = LMFeedSavedPostBloc.instance;

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier<bool> postUploading = ValueNotifier(false);
  bool userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  LMFeedPostBloc postBloc = LMFeedPostBloc.instance;
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  final LMFeedWidgetBuilderDelegate _widgetBuilder =
      LMFeedCore.config.widgetBuilderDelegate;

  @override
  void initState() {
    super.initState();
    addPageRequestListener();
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _savePostBloc.add(
          LMFeedGetSavedPostEvent(
            page: pageKey,
            pageSize: 10,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  void updatePagingControllers(LMFeedSavedPostLoadedState state) {
    if (state.posts.length < 10) {
      _pagingController.appendLastPage(state.posts);
    } else {
      _pagingController.appendPage(state.posts, state.page + 1);
    }
  }

  @override
  dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
      bloc: postBloc,
      listener: (context, state) {
        if (state is LMFeedNewPostErrorState) {
          postUploading.value = false;
          LMFeedCore.showSnackBar(context, state.errorMessage, _widgetSource);
        }
        if (state is LMFeedNewPostUploadedState) {
          LMPostViewData? item = state.postData;
          int length = _pagingController.itemList?.length ?? 0;
          List<LMPostViewData> feedRoomItemList =
              _pagingController.itemList ?? [];
          for (int i = 0; i < feedRoomItemList.length; i++) {
            if (!feedRoomItemList[i].isPinned) {
              feedRoomItemList.insert(i, item);
              break;
            }
          }
          if (length == feedRoomItemList.length) {
            feedRoomItemList.add(item);
          }
          if (feedRoomItemList.isNotEmpty && feedRoomItemList.length > 10) {
            feedRoomItemList.removeLast();
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          } else {
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        }
        if (state is LMFeedPostDeletedState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          feedRoomItemList?.removeWhere((item) => item.id == state.postId);
          _pagingController.itemList = feedRoomItemList;
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
        if (state is LMFeedEditPostUploadedState) {
          LMPostViewData? item = state.postData.copyWith();
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == item.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList?[index] = item;
          }
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }

        if (state is LMFeedPostUpdateState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == state.postId) ??
              -1;
          if (index != -1) {
            LMPostViewData updatePostViewData = feedRoomItemList![index];
            updatePostViewData = LMFeedPostUtils.updatePostData(
                postViewData: updatePostViewData, actionType: state.actionType);
          }
          _pagingController.itemList = feedRoomItemList;
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      },
      builder: (context, state) {
        return BlocListener<LMFeedSavedPostBloc, LMFeedSavedPostState>(
          bloc: _savePostBloc,
          listener: (context, state) {
            if (state is LMFeedSavedPostLoadedState) {
              updatePagingControllers(state);
            }
            if (state is LMFeedSavedPostErrorState) {
              debugPrint(state.stackTrace.toString());
              _pagingController.error = state.errorMessage;
            }
          },
          child: ValueListenableBuilder(
              valueListenable: rebuildPostWidget,
              builder: (context, _, __) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    refresh();
                    clearPagingController();
                  },
                  child: PagedListView<int, LMPostViewData>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                      firstPageProgressIndicatorBuilder: (context) {
                        return widget.firstPageProgressIndicatorBuilder
                                ?.call(context) ??
                            const Center(
                              child: LMFeedLoader(),
                            );
                      },
                      newPageProgressIndicatorBuilder: (context) {
                        return widget.newPageProgressIndicatorBuilder
                                ?.call(context) ??
                            const Center(
                              child: LMFeedLoader(),
                            );
                      },
                      newPageErrorIndicatorBuilder: (context) {
                        return widget.newPageErrorIndicatorBuilder
                                ?.call(context) ??
                            Center(
                              child: LMFeedText(
                                text: _pagingController.error.toString(),
                              ),
                            );
                      },
                      itemBuilder: (context, item, index) {
                        LMFeedPostWidget postWidget =
                            LMFeedDefaultWidgets.instance.defPostWidget(
                          context,
                          _theme,
                          item,
                          _widgetSource,
                          postUploading,
                        );
                        return widget.postBuilder
                                ?.call(context, postWidget, item) ??
                            _widgetBuilder.postWidgetBuilder.call(
                                context, postWidget, item,
                                source: _widgetSource);
                      },
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Widget noPostInFeedWidget(LMFeedThemeData? feedThemeData) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.post_add,
              style: LMFeedIconStyle(
                size: 48,
                color: feedThemeData?.onContainer,
              ),
            ),
            const SizedBox(height: 12),
            LMFeedText(
              text:
                  'No ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: feedThemeData?.onContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LMFeedText(
              text: "Be the first one to create a $postTitleSmallCap here",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: feedThemeData?.onContainer,
                ),
              ),
            ),
            const SizedBox(height: 28),
            LMFeedButton(
              style: LMFeedButtonStyle(
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.add,
                  style: LMFeedIconStyle(
                    size: 18,
                    color: feedThemeData?.onPrimary,
                  ),
                ),
                borderRadius: 28,
                backgroundColor: feedThemeData?.primaryColor,
                height: 44,
                width: 160,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: LMFeedText(
                text: "Create $postTitleFirstCap",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: feedThemeData?.onPrimary,
                  ),
                ),
              ),
              onTap: () {
                LMFeedDefaultWidgets.instance.handleCreatePost(
                  context,
                  _widgetSource,
                  postUploading,
                );
              },
            ),
          ],
        ),
      );
}
