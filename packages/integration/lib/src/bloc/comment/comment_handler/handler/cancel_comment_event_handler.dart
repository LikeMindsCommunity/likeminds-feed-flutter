part of '../comment_handler_bloc.dart';

/// {@template cancel_comment_event_handler}
void handleCancelCommentEvent(
        LMCommentCancelEvent event, Emitter<LMCommentHandlerState> emit) =>
    emit(LMCommentCanceledState());
