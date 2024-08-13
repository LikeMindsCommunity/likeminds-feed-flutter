part of 'comment_bloc.dart';

/// {@template lm_feed_comment_state}
/// Comment state for the feed responsible for representing different states
/// of comment operations such as loading comments, successful retrieval,
/// and handling errors.
/// {@endtemplate}
@immutable
sealed class LMFeedCommentState extends Equatable {
  /// {@macro lm_feed_comment_state}
  const LMFeedCommentState();

  @override
  List<Object?> get props => [];
}

/// {@template lm_feed_comment_initial_state}
/// Initial state when the comment feature is first loaded. This state does
/// not carry any additional data.
/// {@endtemplate}
final class LMFeedCommentInitialState extends LMFeedCommentState {}

/// {@template lm_feed_comment_refresh_state}
/// State representing the refresh action for comments in the feed. This
/// state does not carry any additional data.
/// {@endtemplate}
final class LMFeedCommentRefreshState extends LMFeedCommentState {}

/// {@template lm_feed_comment_loading_state}
/// State representing the loading phase when comments are being fetched.
/// {@endtemplate}
final class LMFeedGetCommentLoadingState extends LMFeedCommentState {}

/// {@template lm_feed_comment_pagination_loading_state}
/// State representing the loading phase for paginated comments.
/// {@endtemplate}
final class LMFeedGetCommentPaginationLoadingState extends LMFeedCommentState {}

/// {@template lm_feed_comment_success_state}
/// State representing a successful fetch of comments. Contains the post,
/// list of comments, and the current page.
/// {@endtemplate}
final class LMFeedGetCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedGetCommentSuccessState] with the provided
  /// [post], [comments], and [page].
  ///
  /// [post] is the post for which comments have been fetched.
  /// [comments] is the list of comments that have been successfully retrieved.
  /// [page] is the current page number of the comments.
  LMFeedGetCommentSuccessState({
    required this.post,
    required this.comments,
    required this.page,
  });

  /// The post for which comments have been fetched.
  final LMPostViewData post;

  /// List of comments that have been successfully loaded.
  final List<LMCommentViewData> comments;

  /// Current page number of the comments.
  final int page;

  @override
  List<Object?> get props => [post, comments, page];
}

/// {@template lm_feed_comment_error_state}
/// State representing an error that occurred during the fetch of comments.
/// Contains an error message describing what went wrong.
/// {@endtemplate}
final class LMFeedGetCommentErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedGetCommentErrorState] with the provided [error].
  ///
  /// [error] describes the error that occurred during comment fetching.
  LMFeedGetCommentErrorState({
    required this.error,
  });

  /// Error message describing the reason for the failure.
  final String error;

  @override
  List<Object?> get props => [error];
}

/// {@template lm_feed_add_comment_success_state}
/// State representing a successful addition of a comment. Contains the
/// newly added comment.
/// {@endtemplate}
final class LMFeedAddCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedAddCommentSuccessState] with the provided [comment].
  ///
  /// [comment] is the comment that has been successfully added.
  LMFeedAddCommentSuccessState({
    required this.comment,
  });

  /// The comment that has been successfully added.
  final LMCommentViewData comment;

  @override
  List<Object?> get props => [comment];
}

/// {@template lm_feed_add_comment_error_state}
/// State representing an error that occurred during the addition of a comment.
/// Contains an error message and the ID of the comment that failed to be added.
/// {@endtemplate}
final class LMFeedAddCommentErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedAddCommentErrorState] with the provided [error]
  /// and [commentId].
  ///
  /// [error] describes the error that occurred during comment addition.
  /// [commentId] is the ID of the comment that failed to be added.
  LMFeedAddCommentErrorState({
    required this.error,
    required this.commentId,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// ID of the comment that failed to be added.
  final String commentId;

  @override
  List<Object?> get props => [error, commentId];
}

/// {@template lm_feed_editing_comment_state}
/// State representing the start of editing a comment. Contains the ID of the
/// post and the old comment data.
/// {@endtemplate}
final class LMFeedEditingCommentState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditingCommentState] with the provided [postId]
  /// and [oldComment].
  ///
  /// [postId] is the ID of the post to which the comment belongs.
  /// [oldComment] is the comment that is being edited.
  LMFeedEditingCommentState({
    required this.postId,
    required this.oldComment,
  });

  /// ID of the post to which the comment belongs.
  final String postId;

  /// The comment that is being edited.
  final LMCommentViewData oldComment;

  @override
  List<Object?> get props => [postId, oldComment];
}

