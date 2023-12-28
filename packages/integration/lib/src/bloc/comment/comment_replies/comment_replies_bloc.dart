import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';

part 'comment_replies_event.dart';
part 'comment_replies_state.dart';

/// {@template lm_fetch_comment_reply_bloc}
/// [LMFetchCommentReplyBloc] fetches the replies for a comment
/// {@endtemplate}
class LMFetchCommentReplyBloc
    extends Bloc<LMCommentRepliesEvent, LMCommentRepliesState> {
  static LMFetchCommentReplyBloc? _instance;

  static LMFetchCommentReplyBloc get instance =>
      _instance ??= LMFetchCommentReplyBloc._();

  LMFeedCore lmFeedIntegration = LMFeedCore.instance;
  LMFetchCommentReplyBloc._() : super(LMCommentRepliesInitial()) {
    on<LMCommentRepliesEvent>((event, emit) async {
      if (event is LMGetCommentReplies) {
        await _mapGetCommentRepliesToState(
            commentDetailRequest: event.commentDetailRequest,
            forLoadMore: event.forLoadMore,
            emit: emit,
            lmFeedIntegration: lmFeedIntegration);
      }
    });
    on<LMClearCommentReplies>(
      (event, emit) {
        emit(LMClearedCommentReplies());
      },
    );
  }

  FutureOr<void> _mapGetCommentRepliesToState(
      {required GetCommentRequest commentDetailRequest,
      required bool forLoadMore,
      required Emitter<LMCommentRepliesState> emit,
      required LMFeedCore lmFeedIntegration}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User> users = {};
    List<Comment> comments = [];
    if (state is LMCommentRepliesLoaded &&
        forLoadMore &&
        commentDetailRequest.commentId ==
            (state as LMCommentRepliesLoaded).commentId) {
      comments = (state as LMCommentRepliesLoaded)
              .commentDetails
              .postReplies!
              .replies ??
          [];
      users = (state as LMCommentRepliesLoaded).commentDetails.users!;
      emit(LMPaginatedCommentRepliesLoading(
          commentId: commentDetailRequest.commentId,
          prevCommentDetails:
              (state as LMCommentRepliesLoaded).commentDetails));
    } else {
      emit(LMCommentRepliesLoading(commentId: commentDetailRequest.commentId));
    }

    GetCommentResponse response =
        await lmFeedIntegration.lmFeedClient.getComment(commentDetailRequest);
    if (!response.success) {
      emit(const LMCommentRepliesError(message: "An error occurred"));
    } else {
      response.postReplies!.replies?.insertAll(0, comments);
      response.users!.addAll(users);
      emit(LMCommentRepliesLoaded(
        commentDetails: response,
        commentId: commentDetailRequest.commentId,
      ));
    }
  }
}
