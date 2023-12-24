import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class PostDetailScreenHandler {
  final Map<String, UserViewData> users = {};
  final PagingController<int, CommentViewData> commetListPagingController;
  final String postId;
  late final LMCommentHandlerBloc commentHandlerBloc;

  PostDetailScreenHandler(this.commetListPagingController, this.postId) {
    commentHandlerBloc = LMCommentHandlerBloc.instance;
    addCommentListPaginationListener();
  }

  Future<PostViewData?> fetchCommentListWithPage(int page) async {
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
      final PostViewData postViewData =
          PostViewDataConvertor.fromPost(post: response.post!);

      final List<CommentViewData> commentList = postViewData.replies;

      addCommentListToController(commentList, 2);

      return postViewData;
    } else {
      toast(
        response.errorMessage ?? 'An error occurred',
        duration: Toast.LENGTH_LONG,
      );
    }
    return null;
  }

  void addCommentListToController(
      List<CommentViewData> commentList, int nextPageKey) {
    commetListPagingController.appendPage(commentList, nextPageKey);
  }

  void addCommentListPaginationListener() {
    commetListPagingController.addPageRequestListener((pageKey) async {
      final PostViewData? response = await fetchCommentListWithPage(pageKey);

      if (response != null) {
        final PostViewData postViewData = response;
        final List<CommentViewData> commentList = postViewData.replies;

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
              deleteCommentFromController(state.commentMetaData.commentId);
            } else if (commentSuccessState.commentMetaData.commentActionType ==
                LMCommentActionType.add) {
              AddCommentResponse response = commentSuccessState
                  .commentActionResponse as AddCommentResponse;

              CommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);

              addCommentToController(commentViewData);
            } else {
              EditCommentResponse response = commentSuccessState
                  .commentActionResponse as EditCommentResponse;

              CommentViewData commentViewData =
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

              CommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);
            } else {
              EditCommentReplyResponse response = commentSuccessState
                  .commentActionResponse as EditCommentReplyResponse;

              CommentViewData commentViewData =
                  CommentViewDataConvertor.fromComment(response.reply!);
            }
          }

          break;
        }
    }
  }

  void addCommentToController(CommentViewData commentViewData) {
    commetListPagingController.itemList?.insert(0, commentViewData);
  }

  void deleteCommentFromController(String commentId) {
    commetListPagingController.itemList
        ?.removeWhere((element) => element.id == commentId);
  }

  void updateCommentInController(CommentViewData commentViewData) {
    final index = commetListPagingController.itemList
        ?.indexWhere((element) => element.id == commentViewData.id);
    if (index != null && index >= 0) {
      commetListPagingController.itemList![index] = commentViewData;
    }
  }
}
