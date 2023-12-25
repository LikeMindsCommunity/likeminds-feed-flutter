import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class PostDetailScreenHandler {
  final Map<String, LMUserViewData> users = {};
  final PagingController<int, LMCommentViewData> commetListPagingController;
  final String postId;
  late final LMCommentHandlerBloc commentHandlerBloc;
  late final FocusNode focusNode;
  late final TextEditingController commentController;

  PostDetailScreenHandler(this.commetListPagingController, this.postId) {
    commentHandlerBloc = LMCommentHandlerBloc.instance;
    addCommentListPaginationListener();
    commentController = TextEditingController();
    focusNode = FocusNode();
  }

  Future<LMPostViewData?> fetchCommentListWithPage(int page) async {
    PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
          ..postId(postId)
          ..page(page))
        .build();

    final response = await LMFeedIntegration.instance.lmFeedClient
        .getPostDetails(postDetailRequest);

    users.addAll(response.users?.map((key, value) =>
            MapEntry(key, UserViewDataConvertor.fromUser(value))) ??
        {});

    if (response.success) {
      final LMPostViewData postViewData =
          PostViewDataConvertor.fromPost(post: response.post!);

      final List<LMCommentViewData> commentList = postViewData.replies;

      addCommentListToController(commentList, 2);

      return postViewData;
    } else {
      toast(
        response.errorMessage ?? 'An error occurred',
        duration: Toast.LENGTH_LONG,
      );

      return null;
    }
  }

  void addCommentListToController(
      List<LMCommentViewData> commentList, int nextPageKey) {
    commetListPagingController.appendPage(commentList, nextPageKey);
  }

  void addCommentListPaginationListener() {
    commetListPagingController.addPageRequestListener((pageKey) async {
      final LMPostViewData? response = await fetchCommentListWithPage(pageKey);

      if (response != null) {
        final LMPostViewData postViewData = response;
        final List<LMCommentViewData> commentList = postViewData.replies;

        final isLastPage = commentList.length < 10;
        if (isLastPage) {
          commetListPagingController.appendLastPage(commentList);
        } else {
          final nextPageKey = pageKey + 1;
          commetListPagingController.appendPage(commentList, nextPageKey);
        }
      }
    });
  }

  bool checkCommentRights() {
    final MemberStateResponse memberStateResponse =
        UserLocalPreference.instance.fetchMemberRights();
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    bool memberRights = UserLocalPreference.instance.fetchMemberRight(10);
    return memberRights;
  }

  void handleBlocChanges(LMCommentHandlerState state) {
    switch (state.runtimeType) {
      case LMCommentActionOngoingState:
        break;

      case LMCommentSuccessState:
        {
          final LMCommentSuccessState commentSuccessState =
              state as LMCommentSuccessState;

          if (commentSuccessState.commentMetaData.commentActionEntity ==
              LMCommentType.parent) {
            if (commentSuccessState.commentMetaData.commentActionType ==
                LMCommentActionType.delete) {
              deleteCommentFromController(state.commentMetaData.commentId!);
            } else if (commentSuccessState.commentMetaData.commentActionType ==
                LMCommentActionType.add) {
              AddCommentResponse response = commentSuccessState
                  .commentActionResponse as AddCommentResponse;

              LMCommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);

              addCommentToController(commentViewData);
            } else {
              EditCommentResponse response = commentSuccessState
                  .commentActionResponse as EditCommentResponse;

              LMCommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);

              updateCommentInController(commentViewData);
            }
          } else {
            // TODO: handle reply action handling
            if (commentSuccessState.commentMetaData.commentActionType ==
                LMCommentActionType.delete) {
            } else if (commentSuccessState.commentMetaData.commentActionType ==
                LMCommentActionType.add) {
              AddCommentReplyResponse response = commentSuccessState
                  .commentActionResponse as AddCommentReplyResponse;

              LMCommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);
            } else {
              EditCommentReplyResponse response = commentSuccessState
                  .commentActionResponse as EditCommentReplyResponse;

              LMCommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);
            }
          }

          break;
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