/// {@template lm_feed_edit_comment_cancel_state}
/// State representing the cancellation of editing a comment. This state
/// {@endtemplate}
final class LMFeedEditingCommentCancelState extends LMFeedCommentState {}

/// {@template lm_feed_edit_comment_success_state}
/// State representing a successful edit of a comment. Contains the updated
/// comment data.
/// {@endtemplate}
final class LMFeedEditCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditCommentSuccessState] with the provided
  /// [commentViewData].
  ///
  /// [commentViewData] is the updated comment data after editing.
  LMFeedEditCommentSuccessState({
    required this.commentViewData,
  });

  /// Updated comment data after editing.
  final LMCommentViewData commentViewData;

  @override
  List<Object?> get props => [commentViewData];
}

/// {@template lm_feed_edit_comment_error_state}
/// State representing an error that occurred during the editing of a comment.
/// Contains an error message and the old comment data.
/// {@endtemplate}
final class LMFeedEditCommentErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditCommentErrorState] with the provided [error]
  /// and [oldComment].
  ///
  /// [error] describes the error that occurred during comment editing.
  /// [oldComment] is the comment data that was being edited.
  LMFeedEditCommentErrorState({
    required this.error,
    required this.oldComment,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// The comment data that was being edited.
  final LMCommentViewData oldComment;

  @override
  List<Object?> get props => [error, oldComment];
}

/// {@template lm_feed_delete_comment_success_state}
/// State representing a successful deletion of a comment. Contains the
/// ID of the deleted comment.
/// {@endtemplate}
final class LMFeedDeleteCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedDeleteCommentSuccessState] with the provided
  /// [commentId].
  ///
  /// [commentId] is the ID of the comment that has been successfully deleted.
  LMFeedDeleteCommentSuccessState({
    required this.commentId,
  });

  /// ID of the comment that has been successfully deleted.
  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

/// {@template lm_feed_delete_comment_error_state}
/// State representing an error that occurred during the deletion of a comment.
/// Contains an error message, the old comment data, and the index of the
/// comment in the list.
/// {@endtemplate}
final class LMFeedDeleteCommentErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedDeleteCommentErrorState] with the provided [error],
  /// [oldComment], and [index].
  ///
  /// [error] describes the error that occurred during comment deletion.
  /// [oldComment] is the comment data that was being deleted.
  /// [index] is the index of the comment in the list.
  LMFeedDeleteCommentErrorState({
    required this.error,
    required this.oldComment,
    required this.index,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// The comment data that was being deleted.
  final LMCommentViewData oldComment;

  /// Index of the comment in the list.
  final int index;

  @override
  List<Object?> get props => [error, oldComment, index];
}

/// {@template lm_feed_replying_comment_state}
/// State representing the start of replying to a comment. Contains the
/// ID of the post, the parent comment, and the username of the person
/// replying.
/// {@endtemplate}
final class LMFeedReplyingCommentState extends LMFeedCommentState {
  /// Constructs a [LMFeedReplyingCommentState] with the provided [postId],
  /// [parentComment], and [userName].
  ///
  /// [postId] is the ID of the post to which the comment belongs.
  /// [parentComment] is the comment to which the reply is being made.
  /// [userName] is the name of the user who is replying.
  LMFeedReplyingCommentState({
    required this.postId,
    required this.parentComment,
    required this.userName,
  });

  /// ID of the post to which the comment belongs.
  final String postId;

  /// The comment to which the reply is being made.
  final LMCommentViewData parentComment;

  /// Name of the user who is replying.
  final String userName;

  @override
  List<Object?> get props => [postId, parentComment, userName];
}

/// {@template lm_feed_reply_cancel_state}
/// State representing the cancellation of a reply to a comment. This state
/// does not carry any additional data.
/// {@endtemplate}
final class LMFeedReplyCancelState extends LMFeedCommentState {}

/// {@template lm_feed_reply_comment_success_state}
/// State representing a successful reply to a comment. Contains the
/// newly added reply.
/// {@endtemplate}
final class LMFeedReplyCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedReplyCommentSuccessState] with the provided
  /// [reply].
  ///
  /// [reply] is the reply that has been successfully added.
  LMFeedReplyCommentSuccessState({
    required this.reply,
  });

  /// The reply that has been successfully added.
  final LMCommentViewData reply;

  @override
  List<Object?> get props => [reply];
}

