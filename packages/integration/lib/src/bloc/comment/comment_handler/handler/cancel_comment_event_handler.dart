part of '../comment_handler_bloc.dart';

/// {@template cancel_comment_event_handler}
/// [handleCancelCommentEvent] is used to remove editing or replying
/// state from the UI
/// [LMCommentCancelEvent] is used to send the request to the handler
/// {@endtemplate}
void handleCancelCommentEvent(
        LMCommentCancelEvent event, Emitter<LMCommentHandlerState> emit) =>
    emit(LMCommentCanceledState());
