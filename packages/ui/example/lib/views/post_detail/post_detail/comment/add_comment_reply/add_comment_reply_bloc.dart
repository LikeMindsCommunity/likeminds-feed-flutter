import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:lm_feed_ui_example/services/likeminds_service.dart';
import 'package:lm_feed_ui_example/services/service_locator.dart';
import 'package:lm_feed_ui_example/utils/analytics/analytics.dart';
import 'package:overlay_support/overlay_support.dart';

part 'add_comment_reply_event.dart';

part 'add_comment_reply_state.dart';

class LMCommentHandlerBloc
    extends Bloc<LMCommentHandlerEvent, LMCommentHandlerState> {
  LMCommentHandlerBloc() : super(LMCommentInitialState()) {
    on<LMAddCommentReplyEvent>(
      (event, emit) async {
        await _mapAddCommentReplyToState(
          addCommentReplyRequest: event.addCommentRequest,
          emit: emit,
        );
      },
    );
    on<LMEditReplyCancelEvent>(
      (event, emit) {
        emit(LMEditReplyCanceledState());
      },
    );
    on<LMEditingReplyEvent>((event, emit) {
      emit(
        LMReplyEditingStartedState(
          commentId: event.commentId,
          text: event.text,
          replyId: event.replyId,
        ),
      );
    });
    on<LMEditReplyEvent>((event, emit) async {
      emit(LMEditReplyLoadingState());
      EditCommentReplyResponse? response = await locator<LikeMindsService>()
          .editCommentReply(event.editCommentReplyRequest);
      if (!response.success) {
        emit(const LMEditReplyErrorState(message: "An error occurred"));
      } else {
        emit(LMEditReplySuccessState(editCommentReplyResponse: response));
      }
    });
    on<LMEditCommentCancelEvent>(
      (event, emit) {
        emit(LMEditCommentCanceledState());
      },
    );
    on<LMEditingCommentEvent>((event, emit) {
      emit(
        LMCommentEditingStartedState(
          commentId: event.commentId,
          text: event.text,
        ),
      );
    });
    on<LMEditCommentEvent>((event, emit) async {
      emit(LMEditCommentLoadingState());
      EditCommentResponse? response = await locator<LikeMindsService>()
          .editComment(event.editCommentRequest);
      if (!response.success) {
        emit(const LMEditCommentErrorState(message: "An error occurred"));
      } else {
        emit(LMEditCommentSuccessState(editCommentResponse: response));
      }
    });
    on<LMDeleteCommentEvent>(
      (event, emit) async {
        try {
          emit(LMCommentDeletionLoadingState());
          final response = await locator<LikeMindsService>().deleteComment(
            event.deleteCommentRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            emit(
              LMCommentDeletedState(
                commentId: event.deleteCommentRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(LMCommentDeleteErrorState());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting comment',
            duration: Toast.LENGTH_LONG,
          );
          emit(LMCommentDeleteErrorState());
        }
      },
    );
    on<LMDeleteCommentReplyEvent>(
      (event, emit) async {
        try {
          emit(LMReplyDeletionLoadingState());
          final response = await locator<LikeMindsService>().deleteComment(
            event.deleteCommentReplyRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            emit(
              LMCommentReplyDeletedState(
                replyId: event.deleteCommentReplyRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(LMCommentDeleteErrorState());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting reply',
            duration: Toast.LENGTH_LONG,
          );
          emit(LMCommentDeleteErrorState());
        }
      },
    );
  }

  FutureOr<void> _mapAddCommentReplyToState(
      {required AddCommentReplyRequest addCommentReplyRequest,
      required Emitter<LMCommentHandlerState> emit}) async {
    emit(LMCommentLoadingState());
    AddCommentReplyResponse response = await locator<LikeMindsService>()
        .addCommentReply(addCommentReplyRequest);
    if (!response.success) {
      emit(const LMAddCommentReplyErrorState(message: "No data found"));
    } else {
      LMAnalytics.get().track(
        AnalyticsKeys.replyPosted,
        {
          "post_id": addCommentReplyRequest.postId,
          "comment_id": addCommentReplyRequest.commentId,
        },
      );
      emit(LMAddCommentReplySuccessState(addCommentResponse: response));
    }
  }
}