/// {@template lm_feed_reply_comment_error_state}
/// State representing an error that occurred during the reply to a comment.
/// Contains an error message, the ID of the comment, and the ID of the reply.
/// {@endtemplate}
final class LMFeedReplyCommentErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedReplyCommentErrorState] with the provided [error],
  /// [commentId], and [replyId].
  ///
  /// [error] describes the error that occurred during the reply.
  /// [commentId] is the ID of the comment being replied to.
  /// [replyId] is the ID of the reply that failed to be added.
  LMFeedReplyCommentErrorState({
    required this.error,
    required this.commentId,
    required this.replyId,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// ID of the comment being replied to.
  final String commentId;

  /// ID of the reply that failed to be added.
  final String replyId;

  @override
  List<Object?> get props => [error, commentId, replyId];
}

/// {@template lm_feed_get_reply_comment_success_state}
/// State representing a successful fetch of replies to a comment. Contains
/// the list of replies, the current page, and the ID of the comment.
/// {@endtemplate}
final class LMFeedGetReplyCommentSuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedGetReplyCommentSuccessState] with the provided
  /// [replies], [page], and [commentId].
  ///
  /// [replies] is the list of replies that have been successfully retrieved.
  /// [page] is the current page number of replies.
  /// [commentId] is the ID of the comment for which replies have been fetched.
  LMFeedGetReplyCommentSuccessState({
    required this.replies,
    required this.page,
    required this.commentId,
  });

  /// List of replies that have been successfully loaded.
  final List<LMCommentViewData> replies;

  /// Current page number of the replies.
  final int page;

  /// ID of the comment for which replies have been fetched.
  final String commentId;

  @override
  List<Object?> get props => [replies, page, commentId];
}

/// {@template lm_feed_get_reply_comment_loading_state}
/// State representing the loading phase for replies to a comment. Contains
/// the ID of the comment whose replies are being fetched.
/// {@endtemplate}
final class LMFeedGetReplyCommentLoadingState extends LMFeedCommentState {
  /// Constructs a [LMFeedGetReplyCommentLoadingState] with the provided
  /// [commentId].
  ///
  /// [commentId] is the ID of the comment whose replies are being fetched.
  LMFeedGetReplyCommentLoadingState({
    required this.commentId,
  });

