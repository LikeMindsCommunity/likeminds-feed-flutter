import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedPostDetailScreenHandler {
  final Map<String, LMUserViewData> users = {};
  final PagingController<int, LMCommentViewData> commetListPagingController;
  final String postId;
  late final LMFeedCommentHandlerBloc commentHandlerBloc;
  late final FocusNode focusNode;
  late final TextEditingController commentController;
  final ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMTopicViewData> topics = {};

  LMFeedPostDetailScreenHandler(this.commetListPagingController, this.postId) {
    commentHandlerBloc = LMFeedCommentHandlerBloc.instance;
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
      users.addAll(response.users!.map((key, value) =>
          MapEntry(key, LMUserViewDataConvertor.fromUser(value))));

      topics.addAll(response.topics!.map((key, value) =>
          MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))));

      final LMPostViewData postViewData =
          LMPostViewDataConvertor.fromPost(post: response.post!);

      final List<LMCommentViewData> commentList = postViewData.replies;

      addCommentListToController(commentList, page + 1);

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
        break;
      case const (LMFeedCommentSuccessState<AddCommentResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;
          AddCommentResponse response =
              commentSuccessState.commentActionResponse as AddCommentResponse;

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!);

          addCommentToController(commentViewData);
          break;
        }
      case const (LMFeedCommentSuccessState<EditCommentResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          EditCommentResponse response =
              commentSuccessState.commentActionResponse as EditCommentResponse;

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!);

          updateCommentInController(commentViewData);
          break;
        }
      case const (LMFeedCommentSuccessState<DeleteCommentResponse>):
        {
          final LMFeedCommentSuccessState commentSuccessState =
              state as LMFeedCommentSuccessState;

          if (commentSuccessState.commentMetaData.commentActionEntity ==
              LMFeedCommentType.parent) {
            deleteCommentFromController(
                commentSuccessState.commentMetaData.commentId!);
          } else {
            LMCommentViewData? commentViewData =
                commetListPagingController.itemList?.firstWhere((element) =>
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

          LMCommentViewData commentViewData =
              LMCommentViewDataConvertor.fromComment(response.reply!);

          if (response.reply!.parentComment != null) {
            updateCommentInController(commentViewData.parentComment!);
          }
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
