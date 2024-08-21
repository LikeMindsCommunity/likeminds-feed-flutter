part of 'comment_bloc.dart';

/// {@template lm_feed_comment_event}
/// Comment event for the feed responsible for handling all the comment related
/// actions like fetching comments, adding comments, editing comments, deleting
/// comments, replying to comments, editing replies, deleting replies, etc.
/// {@endtemplate}
@immutable
sealed class LMFeedCommentEvent extends Equatable {
  /// {@macro lm_feed_comment_event}
  const LMFeedCommentEvent();

  @override
  List<Object> get props => [];
}

/// {@template lm_feed_comment_refresh_event}
/// Event to refresh the comments in the feed.
/// {@endtemplate}
final class LMFeedCommentRefreshEvent extends LMFeedCommentEvent {}

/// {@template lm_feed_get_comments_event}
/// Event to get the comments for a post.
/// [postId] is the id of the post for which the comments are to be fetched.
/// [page] is the page number of the comments to be fetched.
/// [pageSize] is the number of comments to be fetched in a single
/// {@endtemplate}
final class LMFeedGetCommentsEvent extends LMFeedCommentEvent {
  final String postId;
  final int page;
  final int pageSize;

  /// {@macro lm_feed_get_comments_event}
  LMFeedGetCommentsEvent({
    required this.postId,
    required this.page,
    required this.pageSize,
  });
  @override
  List<Object> get props => [postId, page, pageSize];
}

/// {@template lm_feed_add_comment_event}
/// Event to add a comment to a post.
/// [postId] is the id of the post to which the comment is to be added.
/// [commentText] is the text of the comment to be added.
/// {@endtemplate}
final class LMFeedAddCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final String commentText;

  /// {@macro lm_feed_add_comment_event}
  LMFeedAddCommentEvent({
    required this.postId,
    required this.commentText,
  });
  @override
  List<Object> get props => [postId, commentText];
}

/// {@template lm_feed_editing_comment_event}
/// Event to start editing a comment.
/// [postId] is the id of the post to which the comment belongs.
/// [oldComment] is the comment to be edited.
/// {@endtemplate}
final class LMFeedEditingCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;

  /// {@macro lm_feed_editing_comment_event}
  LMFeedEditingCommentEvent({
    required this.postId,
    required this.oldComment,
  });

  @override
  List<Object> get props => [postId, oldComment];
}

/// {@template lm_feed_edit_comment_event}
/// Event to edit a comment. It will do an API call to edit the comment.
/// [postId] is the id of the post to which the comment belongs.
/// [oldComment] is the comment to be edited.
/// [editedText] is the edited text of the comment.
/// {@endtemplate}
final class LMFeedEditCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;
  final String editedText;

  /// {@macro lm_feed_edit_comment_event}
  LMFeedEditCommentEvent(this.postId, this.oldComment, this.editedText);
  @override
  List<Object> get props => [postId, oldComment, editedText];
}

/// {@template lm_feed_edit_comment_cancel_event}
/// Event to cancel the editing of a comment.
/// {@endtemplate}
final class LMFeedEditCommentCancelEvent extends LMFeedCommentEvent {}

/// {@template lm_feed_delete_comment_event}
/// Event to delete a comment. It will do an API call to delete the comment.
/// [postId] is the id of the post to which the comment belongs.
/// [oldComment] is the comment to be deleted.
/// [reason] is the reason for deleting the comment.
/// [index] is the index of the comment in the list of comments.
/// {@endtemplate}
final class LMFeedDeleteCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;
  final String reason;
  final int index;

  /// {@macro lm_feed_delete_comment_event}
  LMFeedDeleteCommentEvent({
    required this.postId,
    required this.oldComment,
    required this.reason,
    required this.index,
  });

  @override
  List<Object> get props => [postId, oldComment, reason, index];
}

/// {@template lm_feed_replying_comment_event}
/// Event to start replying to a comment.
/// [postId] is the id of the post to which the comment belongs.
/// [parentComment] is the comment to which the reply is to be made.
/// [userName] is the name of the user to whom the reply is to be made.
/// {@endtemplate}

final class LMFeedReplyingCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData parentComment;
  final String userName;

  LMFeedReplyingCommentEvent({
    required this.postId,
    required this.parentComment,
    required this.userName,
  });

  @override
  List<Object> get props => [postId, parentComment, userName];
}

