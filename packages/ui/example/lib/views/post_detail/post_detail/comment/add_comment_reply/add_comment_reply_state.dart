part of 'add_comment_reply_bloc.dart';

abstract class LMCommentHandlerState extends Equatable {
  const LMCommentHandlerState();

  @override
  List<Object> get props => [];
}

class LMCommentInitialState extends LMCommentHandlerState {}

class LMCommentLoadingState extends LMCommentHandlerState {}

class LMAddCommentReplySuccessState extends LMCommentHandlerState {
  final AddCommentReplyResponse addCommentResponse;
  const LMAddCommentReplySuccessState({required this.addCommentResponse});
}

class LMAddCommentReplyErrorState extends LMCommentHandlerState {
  final String message;
  const LMAddCommentReplyErrorState({required this.message});
}

class LMCommentEditingStartedState extends LMCommentHandlerState {
  final String commentId;
  final String text;

  const LMCommentEditingStartedState(
      {required this.commentId, required this.text});
}

class LMEditCommentLoadingState extends LMCommentHandlerState {}

class LMEditCommentCanceledState extends LMCommentHandlerState {}

class LMEditCommentSuccessState extends LMCommentHandlerState {
  final EditCommentResponse editCommentResponse;

  const LMEditCommentSuccessState({required this.editCommentResponse});
}

class LMEditCommentErrorState extends LMCommentHandlerState {
  final String message;
  const LMEditCommentErrorState({required this.message});
}

class LMReplyEditingStartedState extends LMCommentHandlerState {
  final String commentId;
  final String text;
  final String replyId;

  const LMReplyEditingStartedState(
      {required this.commentId, required this.text, required this.replyId});
}

class LMEditReplyLoadingState extends LMCommentHandlerState {}

class LMEditReplyCanceledState extends LMCommentHandlerState {}

class LMEditReplySuccessState extends LMCommentHandlerState {
  final EditCommentReplyResponse editCommentReplyResponse;

  const LMEditReplySuccessState({required this.editCommentReplyResponse});
}

class LMEditReplyErrorState extends LMCommentHandlerState {
  final String message;
  const LMEditReplyErrorState({required this.message});
}

class LMCommentDeletionLoadingState extends LMCommentHandlerState {}

class LMCommentDeletedState extends LMCommentHandlerState {
  final String commentId;
  const LMCommentDeletedState({
    required this.commentId,
  });
}

class LMCommentDeleteErrorState extends LMCommentHandlerState {}

class LMReplyDeletionLoadingState extends LMCommentHandlerState {}

class LMCommentReplyDeletedState extends LMCommentHandlerState {
  final String replyId;
  const LMCommentReplyDeletedState({
    required this.replyId,
  });
}

class LMCommentReplyDeleteErrorState extends LMCommentHandlerState {}
