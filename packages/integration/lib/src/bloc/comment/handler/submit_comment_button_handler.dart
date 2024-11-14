part of '../comment_bloc.dart';

void _handleSubmitCommentButtonAction(LMFeedSubmitCommentEvent event, emit) {
  // check if the user is a guest user
  if (LMFeedUserUtils.isGuestUser()) {
    event.commentController.clear();
    LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
    return;
  }
  final commentBloc = LMFeedCommentBloc.instance;
  final userTags = commentBloc.userTags;
  bool isEditing = commentBloc.state is LMFeedEditingCommentState;
  bool isReply = commentBloc.state is LMFeedReplyingCommentState;
  bool isReplyEditing = commentBloc.state is LMFeedEditingReplyState;
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  closeOnScreenKeyboard(event.focusNode);
  // extract text from comment controller
  String commentText = LMFeedTaggingHelper.encodeString(
    event.commentController.text,
    userTags,
  ).trim();
  commentText = commentText.trim();
  if (commentText.isEmpty) {
    LMFeedCore.showSnackBar(
      event.context,
      event.emptyTextErrorMessage ??
          "Please write something to create a $commentTitleSmallCapSingular",
      event.widgetSource,
    );

    return;
  }

  if (isEditing) {
    // edit an existing comment
    final currentState = commentBloc.state as LMFeedEditingCommentState;
    commentBloc.add(LMFeedEditCommentEvent(
      event.postId,
      currentState.oldComment,
      commentText,
    ));
  } else if (isReply) {
    // create new reply
    final currentState = commentBloc.state as LMFeedReplyingCommentState;
    commentBloc.add(LMFeedReplyCommentEvent(
      postId: event.postId,
      parentComment: currentState.parentComment,
      replyText: commentText,
    ));
  } else if (isReplyEditing) {
    // edit an existing reply
    final currentState = commentBloc.state as LMFeedEditingReplyState;
    commentBloc.add(LMFeedEditReplyEvent(
      postId: currentState.postId,
      commentId: currentState.commentId,
      oldReply: currentState.oldReply,
      editText: commentText,
    ));
  } else {
    // create new comment
    commentBloc.add(LMFeedAddCommentEvent(
      postId: event.postId,
      commentText: commentText,
    ));
  }

  event.commentController.clear();
}

void closeOnScreenKeyboard(FocusNode focusNode) {
  if (focusNode.hasFocus) {
    focusNode.unfocus();
  }
}
