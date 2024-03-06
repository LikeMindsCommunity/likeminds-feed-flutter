import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';

class LMFeedPostDetailScreenHandler {
  final Map<String, LMUserViewData> users = {};
  final PagingController<int, LMCommentViewData> commetListPagingController;
  final String postId;
  late final LMFeedCommentBloc commentHandlerBloc;
  late final FocusNode focusNode;
  late final TextEditingController commentController;
  final ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMPostViewData> repostedPosts = {};
  Map<String, LMWidgetViewData> widgets = {};
  LMPostViewData? postData;

  LMFeedPostDetailScreenHandler(this.commetListPagingController, this.postId) {
    commentHandlerBloc = LMFeedCommentBloc.instance;
    addCommentListPaginationListener();
    commentController = TextEditingController();
    focusNode = FocusNode();
  }

  Future<LMPostViewData?> fetchCommentListWithPage(int page) async {
    PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
          ..postId(postId)
          ..page(page))
        .build();

    final response = await LMFeedCore.client.getPostDetails(postDetailRequest);

    if (response.success) {
      // Convert [User] to [LMUserViewData]
      // Add users to the map
      users.addAll(response.users!.map((key, value) =>
          MapEntry(key, LMUserViewDataConvertor.fromUser(value))));

      // Convert [Topic] to [LMTopicViewData]
      // Add topics to the map
      topics.addAll(response.topics!.map((key, value) =>
          MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))));

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
              ))) ??
          {});

      // Convert [WidgetModel] to [LMWidgetViewData]
      // Add widgets to the map
      widgets.addAll(response.widgets?.map((key, value) => MapEntry(
              key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
          {});

      // Convert [Post] to [LMPostViewData]
      // Add post data, and all supporting data to the map
      final LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
        post: response.post!,
        widgets: response.widgets,
        repostedPosts: response.repostedPosts,
        users: response.users ?? {},
        topics: response.topics ?? {},
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
      // TODO: remove old toast
      // toast(
      //   response.errorMessage ?? 'An error occurred',
      //   duration: Toast.LENGTH_LONG,
      // );

      return null;
    }
  }

  void addCommentListToController(
      List<LMCommentViewData> commentList, int nextPageKey) {
    final isLastPage = commentList.length < 10;
    if (isLastPage) {
      commetListPagingController.appendLastPage(commentList);
    } else {
      commetListPagingController.appendPage(commentList, nextPageKey);
    }
  }

  void addCommentListPaginationListener() {
    commetListPagingController.addPageRequestListener((pageKey) async {
      await fetchCommentListWithPage(pageKey);
    });
  }

  bool checkCommentRights() {
    final MemberStateResponse memberStateResponse =
        LMFeedUserLocalPreference.instance.fetchMemberRights();
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    bool memberRights = LMFeedUserLocalPreference.instance.fetchMemberRight(10);
    return memberRights;
  }

  void handleBlocChanges(LMFeedCommentHandlerState state) {
    switch (state.runtimeType) {
      case LMFeedCommentActionOngoingState:
        {
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

          postData!.commentCount += 1;

          addCommentToController(commentViewData);

          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postData!));

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
            deleteCommentFromController(
                commentSuccessState.commentMetaData.commentId!);
            postData!.commentCount -= 1;
          } else {
            LMCommentViewData? commentViewData =
                commetListPagingController.itemList?.firstWhere((element) =>
                    element.id ==
                    commentSuccessState.commentMetaData.commentId);
            if (commentViewData != null) {
              updateCommentInController(commentViewData);
            }
          }

          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postData!));

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
    }
  }

  void addCommentToController(LMCommentViewData commentViewData) {
    commetListPagingController.itemList?.insert(0, commentViewData);
  }

  void deleteCommentFromController(String commentId) {
    commetListPagingController.itemList
        ?.removeWhere((element) => element.id == commentId);
  }

  void updateCommentInController(LMCommentViewData commentViewData) {
    final index = commetListPagingController.itemList
        ?.indexWhere((element) => element.id == commentViewData.id);
    if (index != null && index >= 0) {
      commetListPagingController.itemList![index] = commentViewData;
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
