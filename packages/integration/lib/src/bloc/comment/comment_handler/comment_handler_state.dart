part of 'comment_handler_bloc.dart';

abstract class LMCommentHandlerState extends Equatable {
  const LMCommentHandlerState();

  @override
  List<Object> get props => [];
}

class LMCommentInitialState extends LMCommentHandlerState {}

class LMCommentLoadingState extends LMCommentHandlerState {
  final LMCommentMetaData commentMetaData;

  const LMCommentLoadingState({
    required this.commentMetaData,
  });

  @override
  List<Object> get props => [commentMetaData];
}

class LMCommentErrorState<Response extends Object>
    extends LMCommentHandlerState {
  final LMCommentMetaData commentMetaData;
  final Response commentActionResponse;

  const LMCommentErrorState({
    required this.commentMetaData,
    required this.commentActionResponse,
  });

  @override
  List<Object> get props => [commentMetaData, commentActionResponse];
}

class LMCommentSuccessState<Response extends Object>
    extends LMCommentHandlerState {
  final LMCommentMetaData commentMetaData;
  final Response commentActionResponse;

  const LMCommentSuccessState({
    required this.commentMetaData,
    required this.commentActionResponse,
  });

  @override
  List<Object> get props => [commentMetaData, commentActionResponse];
}

// [LMCommentActionOngoingState] state is used to generate view for
// Editing or Replying flow for both comment and replies to comments
class LMCommentActionOngoingState extends LMCommentHandlerState {
  // [LMCommentMetaData] defines the metadata of the comment
  // which is being added, edited or deleted
  // [REQUIRED]
  final LMCommentMetaData commentMetaData;

  const LMCommentActionOngoingState({
    required this.commentMetaData,
  });

  @override
  List<Object> get props => [commentMetaData];
}

class LMCommentCanceledState extends LMCommentHandlerState {
  final LMCommentMetaData lmCommentMetaData;

  const LMCommentCanceledState({
    required this.lmCommentMetaData,
  });
}
