import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:async/async.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';

class LMFeedSearchScreen extends StatefulWidget {
  const LMFeedSearchScreen({
    super.key,
    this.postBuilder,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
  });

  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? emptyFeedViewBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageLoaderBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? paginationLoaderBuilder;
  // Builder for error view when error occurs
  final LMFeedContextWidgetBuilder? feedErrorViewBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noNewPageWidgetBuilder;

  @override
  State<LMFeedSearchScreen> createState() => LMFeedSearchScreenState();
}

class LMFeedSearchScreenState extends State<LMFeedSearchScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility widgetUtility = LMFeedCore.widgetUtility;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.searchScreen;
  ValueNotifier<bool> showCancelIcon = ValueNotifier<bool>(false);
  TextEditingController searchController = TextEditingController();
  CancelableOperation? _debounceOperation;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedSearchBloc searchBloc = LMFeedSearchBloc();
  ValueNotifier<bool> postUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier<bool>(false);
  // check whether current logged in user is CM or not
  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  FocusNode focusNode = FocusNode();
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  int page = 1;
  int pageSize = 10;
  late Size screenSize;
  double? screenWidth;
  bool isWeb = LMFeedPlatform.instance.isWeb();

  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  bool isDesktopWeb = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width > webConfig.maxWidth && kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }
  }

  @override
  void initState() {
    super.initState();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    addPageRequestListener();
    searchController.addListener(() {
      _onTextChanged(searchController.text);
    });

    if (focusNode.canRequestFocus) {
      focusNode.requestFocus();
    }

    // Fire analytics for search screen opened event
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.searchScreenOpened,
        eventProperties: {
          LMFeedAnalyticsKeys.userIdKey: currentUser.sdkClientInfo.uuid
        }));
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
            type: 'text',
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
    focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceOperation?.cancel();
    _debounceOperation = CancelableOperation.fromFuture(
      Future.delayed(const Duration(milliseconds: 500)),
    );
    _debounceOperation?.value.then((_) {
      handleCancelIcon(value);
      _fetchSearchResults(value);
    });
  }

  void handleCancelIcon(String value) {
    if (value.isNotEmpty) {
      if (!showCancelIcon.value) showCancelIcon.value = true;
    } else {
      if (showCancelIcon.value) showCancelIcon.value = false;
    }
  }

  Future<void> _fetchSearchResults(String value) async {
    if (value.isEmpty) return;
    clearPagingController();
    searchBloc.add(
      LMFeedGetSearchEvent(
        query: value,
        page: page,
        pageSize: pageSize,
        type: LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
            ? 'heading'
            : 'text',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = min(LMFeedCore.webConfiguration.maxWidth, screenSize.width);
    return widgetUtility.scaffold(
      source: _widgetSource,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.container,
        foregroundColor: theme.onContainer,
        title: TextField(
          controller: searchController,
          focusNode: focusNode,
          onChanged: _onTextChanged,
          cursorColor: theme.primaryColor,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: theme.onContainer.withOpacity(0.5)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          style: TextStyle(color: theme.onContainer),
        ),
        actions: [
          ValueListenableBuilder(
              valueListenable: showCancelIcon,
              builder: (context, value, child) {
                return value
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          clearPagingController();
                          refresh();
                          showCancelIcon.value = false;
                        },
                      )
                    : SizedBox();
              }),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth,
          child: BlocListener(
            bloc: newPostBloc,
            listener: (context, state) {
              if (state is LMFeedNewPostErrorState) {
                postUploading.value = false;
                LMFeedCore.showSnackBar(
                  context,
                  state.errorMessage,
                  _widgetSource,
                );
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
                if (feedRoomItemList.isNotEmpty &&
                    feedRoomItemList.length > 10) {
                  feedRoomItemList.removeLast();

                  postUploading.value = false;
                  rebuildPostWidget.value = !rebuildPostWidget.value;
                } else {
                  postUploading.value = false;
                  rebuildPostWidget.value = !rebuildPostWidget.value;
                }
              }
              if (state is LMFeedPostDeletedState) {
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                feedRoomItemList
                    ?.removeWhere((item) => item.id == state.postId);
                _pagingController.itemList = feedRoomItemList;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }

              if (state is LMFeedEditPostUploadedState) {
                LMPostViewData? item = state.postData.copyWith();
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }

                rebuildPostWidget.value = !rebuildPostWidget.value;
              }

              if (state is LMFeedPostUpdateState) {
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == state.postId) ??
                    -1;

                if (index != -1) {
                  feedRoomItemList![index] = LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? feedRoomItemList[index],
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  );
                }
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
            },
            child: BlocConsumer<LMFeedSearchBloc, LMFeedSearchState>(
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
                    _widgetSource,
                  );
                }
                if (state is LMFeedSearchLoadedState) {
                  // FocusScope.of(context).unfocus();
                  updatePagingControllers(state);
                }
              },
              builder: (context, state) {
                if (state is LMFeedSearchLoadingState) {
                  return widget.firstPageLoaderBuilder?.call(context) ??
                      const LMFeedLoader();
                }

                if (state is LMFeedSearchLoadedState) {
                  return ValueListenableBuilder(
                      valueListenable: rebuildPostWidget,
                      builder: (context, _, __) {
                        return PagedListView(
                          pagingController: _pagingController,
                          padding:
                              isDesktopWeb ? EdgeInsets.only(top: 20) : null,
                          builderDelegate:
                              PagedChildBuilderDelegate<LMPostViewData>(
                            noItemsFoundIndicatorBuilder: (context) {
                              return widget.emptyFeedViewBuilder
                                      ?.call(context) ??
                                  noPostInFeedWidget();
                            },
                            itemBuilder: (context, item, index) {
                              LMFeedPostWidget postWidget =
                                  LMFeedDefaultWidgets.instance.defPostWidget(
                                context,
                                theme,
                                item,
                                _widgetSource,
                                postUploading,
                              );
                              return Column(
                                children: [
                                  const SizedBox(height: 2),
                                  widget.postBuilder?.call(
                                        context,
                                        postWidget,
                                        item,
                                      ) ??
                                      widgetUtility.postWidgetBuilder(
                                        context,
                                        postWidget,
                                        item,
                                        source: _widgetSource,
                                      ),
                                ],
                              );
                            },
                            firstPageProgressIndicatorBuilder: (context) =>
                                const SizedBox(),
                            newPageProgressIndicatorBuilder: (context) =>
                                const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        );
                      });
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoaderThumbnail(LMAttachmentViewData? media) {
    if (media != null) {
      if (media.attachmentType == LMMediaType.image) {
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMFeedImage(
            image: media,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.attachmentType == LMMediaType.document) {
        return const LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: kAssetNoPostsIcon,
          style: LMFeedIconStyle(
            color: Colors.red,
            size: 35,
            boxPadding: 0,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget noPostInFeedWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMFeedIcon(
              style: LMFeedIconStyle(size: 100),
              type: LMFeedIconType.png,
              assetPath: lmNoResponsePng,
            ),
            SizedBox(height: 8),
            LMFeedText(
              text: 'No results found',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: LikeMindsTheme.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      );
}
