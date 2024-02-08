part of '../comment_handler_bloc.dart';

/// {@template ongoing_comment_event_handler}
/// [handleOngoingCommentEvent] is used to handle the ongoing event
/// i.e. A user is editing a comment/reply
/// [LMFeedCommentOngoingEvent] is used to send the request to the handler
/// or replying to a existing comment
/// {@endtemplate}
void handleOngoingCommentEvent(LMFeedCommentOngoingEvent event,
        Emitter<LMFeedCommentHandlerState> emit) =>
    emit(
      // @{macro lm_ongoing_comment_state}
      LMFeedCommentActionOngoingState(commentMetaData: event.commentMetaData),
    );
