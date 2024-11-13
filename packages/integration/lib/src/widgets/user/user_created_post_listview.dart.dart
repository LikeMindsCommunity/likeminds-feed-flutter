// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedUserCreatedPostListView extends StatefulWidget {
  const LMFeedUserCreatedPostListView({
    Key? key,
    required this.uuid,
    this.postBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
  }) : super(key: key);

  // The user id for which the user feed is to be shown
  final String uuid;
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
  State<LMFeedUserCreatedPostListView> createState() =>
      _LMFeedUserCreatedPostListViewState();
}

class _LMFeedUserCreatedPostListViewState
    extends State<LMFeedUserCreatedPostListView> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.userFeed;
  static const int pageSize = 10;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};
  Map<String, LMPostViewData> repostedPosts = {};
  Map<String, LMCommentViewData> filteredComments = {};

  int _pageFeed = 1;
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  final ValueNotifier postUploading = ValueNotifier(false);
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;

  @override
  void initState() {
    super.initState();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    addPaginationListener();
  }

  void addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) async {
      final userFeedRequest = (GetUserPostRequestBuilder()
            ..page(pageKey)
            ..pageSize(pageSize)
            ..uuid(widget.uuid))
          .build();
      GetUserPostResponse response = await LMFeedCore.instance.lmFeedClient
          .getUserCreatedPosts(userFeedRequest);
      updatePagingControllers(response);
    });
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(GetUserPostResponse response) {
    if (response.success) {
      _pageFeed++;
      if (response.widgets != null) {
        widgets.addAll(response.widgets?.map((key, value) => MapEntry(
                key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
            {});
      }
      if (response.topics != null) {
        topics.addAll(response.topics!.map((key, value) => MapEntry(
              key,
              LMTopicViewDataConvertor.fromTopic(value, widgets: widgets),
            )));
      }
      if (response.users != null) {
        users.addAll(response.users!.map((key, value) => MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(
              value,
              topics: topics,
              widgets: widgets,
              userTopics: response.userTopics,
            ))));
      }

      if (response.filteredComments != null) {
        filteredComments.addAll(
          response.filteredComments!.map(
            (key, value) => MapEntry(
              key,
              LMCommentViewDataConvertor.fromComment(
                value,
                users,
              ),
            ),
          ),
        );
      }

      if (response.repostedPosts != null) {
        repostedPosts.addAll(
          response.repostedPosts!.map(
            (key, value) => MapEntry(
              key,
              LMPostViewDataConvertor.fromPost(
                post: value,
                users: users,
                filteredComments: filteredComments,
                topics: topics,
                userTopics: response.userTopics,
                widgets: widgets,
              ),
            ),
          ),
        );
      }
      List<LMPostViewData> listOfPosts = response.posts!
          .map((e) => LMPostViewDataConvertor.fromPost(
              post: e,
              widgets: widgets,
              repostedPosts: repostedPosts,
              topics: topics,
              users: users,
              filteredComments: filteredComments,
              userTopics: response.userTopics))
          .toList();

      if (listOfPosts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, _pageFeed);
      }
    } else {
      _pagingController.appendLastPage([]);
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    _pageFeed = 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
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
          if (feedRoomItemList.isNotEmpty && feedRoomItemList.length > 10) {
            feedRoomItemList.removeLast();
            users.addAll(state.userData);
            topics.addAll(state.topics);
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          } else {
            users.addAll(state.userData);
            topics.addAll(state.topics);
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
        if (state is LMFeedEditPostUploadedState) {
          LMPostViewData? item = state.postData.copyWith();
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == item.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList?[index] = item;
          }
          users.addAll(state.userData);
          topics.addAll(state.topics);
          widgets.addAll(state.widgets);

          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      },
      child: ValueListenableBuilder(
          valueListenable: rebuildPostWidget,
          builder: (context, _, __) {
            return PagedSliverList(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                itemBuilder: (context, item, index) {
                  if (!users.containsKey(item.uuid)) {
                    return const SizedBox();
                  }
                  LMFeedPostWidget postWidget =
                      LMFeedDefaultWidgets.instance.defPostWidget(
                    context,
                    feedThemeData,
                    item,
                    _widgetSource,
                  );

                  return Column(
                    children: [
                      const SizedBox(height: 2),
                      widget.postBuilder?.call(context, postWidget, item) ??
                          _widgetsBuilder.postWidgetBuilder(
                            context,
                            postWidget,
                            item,
                            source: _widgetSource,
                          ),
                    ],
                  );
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return widget.noItemsFoundIndicatorBuilder?.call(context) ??
                      _widgetsBuilder.noItemsFoundIndicatorBuilderFeed(context,
                          isSelfPost:
                              widget.uuid == currentUser?.sdkClientInfo.uuid ||
                                  widget.uuid == currentUser?.uuid,
                          createPostButton: createPostButton());
                },
                firstPageProgressIndicatorBuilder: (context) =>
                    widget.firstPageProgressIndicatorBuilder?.call(context) ??
                    const LMFeedShimmer(),
                newPageProgressIndicatorBuilder: (context) =>
                    widget.newPageProgressIndicatorBuilder?.call(context) ??
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
              ),
            );
          }),
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
        return LMFeedTheme
                .instance.theme.mediaStyle.documentStyle.documentIcon ??
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.picture_as_pdf,
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

  LMFeedButton createPostButton() {
    return LMFeedButton(
      style: LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.add,
          style: LMFeedIconStyle(
            color: feedThemeData.onPrimary,
            size: 18,
          ),
        ),
        borderRadius: 28,
        backgroundColor: feedThemeData.primaryColor,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        placement: LMFeedIconButtonPlacement.end,
      ),
      text: LMFeedText(
        text: "Create $postTitleFirstCap",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: feedThemeData.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: userPostingRights
          ? () async {
              if (!postUploading.value) {
                LMFeedVideoProvider.instance.pauseCurrentVideo();
                // ignore: use_build_context_synchronously
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LMFeedComposeScreen(
                      widgetSource: LMFeedWidgetSource.userFeed,
                    ),
                  ),
                );
                LMFeedVideoProvider.instance.playCurrentVideo();
              } else {
                LMFeedCore.showSnackBar(
                  context,
                  'A $postTitleSmallCap is already uploading.',
                  _widgetSource,
                );
              }
            }
          : () {
              LMFeedCore.showSnackBar(
                context,
                'You do not have permission to create a $postTitleSmallCap',
                _widgetSource,
              );
            },
    );
  }

  void handlePostReportAction(LMPostViewData postViewData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedReportScreen(
          entityId: postViewData.id,
          entityType: postEntityId,
          entityCreatorId: postViewData.user.uuid,
        ),
      ),
    );
  }
}
