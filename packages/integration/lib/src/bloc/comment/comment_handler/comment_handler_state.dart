part of 'comment_handler_bloc.dart';

/// {@template lm_comment_handler_state}
/// [LMCommentHandlerState] defines the states which
/// are emitted by LMCommentHandlerBloc
/// {@endtemplate}
abstract class LMCommentHandlerState extends Equatable {
  /// {@macro lm_comment_handler_state}
  const LMCommentHandlerState();

  @override
  List<Object> get props => [];
}

/// {@template lm_comment_initial_state}
/// [LMCommentInitialState] is the initial state of the LMCommentHandlerBloc
/// {@endtemplate}
class LMCommentInitialState extends LMCommentHandlerState {}

/// {@template lm_comment_loading_state}
/// [LMCommentLoadingState] is the state emitted when the comment related
/// action is being performed
/// i.e. Add, Edit, Delete, etc.
/// {@endtemplate}
class LMCommentLoadingState extends LMCommentHandlerState {
  // @{macro lm_comment_meta_data}
  final LMCommentMetaData commentMetaData;

  /// {@macro lm_comment_loading_state}
  const LMCommentLoadingState({
    required this.commentMetaData,
  });

  @override
  List<Object> get props => [commentMetaData];
}

/// {@template lm_comment_error_state}
/// [LMCommentErrorState] is the state emitted when the comment related
/// action fails
/// i.e. Add, Edit, Delete, etc.
/// {@endtemplate}
class LMCommentErrorState<Response extends Object>
    extends LMCommentHandlerState {
  // @{macro lm_comment_meta_data}
  final LMCommentMetaData commentMetaData;

  // [Response] defines the response of the comment related action
  // i.e. Add, Edit, Delete, etc.
  // [REQUIRED]
  // It can be of type AddCommentResponse, AddCommentReplyResponse,
  // EditCommentResponse, EditCommentReplyResponse,
  // DeleteCommentResponse
  final Response commentActionResponse;

  // {@macro lm_comment_error_state}
  const LMCommentErrorState({
    required this.commentMetaData,
    required this.commentActionResponse,
  });

  @override
  List<Object> get props => [commentMetaData, commentActionResponse];
}

/// {@template lm_comment_success_state}
/// [LMCommentSuccessState] is the state emitted when the comment related
/// action is successful
/// i.e. Add, Edit, Delete, etc.
/// {@endtemplate}
class LMCommentSuccessState<Response extends Object>
    extends LMCommentHandlerState {
  // @{macro lm_comment_meta_data}
  final LMCommentMetaData commentMetaData;

  // [Response] defines the response of the comment related action
  // i.e. Add, Edit, Delete, etc.
  // [REQUIRED]
  // It can be of type AddCommentResponse, AddCommentReplyResponse,
  // EditCommentResponse, EditCommentReplyResponse,
  // DeleteCommentResponse
  final Response commentActionResponse;

  // {@macro lm_comment_success_state}
  const LMCommentSuccessState({
    required this.commentMetaData,
    required this.commentActionResponse,
  });

  @override
  List<Object> get props => [commentMetaData, commentActionResponse];
}

/// {@template lm_comment_action_ongoing_state}
/// [LMCommentActionOngoingState] state is used to generate view for
/// Editing or Replying flow for both comment and replies to comments
/// {@endtemplate}
class LMCommentActionOngoingState extends LMCommentHandlerState {
  // [LMCommentMetaData] defines the metadata of the comment
  // which is being added, edited or deleted
  // [REQUIRED]
  final LMCommentMetaData commentMetaData;

  // {@macro lm_comment_action_ongoing_state}
  const LMCommentActionOngoingState({
    required this.commentMetaData,
  });

  @override
  List<Object> get props => [commentMetaData];
}

/// {@template lm_comment_canceled_state}
/// [LMCommentCanceledState] is the state emitted when the comment related
/// action is canceled
/// i.e. A user was editing a comment/reply or replying to a existing comment
/// but cancelled the action
/// {@endtemplate}
class LMCommentCanceledState extends LMCommentHandlerState {}
