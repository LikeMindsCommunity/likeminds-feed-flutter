import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'comment_replies_event.dart';
part 'comment_replies_state.dart';

/// {@template lm_fetch_comment_reply_bloc}
/// [LMFeedFetchCommentReplyBloc] fetches the replies for a comment
/// {@endtemplate}
class LMFeedFetchCommentReplyBloc
    extends Bloc<LMFeedCommentRepliesEvent, LMFeedCommentRepliesState> {
  static LMFeedFetchCommentReplyBloc? _instance;

  static LMFeedFetchCommentReplyBloc get instance =>
      _instance ??= LMFeedFetchCommentReplyBloc._();

  LMFeedCore lmFeedIntegration = LMFeedCore.instance;
  LMFeedFetchCommentReplyBloc._() : super(LMFeedCommentRepliesInitialState()) {
    on<LMFeedDeleteLocalReplyEvent>((event, emit) =>
        emit(LMFeedDeleteLocalReplyState(replyId: event.replyId)));
    on<LMFeedCommentRepliesEvent>((event, emit) async {
      if (event is LMFeedGetCommentRepliesEvent) {
        await _mapGetCommentRepliesToState(
            commentDetailRequest: event.commentDetailRequest,
            forLoadMore: event.forLoadMore,
            emit: emit,
            lmFeedIntegration: lmFeedIntegration);
      } else if (event is LMFeedClearCommentRepliesEvent)
        emit(LMFeedClearedCommentRepliesState());
      else if (event is LMFeedAddLocalReplyEvent)
        emit(LMFeedAddLocalReplyState(comment: event.comment));
    });
  }

  FutureOr<void> _mapGetCommentRepliesToState(
      {required GetCommentRequest commentDetailRequest,
      required bool forLoadMore,
      required Emitter<LMFeedCommentRepliesState> emit,
      required LMFeedCore lmFeedIntegration}) async {
    Map<String, User> users = {};
    List<Comment> comments = [];
    if (state is LMFeedCommentRepliesLoadedState &&
        forLoadMore &&
        commentDetailRequest.commentId ==
            (state as LMFeedCommentRepliesLoadedState).commentId) {
      comments = (state as LMFeedCommentRepliesLoadedState)
              .commentDetails
              .postReplies!
              .replies ??
          [];
      users = (state as LMFeedCommentRepliesLoadedState).commentDetails.users!;
      emit(LMFeedPaginatedCommentRepliesLoadingState(
          commentId: commentDetailRequest.commentId,
          prevCommentDetails:
              (state as LMFeedCommentRepliesLoadedState).commentDetails));
    } else {
      emit(LMFeedCommentRepliesLoadingState(
          commentId: commentDetailRequest.commentId));
    }

    GetCommentResponse response =
        await lmFeedIntegration.lmFeedClient.getComment(commentDetailRequest);
    if (!response.success) {
      emit(const LMFeedCommentRepliesErrorState(message: "An error occurred"));
    } else {
      response.postReplies!.replies?.insertAll(0, comments);
      response.users!.addAll(users);
      emit(LMFeedCommentRepliesLoadedState(
        commentDetails: response,
        commentId: commentDetailRequest.commentId,
      ));
    }
  }
}
