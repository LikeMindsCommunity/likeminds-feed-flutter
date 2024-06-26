import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostDetailScreenHandler {
  final Map<String, LMUserViewData> users = {};
  final LMFeedWidgetSource widgetSource = LMFeedWidgetSource.postDetailScreen;
  late final PagingController<int, LMCommentViewData>
      commentListPagingController;
  late final String postId;
  late final LMFeedCommentBloc commentHandlerBloc;
  late final FocusNode focusNode;
  late final TextEditingController commentController;
  final ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMPostViewData> repostedPosts = {};
  Map<String, LMWidgetViewData> widgets = {};
  Map<String, List<String>> userTopics = {};
  LMPostViewData? postData;
  int commentListPageSize = 10;

  LMFeedPostDetailScreenHandler(
      PagingController<int, LMCommentViewData> commetListPagingController,
      String postId) {
    this.commentListPagingController = commetListPagingController;
    this.postId = postId;
    commentHandlerBloc = LMFeedCommentBloc.instance;
    commentController = TextEditingController();
    focusNode = FocusNode();
    addCommentListPaginationListener();
  }

  Future<LMPostViewData?> fetchCommentListWithPage(int page) async {
    PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
          ..postId(postId)
          ..pageSize(commentListPageSize)
          ..page(page))
        .build();

    final PostDetailResponse response =
        await LMFeedCore.client.getPostDetails(postDetailRequest);

    if (response.success) {
      // Convert [WidgetModel] to [LMWidgetViewData]
      // Add widgets to the map
      widgets.addAll(response.widgets?.map((key, value) => MapEntry(
              key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
          {});

      // Convert [Topic] to [LMTopicViewData]
      // Add topics to the map
      topics.addAll(response.topics!.map((key, value) => MapEntry(
          key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets))));

      userTopics.addAll(response.userTopics!);

      // Convert [User] to [LMUserViewData]
      // Add users to the map
      users.addAll(
        response.users!.map(
          (key, value) => MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(
              value,
              topics: topics,
              widgets: widgets,
              userTopics: userTopics,
            ),
          ),
        ),
      );

      // Convert [Post] to [LMPostViewData]
      // Add reposted posts to the map
      repostedPosts.addAll(response.repostedPosts?.map((key, value) => MapEntry(
              key,
              LMPostViewDataConvertor.fromPost(
                post: value,
                widgets: widgets,
                repostedPosts: repostedPosts,
                users: users,
                topics: topics,
                userTopics: userTopics,
              ))) ??
          {});

      // Convert [Post] to [LMPostViewData]
      // Add post data, and all supporting data to the map
      final LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
        post: response.post!,
        widgets: widgets,
        repostedPosts: repostedPosts,
        users: users,
        topics: topics,
        userTopics: userTopics,
      );

      if (page == 1) {
        rebuildPostWidget.value = !rebuildPostWidget.value;
      }

      final List<LMCommentViewData> commentList = postViewData.replies;

      addCommentListToController(commentList, page + 1);

      return postViewData;
    } else {
      commentListPagingController.error = response.errorMessage;

      return null;
    }
  }

  void addCommentListToController(
      List<LMCommentViewData> commentList, int nextPageKey) {
    final isLastPage = commentList.length < commentListPageSize;
    if (isLastPage) {
      commentListPagingController.appendLastPage(commentList);
    } else {
      commentListPagingController.appendPage(commentList, nextPageKey);
    }
  }

  void addCommentListPaginationListener() {
    commentListPagingController.addPageRequestListener((pageKey) async {
      await fetchCommentListWithPage(pageKey);
    });
  }

  void handleBlocChanges(
      BuildContext context, LMFeedCommentHandlerState state) {
    switch (state.runtimeType) {
      case LMFeedCommentCanceledState:
        {
          commentController.clear();
          closeOnScreenKeyboard();
          break;
        }
      case LMFeedCommentActionOngoingState:
        {
          openOnScreenKeyboard();

          LMCommentMetaData commentMetaData =
              (state as LMFeedCommentActionOngoingState).commentMetaData;

          if (commentMetaData.commentActionType ==
              LMFeedCommentActionType.edit) {
            commentController.text = commentMetaData.commentText!;
          }
          break;
        }
      case const (LMFeedCommentSuccessState<AddCommentResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;
          AddCommentResponse response =
              commentSuccessState.commentActionResponse as AddCommentResponse;

          widgets.addAll((response.widgets ?? {})
              .map((key, value) => MapEntry(
                  key, LMWidgetViewDataConvertor.fromWidgetModel(value)))
              .cast<String, LMWidgetViewData>());

          topics.addAll((response.topics ?? {})
              .map((key, value) => MapEntry(key,
                  LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)))
              .cast<String, LMTopicViewData>());

          users.addAll(response.users?.map((key, value) => MapEntry(
                  key,
                  LMUserViewDataConvertor.fromUser(
                    value,
                    topics: topics,
                    widgets: widgets,
                    userTopics: response.userTopics,
                  ))) ??
              {});

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!, users);

          replaceTempCommentWithActualComment(commentViewData);

          rebuildPostWidget.value = !rebuildPostWidget.value;
          break;
        }
      case const (LMFeedCommentSuccessState<EditCommentResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          EditCommentResponse response =
              commentSuccessState.commentActionResponse as EditCommentResponse;

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!, users);

          updateCommentInController(commentViewData);

          rebuildPostWidget.value = !rebuildPostWidget.value;

          break;
        }
      case const (LMFeedCommentSuccessState<DeleteCommentResponse>):
        {
          String commentTitle = LMFeedPostUtils.getCommentTitle(
              LMFeedPluralizeWordAction.firstLetterCapitalSingular);
          // Show the toast message for comment deleted
          LMFeedCore.showSnackBar(
            context,
            '$commentTitle Deleted',
            widgetSource,
          );

          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          if (commentSuccessState.commentMetaData.commentActionEntity ==
              LMFeedCommentType.parent) {
          } else {
            LMCommentViewData? commentViewData =
                commentListPagingController.itemList?.firstWhere((element) =>
                    element.id ==
                    commentSuccessState.commentMetaData.commentId);
            if (commentViewData != null) {
              updateCommentInController(commentViewData);
            }
          }

          rebuildPostWidget.value = !rebuildPostWidget.value;
          break;
        }
      case const (LMFeedCommentSuccessState<AddCommentReplyResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          AddCommentReplyResponse response = commentSuccessState
              .commentActionResponse as AddCommentReplyResponse;

          Map<String, LMWidgetViewData> responseWidgets = response.widgets?.map(
                  (key, value) => MapEntry(
                      key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
              {};

          Map<String, LMTopicViewData> responseTopics = response.topics?.map(
                  (key, value) => MapEntry(
                      key,
                      LMTopicViewDataConvertor.fromTopic(value,
                          widgets: responseWidgets))) ??
              {};

          Map<String, LMUserViewData> responseUsers =
              response.users?.map((key, value) => MapEntry(
                      key,
                      LMUserViewDataConvertor.fromUser(
                        value,
                        topics: responseTopics,
                        widgets: responseWidgets,
                        userTopics: response.userTopics,
                      ))) ??
                  {};

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(
            response.reply!,
            responseUsers,
          );

          if (response.reply!.parentComment != null) {
            updateCommentInController(commentViewData.parentComment!);
          }
          LMFeedFetchCommentReplyBloc.instance.add(LMFeedAddLocalReplyEvent(
            comment: commentViewData,
          ));
          rebuildPostWidget.value = !rebuildPostWidget.value;
          break;
        }
      case const (LMFeedCommentSuccessState<EditCommentReplyResponse>):
        {
          // final LMFeedCommentSuccessState commentSuccessState =
          //     state as LMFeedCommentSuccessState;

          // EditCommentReplyResponse response = commentSuccessState
          //     .commentActionResponse as EditCommentReplyResponse;

          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      case const (LMFeedCommentErrorState<DeleteCommentResponse>):
        {
          LMFeedCore.showSnackBar(
            context,
            (state as DeleteCommentResponse).errorMessage ??
                "An error occurred",
            widgetSource,
          );
        }
      case const (LMFeedCommentErrorState<AddCommentRequest>,):
        {
          final LMFeedCommentErrorState<AddCommentResponse> commentErrorState =
              state as LMFeedCommentErrorState<AddCommentResponse>;
          removeTempCommentFromController(
              commentErrorState.commentMetaData.commentId!);
          LMFeedCore.showSnackBar(
            context,
            commentErrorState.commentActionResponse.errorMessage ??
                'An error occurred',
            widgetSource,
          );
          break;
        }
    }
  }

  void removeTempCommentFromController(String tempId) {
    debugPrint('tempId: $tempId');
    commentListPagingController.itemList
        ?.removeWhere((element) => element.tempId == tempId);
  }

  void addTempReplyCommentToController(
      String tempId, String text, int level, String parentId, bool replyShown) {
    DateTime createdAt = DateTime.now();
    LMUserViewData? currentUser =
        LMFeedLocalPreference.instance.fetchUserData();

    LMCommentViewData commentViewData = (LMCommentViewDataBuilder()
          ..id(tempId)
          ..uuid(currentUser!.uuid)
          ..text(text)
          ..level(level)
          ..likesCount(0)
          ..isEdited(false)
          ..repliesCount(0)
          ..menuItems([])
          ..createdAt(createdAt)
          ..updatedAt(createdAt)
          ..isLiked(false)
          ..user(currentUser)
          ..tempId(tempId))
        .build();
    final index = commentListPagingController.itemList
        ?.indexWhere((element) => element.id == parentId);
    if (index != null && index >= 0) {
      LMCommentViewData parentComment =
          commentListPagingController.itemList![index];
      parentComment.repliesCount += 1;
      parentComment.replies?.insert(0, commentViewData);
      updateCommentInController(parentComment);
      commentViewData.parentComment = parentComment;
      rebuildPostWidget.value = !rebuildPostWidget.value;
    }

    // if (!replyShown)
    {
      LMFeedFetchCommentReplyBloc.instance
          .add(LMFeedAddLocalReplyEvent(comment: commentViewData));
    }
  }

  void addTempCommentToController(String tempId, String text, int level,
      {DateTime? createdTime}) {
    DateTime createdAt = DateTime.now();
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;

    LMCommentViewData commentViewData = (LMCommentViewDataBuilder()
          ..id(tempId)
          ..uuid(currentUser.uuid)
          ..text(text)
          ..level(level)
          ..likesCount(0)
          ..isEdited(false)
          ..repliesCount(0)
          ..menuItems([])
          ..createdAt(createdTime ?? createdAt)
          ..updatedAt(createdTime ?? createdAt)
          ..isLiked(false)
          ..user(currentUser)
          ..tempId(tempId))
        .build();
    addCommentToController(commentViewData);
  }

  void addTempEditingComment(String commentId, String editedText) {
    final index = commentListPagingController.itemList
        ?.indexWhere((element) => element.id == commentId);
    if (index != null && index >= 0) {
      LMCommentViewData commentViewData =
          commentListPagingController.itemList![index];
      commentViewData.isEdited = true;
      commentViewData.text = editedText;
      commentListPagingController.itemList![index] = commentViewData;
      rebuildPostWidget.value = !rebuildPostWidget.value;
    }
  }

  void replaceTempCommentWithActualComment(LMCommentViewData commentViewData) {
    final index = commentListPagingController.itemList
        ?.indexWhere((element) => element.tempId == commentViewData.tempId);
    if (index != null && index >= 0) {
      commentListPagingController.itemList![index] = commentViewData;
    }
  }

  void addCommentToController(LMCommentViewData commentViewData) {
    commentListPagingController.itemList?.insert(0, commentViewData);
    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postData!.id, actionType: LMFeedPostActionType.commentAdded));
    debugPrint(
        'commentListPagingController.itemList: ${commentListPagingController.itemList}');
  }

  void deleteCommentFromController(String commentId) {
    commentListPagingController.itemList
        ?.removeWhere((element) => element.id == commentId);
  }

  void updateCommentInController(LMCommentViewData commentViewData) {
    final index = commentListPagingController.itemList
        ?.indexWhere((element) => element.id == commentViewData.id);
    if (index != null && index >= 0) {
      commentListPagingController.itemList![index] = commentViewData;
    }
  }

  void openOnScreenKeyboard() {
    if (focusNode.canRequestFocus) {
      focusNode.requestFocus();
      if (commentController.text.isNotEmpty) {
        commentController.selection = TextSelection.fromPosition(
            TextPosition(offset: commentController.text.length));
      }
    }
  }

  void closeOnScreenKeyboard() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }
}