/// {@template lm_feed_reply_comment_event}
/// Event to reply to a comment. It will do an API call to reply to the comment.
/// [postId] is the id of the post to which the comment belongs.
/// [parentComment] is the comment to which the reply is to be made.
/// [replyText] is the text of the reply.
/// {@endtemplate}
final class LMFeedReplyCommentEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData parentComment;
  final String replyText;

  /// {@macro lm_feed_reply_comment_event}
  LMFeedReplyCommentEvent({
    required this.postId,
    required this.parentComment,
    required this.replyText,
  });
}

/// {@template lm_feed_reply_cancel_event}
/// Event to cancel the reply to a comment.
/// {@endtemplate}
final class LMFeedReplyCancelEvent extends LMFeedCommentEvent {}

/// {@template lm_feed_get_reply_event}
/// Event to get the replies for a comment.
/// [postId] is the id of the post to which the comment belongs.
/// [commentId] is the id of the comment for which the replies are to be fetched.
/// [page] is the page number of the replies to be fetched.
/// [pageSize] is the number of replies to be fetched in a single page.
/// {@endtemplate}
final class LMFeedGetReplyEvent extends LMFeedCommentEvent {
  final String postId;
  final String commentId;
  final int page;
  final int pageSize;

  /// {@macro lm_feed_get_reply_event}
  LMFeedGetReplyEvent({
    required this.postId,
    required this.commentId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [postId, commentId, page, pageSize];
}

/// {@template lm_feed_close_reply_event}
/// Event to close the replies for a comment.
/// [commentId] is the id of the comment for which the replies are to be closed.
/// {@endtemplate}
final class LMFeedCloseReplyEvent extends LMFeedCommentEvent {
  final String commentId;

  /// {@macro lm_feed_close_reply_event}
  LMFeedCloseReplyEvent({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}

/// {@template lm_feed_editing_reply_event}
/// Event to start editing a reply.
/// [postId] is the id of the post to which the comment belongs.
/// [commentId] is the id of the comment to which the reply belongs.
/// [oldReply] is the reply to be edited.
/// [replyText] is the text of the reply to be edited.
/// {@endtemplate}
final class LMFeedEditingReplyEvent extends LMFeedCommentEvent {
  final String postId;
  final String commentId;
  final LMCommentViewData oldReply;
  final String replyText;

  /// {@macro lm_feed_editing_reply_event}
  LMFeedEditingReplyEvent({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.replyText,
  });

  @override
  List<Object> get props => [postId, commentId, oldReply, replyText];
}

/// {@template lm_feed_edit_reply_event}
/// Event to edit a reply. It will do an API call to edit the reply.
/// [postId] is the id of the post to which the comment belongs.
/// [commentId] is the id of the comment to which the reply belongs.
/// [oldReply] is the reply to be edited.
/// [editText] is the edited text of the reply.
/// {@endtemplate}
final class LMFeedEditReplyEvent extends LMFeedCommentEvent {
  final String postId;
  final String commentId;
  final LMCommentViewData oldReply;
  final String editText;

  LMFeedEditReplyEvent({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.editText,
  });

  @override
  List<Object> get props => [postId, commentId, oldReply, editText];
}

/// {@template lm_feed_edit_reply_cancel_event}
/// Event to cancel the editing of a reply.
/// {@endtemplate}
final class LMFeedEditReplyCancelEvent extends LMFeedCommentEvent {}

/// {@template lm_delete_reply_event}
/// Event to delete a reply. It will do an API call to delete the reply.
/// [postId] is the id of the post to which the comment belongs.
/// [oldReply] is the reply to be deleted.
/// [reason] is the reason for deleting the reply.
/// [commentId] is the id of the comment to which the reply belongs.
/// {@endtemplate}
final class LMDeleteReplyEvent extends LMFeedCommentEvent {
  final String postId;
  final LMCommentViewData oldReply;
  final String reason;
  final String commentId;

  LMDeleteReplyEvent({
    required this.postId,
    required this.oldReply,
    required this.reason,
    required this.commentId,
  });

  @override
  List<Object> get props => [postId, oldReply, reason, commentId];
}
