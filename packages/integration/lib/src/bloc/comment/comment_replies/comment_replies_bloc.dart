import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';

part 'comment_replies_event.dart';
part 'comment_replies_state.dart';

class CommentRepliesBloc
    extends Bloc<CommentRepliesEvent, CommentRepliesState> {
  LMFeedBloc lmFeedBloc = LMFeedBloc.get();
  CommentRepliesBloc() : super(CommentRepliesInitial()) {
    on<CommentRepliesEvent>((event, emit) async {
      if (event is GetCommentReplies) {
        await _mapGetCommentRepliesToState(
          commentDetailRequest: event.commentDetailRequest,
          forLoadMore: event.forLoadMore,
          emit: emit,
          lmFeedBloc: lmFeedBloc,
        );
      }
    });
    on<ClearCommentReplies>(
      (event, emit) {
        emit(ClearedCommentReplies());
      },
    );
  }

  FutureOr<void> _mapGetCommentRepliesToState(
      {required GetCommentRequest commentDetailRequest,
      required bool forLoadMore,
      required Emitter<CommentRepliesState> emit,
      required LMFeedBloc lmFeedBloc}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User> users = {};
    List<Comment> comments = [];
    if (state is CommentRepliesLoaded &&
        forLoadMore &&
        commentDetailRequest.commentId ==
            (state as CommentRepliesLoaded).commentId) {
      comments =
          (state as CommentRepliesLoaded).commentDetails.postReplies!.replies ??
              [];
      users = (state as CommentRepliesLoaded).commentDetails.users!;
      emit(PaginatedCommentRepliesLoading(
          commentId: commentDetailRequest.commentId,
          prevCommentDetails: (state as CommentRepliesLoaded).commentDetails));
    } else {
      emit(CommentRepliesLoading(commentId: commentDetailRequest.commentId));
    }

    GetCommentResponse response =
        await lmFeedBloc.lmFeedClient.getComment(commentDetailRequest);
    if (!response.success) {
      emit(const CommentRepliesError(message: "An error occurred"));
    } else {
      response.postReplies!.replies?.insertAll(0, comments);
      response.users!.addAll(users);
      emit(CommentRepliesLoaded(
        commentDetails: response,
        commentId: commentDetailRequest.commentId,
      ));
    }
  }
}
