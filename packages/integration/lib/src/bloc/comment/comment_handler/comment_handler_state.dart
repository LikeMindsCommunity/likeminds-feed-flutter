// part of 'comment_handler_bloc.dart';

// /// {@template lm_comment_handler_state}
// /// [LMFeedCommentHandlerState] defines the states which
// /// are emitted by LMFeedCommentHandlerBloc
// /// {@endtemplate}
// abstract class LMFeedCommentHandlerState extends Equatable {
//   /// {@macro lm_comment_handler_state}
//   const LMFeedCommentHandlerState();

//   @override
//   List<Object> get props => [];
// }

// /// {@template lm_comment_initial_state}
// /// [LMFeedCommentInitialState] is the initial state of the LMFeedCommentHandlerBloc
// /// {@endtemplate}
// class LMFeedCommentInitialState extends LMFeedCommentHandlerState {}

// /// {@template lm_comment_loading_state}
// /// [LMFeedCommentLoadingState] is the state emitted when the comment related
// /// action is being performed
// /// i.e. Add, Edit, Delete, etc.
// /// {@endtemplate}
// class LMFeedCommentLoadingState extends LMFeedCommentHandlerState {
//   // @{macro lm_comment_meta_data}
//   final LMCommentMetaData commentMetaData;

//   /// {@macro lm_comment_loading_state}
//   const LMFeedCommentLoadingState({
//     required this.commentMetaData,
//   });

//   @override
//   List<Object> get props => [commentMetaData];
// }

// /// {@template lm_comment_error_state}
// /// [LMFeedCommentErrorState] is the state emitted when the comment related
// /// action fails
// /// i.e. Add, Edit, Delete, etc.
// /// {@endtemplate}
// class LMFeedCommentErrorState<Response extends Object>
//     extends LMFeedCommentHandlerState {
//   // @{macro lm_comment_meta_data}
//   final LMCommentMetaData commentMetaData;

//   // [Response] defines the response of the comment related action
//   // i.e. Add, Edit, Delete, etc.
//   // [REQUIRED]
//   // It can be of type AddCommentResponse, AddCommentReplyResponse,
//   // EditCommentResponse, EditCommentReplyResponse,
//   // DeleteCommentResponse
//   final Response commentActionResponse;

//   // {@macro lm_comment_error_state}
//   const LMFeedCommentErrorState({
//     required this.commentMetaData,
//     required this.commentActionResponse,
//   });

//   @override
//   List<Object> get props => [commentMetaData, commentActionResponse];
// }

// /// {@template lm_comment_success_state}
// /// [LMFeedCommentSuccessState] is the state emitted when the comment related
// /// action is successful
// /// i.e. Add, Edit, Delete, etc.
// /// {@endtemplate}
// class LMFeedCommentSuccessState<Response extends Object>
//     extends LMFeedCommentHandlerState {
//   // @{macro lm_comment_meta_data}
//   final LMCommentMetaData commentMetaData;

//   // [Response] defines the response of the comment related action
//   // i.e. Add, Edit, Delete, etc.
//   // [REQUIRED]
//   // It can be of type AddCommentResponse, AddCommentReplyResponse,
//   // EditCommentResponse, EditCommentReplyResponse,
//   // DeleteCommentResponse
//   final Response commentActionResponse;

//   // {@macro lm_comment_success_state}
//   const LMFeedCommentSuccessState({
//     required this.commentMetaData,
//     required this.commentActionResponse,
//   });

//   @override
//   List<Object> get props => [commentMetaData, commentActionResponse];
// }

// /// {@template lm_comment_action_ongoing_state}
// /// [LMFeedCommentActionOngoingState] state is used to generate view for
// /// Editing or Replying flow for both comment and replies to comments
// /// {@endtemplate}
// class LMFeedCommentActionOngoingState extends LMFeedCommentHandlerState {
//   // [LMCommentMetaData] defines the metadata of the comment
//   // which is being added, edited or deleted
//   // [REQUIRED]
//   final LMCommentMetaData commentMetaData;

//   // {@macro lm_comment_action_ongoing_state}
//   const LMFeedCommentActionOngoingState({
//     required this.commentMetaData,
//   });

//   @override
//   List<Object> get props => [commentMetaData];
// }

// /// {@template lm_comment_canceled_state}
// /// [LMFeedCommentCanceledState] is the state emitted when the comment related
// /// action is canceled
// /// i.e. A user was editing a comment/reply or replying to a existing comment
// /// but cancelled the action
// /// {@endtemplate}
// class LMFeedCommentCanceledState extends LMFeedCommentHandlerState {}
