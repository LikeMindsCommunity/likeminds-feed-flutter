import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/constants/analytics/keys.dart';
import 'package:overlay_support/overlay_support.dart';

part 'add_comment_reply_event.dart';

part 'add_comment_reply_state.dart';

class AddCommentReplyBloc
    extends Bloc<AddCommentReplyEvent, AddCommentReplyState> {
  AddCommentReplyBloc() : super(AddCommentReplyInitial()) {
    LMFeedBloc lmFeedBloc = LMFeedBloc.get();

    on<ReplyCommentCancel>((event, emit) => emit(ReplyCommentCanceled()));
    on<AddCommentReply>(
      (event, emit) async {
        await _mapAddCommentReplyToState(
          addCommentReplyEvent: event,
          emit: emit,
          lmFeedBloc: lmFeedBloc,
        );
      },
    );
    on<EditReplyCancel>(
      (event, emit) {
        emit(EditReplyCanceled());
      },
    );
    on<EditingReply>((event, emit) {
      emit(
        ReplyEditingStarted(
          commentId: event.commentId,
          text: event.text,
          replyId: event.replyId,
        ),
      );
    });
    on<EditReply>((event, emit) async {
      emit(EditReplyLoading());
      EditCommentReplyResponse? response = await lmFeedBloc.lmFeedClient
          .editCommentReply(event.editCommentReplyRequest);
      if (!response.success) {
        emit(const EditReplyError(message: "An error occurred"));
      } else {
        emit(EditReplySuccess(editCommentReplyResponse: response));
      }
    });
    on<EditCommentCancel>(
      (event, emit) {
        emit(EditCommentCanceled());
      },
    );
    on<EditingComment>((event, emit) {
      emit(
        CommentEditingStarted(
          commentId: event.commentId,
          text: event.text,
        ),
      );
    });
    on<EditComment>((event, emit) async {
      emit(EditCommentLoading());
      EditCommentResponse? response =
          await lmFeedBloc.lmFeedClient.editComment(event.editCommentRequest);
      if (!response.success) {
        emit(const EditCommentError(message: "An error occurred"));
      } else {
        emit(EditCommentSuccess(editCommentResponse: response));
      }
    });
    on<DeleteComment>(
      (event, emit) async {
        try {
          emit(CommentDeletionLoading());
          final response = await lmFeedBloc.lmFeedClient.deleteComment(
            event.deleteCommentRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );

            lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
              eventName: AnalyticsKeys.commentDeleted,
              eventProperties: {
                "post_id": event.deleteCommentRequest.postId,
                "comment_id": event.deleteCommentRequest.commentId,
              },
            ));
            emit(
              CommentDeleted(
                commentId: event.deleteCommentRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(CommentDeleteError());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting comment',
            duration: Toast.LENGTH_LONG,
          );
          emit(CommentDeleteError());
        }
      },
    );
    on<DeleteCommentReply>(
      (event, emit) async {
        try {
          emit(ReplyDeletionLoading());
          final response = await lmFeedBloc.lmFeedClient.deleteComment(
            event.deleteCommentReplyRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
              eventName: AnalyticsKeys.replyDeleted,
              eventProperties: {
                "post_id": event.deleteCommentReplyRequest.postId,
                "comment_reply_id": event.deleteCommentReplyRequest.commentId,
              },
            ));
            emit(
              CommentReplyDeleted(
                replyId: event.deleteCommentReplyRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(CommentDeleteError());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting reply',
            duration: Toast.LENGTH_LONG,
          );
          emit(CommentDeleteError());
        }
      },
    );
  }

  FutureOr<void> _mapAddCommentReplyToState(
      {required AddCommentReply addCommentReplyEvent,
      required Emitter<AddCommentReplyState> emit,
      required LMFeedBloc lmFeedBloc}) async {
    emit(AddCommentReplyLoading());
    AddCommentReplyResponse response = await lmFeedBloc.lmFeedClient
        .addCommentReply(addCommentReplyEvent.addCommentRequest);
    if (!response.success) {
      emit(const AddCommentReplyError(message: "An error occurred"));
    } else {
      lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
        eventName: AnalyticsKeys.replyPosted,
        eventProperties: {
          "post_id": addCommentReplyEvent.addCommentRequest.postId,
          "comment_id": addCommentReplyEvent.addCommentRequest.commentId,
          "comment_reply_id": response.reply?.id,
          "user_id": addCommentReplyEvent.userId
        },
      ));
      emit(AddCommentReplySuccess(addCommentResponse: response));
    }
  }
}
