part of '../comment_handler_bloc.dart';

/// {@template ongoing_comment_event_handler}
/// [handleOngoingCommentEvent] is used to handle the ongoing event
/// i.e. A user is editing a comment/reply
/// [LMCommentOngoingEvent] is used to send the request to the handler
/// or replying to a existing comment
void handleOngoingCommentEvent(
        LMCommentOngoingEvent event, Emitter<LMCommentHandlerState> emit) =>
    emit(
      LMCommentActionOngoingState(commentMetaData: event.commentMetaData),
    );
