String getPostLikesText(int likesCount) {
  if (likesCount == 1) {
    return "1 Like";
  } else {
    return "$likesCount Likes";
  }
}

String getPostCommentButtonText(int commentCount) {
  if (commentCount == 0) {
    return "Add Comment";
  } else if (commentCount == 1) {
    return "1 Comment";
  } else {
    return "$commentCount Comments";
  }
}
