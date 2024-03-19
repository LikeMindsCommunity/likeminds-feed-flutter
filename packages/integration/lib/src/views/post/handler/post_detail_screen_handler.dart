import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostDetailScreenHandler {
  final Map<String, LMUserViewData> users = {};
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

  LMFeedPostDetailScreenHandler(
      PagingController<int, LMCommentViewData> commetListPagingController,
      String postId) {
    this.commentListPagingController = commetListPagingController;
    this.postId = postId;
    commentHandlerBloc = LMFeedCommentBloc.instance;
    commentController = TextEditingController();
    focusNode = FocusNode();
  }

  Future<LMPostViewData?> fetchCommentListWithPage(int page) async {
    PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
          ..postId(postId)
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
              topics: response.topics,
              widgets: response.widgets,
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
                widgets: response.widgets,
                repostedPosts: response.repostedPosts,
                users: response.users ?? {},
                topics: response.topics ?? {},
                userTopics: userTopics,
              ))) ??
          {});

      // Convert [Post] to [LMPostViewData]
      // Add post data, and all supporting data to the map
      final LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
        post: response.post!,
        widgets: response.widgets,
        repostedPosts: response.repostedPosts,
        users: response.users ?? {},
        topics: response.topics ?? {},
        userTopics: userTopics,
      );

      final List<LMCommentViewData> commentList = postViewData.replies;

      addCommentListToController(commentList, page + 1);

      return postViewData;
    } else {
      LMFeedCore.showSnackBar(
        LMFeedSnackBar(
          content: LMFeedText(
            text: response.errorMessage ?? "An error occurred",
          ),
        ),
      );
      return null;
    }
  }

  void addCommentListToController(
      List<LMCommentViewData> commentList, int nextPageKey) {
    final isLastPage = commentList.length < 10;
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

  void handleBlocChanges(LMFeedCommentHandlerState state) {
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

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!, users);
          replaceTempCommentWithActualComment(commentViewData);

          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              postId: postData!.id,
              actionType: LMFeedPostActionType.commentAdded));

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
          // Show the toast message for comment deleted
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text: 'Comment Deleted',
              ),
            ),
          );

          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          if (commentSuccessState.commentMetaData.commentActionEntity ==
              LMFeedCommentType.parent) {
            // deleteCommentFromController(
            //     commentSuccessState.commentMetaData.commentId!);
            // postData!.commentCount -= 1;
          } else {
            LMCommentViewData? commentViewData =
                commentListPagingController.itemList?.firstWhere((element) =>
                    element.id ==
                    commentSuccessState.commentMetaData.commentId);
            if (commentViewData != null) {
              updateCommentInController(commentViewData);
            }
          }

          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              postId: postData!.id,
              commentId: commentSuccessState.commentMetaData.commentId,
              actionType:
                  commentSuccessState.commentMetaData.commentActionEntity ==
                          LMFeedCommentType.parent
                      ? LMFeedPostActionType.commentDeleted
                      : LMFeedPostActionType.replyDeleted));

          rebuildPostWidget.value = !rebuildPostWidget.value;
          break;
        }
      case const (LMFeedCommentSuccessState<AddCommentReplyResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          AddCommentReplyResponse response = commentSuccessState
              .commentActionResponse as AddCommentReplyResponse;

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!, users);

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
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          EditCommentReplyResponse response = commentSuccessState
              .commentActionResponse as EditCommentReplyResponse;

          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      case const (LMFeedCommentErrorState<DeleteCommentResponse>):
        {
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                  text: (state as DeleteCommentResponse).errorMessage ??
                      "An error occurred"),
            ),
          );
        }
      case const (LMFeedCommentErrorState<AddCommentRequest>,):
        {
          final LMFeedCommentErrorState<AddCommentResponse> commentErrorState =
              state as LMFeedCommentErrorState<AddCommentResponse>;
          removeTempCommentFromController(
              commentErrorState.commentMetaData.commentId!);
          LMFeedCore.showSnackBar(LMFeedSnackBar(
              content: Text(
                  commentErrorState.commentActionResponse.errorMessage ??
                      'An error occurred')));
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
          ..createdAt(DateTime.now())
          ..updatedAt(DateTime.now())
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
    }

    // if (!replyShown)
    {
      LMFeedFetchCommentReplyBloc.instance
          .add(LMFeedAddLocalReplyEvent(comment: commentViewData));
    }
  }

  void addTempCommentToController(String tempId, String text, int level) {
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
          ..createdAt(DateTime.now())
          ..updatedAt(DateTime.now())
          ..isLiked(false)
          ..user(currentUser)
          ..tempId(tempId))
        .build();
    postData!.commentCount += 1;
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