  /// ID of the comment whose replies are being fetched.
  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

/// {@template lm_feed_get_reply_comment_pagination_loading_state}
/// State representing the loading phase for paginated replies to a comment.
/// Contains the ID of the comment whose paginated replies are being fetched.
/// {@endtemplate}
final class LMFeedGetReplyCommentPaginationLoadingState
    extends LMFeedCommentState {
  /// Constructs a [LMFeedGetReplyCommentPaginationLoadingState] with the
  /// provided [commentId].
  ///
  /// [commentId] is the ID of the comment whose paginated replies are being
  /// fetched.
  LMFeedGetReplyCommentPaginationLoadingState({
    required this.commentId,
  });

  /// ID of the comment whose paginated replies are being fetched.
  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

/// {@template lm_feed_close_reply_state}
/// State representing the closure of replies for a comment. Contains the
/// ID of the comment whose replies are being closed.
/// {@endtemplate}
final class LMFeedCloseReplyState extends LMFeedCommentState {
  /// Constructs a [LMFeedCloseReplyState] with the provided [commentId].
  ///
  /// [commentId] is the ID of the comment whose replies are being closed.
  LMFeedCloseReplyState({
    required this.commentId,
  });

  /// ID of the comment whose replies are being closed.
  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

/// {@template lm_feed_editing_reply_state}
/// State representing the start of editing a reply to a comment. Contains
/// the ID of the post, the ID of the comment, the old reply data, and the
/// new reply text.
/// {@endtemplate}
final class LMFeedEditingReplyState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditingReplyState] with the provided [postId],
  /// [commentId], [oldReply], and [replyText].
  ///
  /// [postId] is the ID of the post to which the comment belongs.
  /// [commentId] is the ID of the comment to which the reply belongs.
  /// [oldReply] is the reply that is being edited.
  /// [replyText] is the new text of the reply.
  LMFeedEditingReplyState({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.replyText,
  });

  /// ID of the post to which the comment belongs.
  final String postId;

  /// ID of the comment to which the reply belongs.
  final String commentId;

  /// The reply that is being edited.
  final LMCommentViewData oldReply;

  /// New text of the reply.
  final String replyText;

  @override
  List<Object?> get props => [postId, commentId, oldReply, replyText];
}

/// {@template lm_feed_edit_reply_success_state}
/// State representing a successful edit of a reply to a comment. Contains
/// the ID of the comment, the ID of the reply, and the updated reply data.
/// {@endtemplate}
final class LMFeedEditReplySuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditReplySuccessState] with the provided [commentId],
  /// [replyId], and [reply].
  ///
  /// [commentId] is the ID of the comment to which the reply belongs.
  /// [replyId] is the ID of the reply that has been successfully edited.
  /// [reply] is the updated reply data.
  LMFeedEditReplySuccessState({
    required this.commentId,
    required this.replyId,
    required this.reply,
  });

  /// ID of the comment to which the reply belongs.
  final String commentId;

  /// ID of the reply that has been successfully edited.
  final String replyId;

  /// Updated reply data.
  final LMCommentViewData reply;

  @override
  List<Object?> get props => [commentId, replyId, reply];
}

/// {@template lm_feed_edit_reply_error_state}
/// State representing an error that occurred during the editing of a reply.
/// Contains an error message, the ID of the comment, and the old reply data.
/// {@endtemplate}
final class LMFeedEditReplyErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedEditReplyErrorState] with the provided [error],
  /// [commentId], and [oldReply].
  ///
  /// [error] describes the error that occurred during the reply editing.
  /// [commentId] is the ID of the comment to which the reply belongs.
  /// [oldReply] is the reply data that was being edited.
  LMFeedEditReplyErrorState({
    required this.error,
    required this.commentId,
    required this.oldReply,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// ID of the comment to which the reply belongs.
  final String commentId;

  /// The reply data that was being edited.
  final LMCommentViewData oldReply;

  @override
  List<Object?> get props => [error, commentId, oldReply];
}

/// {@template lm_feed_delete_reply_success_state}
/// State representing a successful deletion of a reply. Contains the ID
/// of the deleted reply and the ID of the comment to which it belongs.
/// {@endtemplate}
final class LMFeedDeleteReplySuccessState extends LMFeedCommentState {
  /// Constructs a [LMFeedDeleteReplySuccessState] with the provided
  /// [replyId] and [commentId].
  ///
  /// [replyId] is the ID of the reply that has been successfully deleted.
  /// [commentId] is the ID of the comment to which the deleted reply belonged.
  LMFeedDeleteReplySuccessState({
    required this.replyId,
    required this.commentId,
  });

  /// ID of the reply that has been successfully deleted.
  final String replyId;

  /// ID of the comment to which the deleted reply belonged.
  final String commentId;

  @override
  List<Object?> get props => [replyId, commentId];
}

/// {@template lm_feed_delete_reply_error_state}
/// State representing an error that occurred during the deletion of a reply.
/// Contains an error message and the old reply data.
/// {@endtemplate}
final class LMFeedDeleteReplyErrorState extends LMFeedCommentState {
  /// Constructs a [LMFeedDeleteReplyErrorState] with the provided [error]
  /// and [oldReply].
  ///
  /// [error] describes the error that occurred during the reply deletion.
  /// [oldReply] is the reply data that was being deleted.
  LMFeedDeleteReplyErrorState({
    required this.error,
    required this.oldReply,
  });

  /// Error message describing the reason for the failure.
  final String error;

  /// The reply data that was being deleted.
  final LMCommentViewData oldReply;

  @override
  List<Object?> get props => [error, oldReply];
}
