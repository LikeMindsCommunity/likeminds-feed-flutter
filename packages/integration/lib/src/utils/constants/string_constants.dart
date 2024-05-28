class LMFeedStringConstants {
  static const String kStringLike = "Like";
  static const String kStringLikes = "Likes";
  static const String kStringAddComment = "Add Comment";
  static const String kRegexLinksAndTags =
      r'((?:http|https|ftp|www)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(?::[a-zA-Z0-9]*)?\/?[^\s\n]+|@([^<>~]+)~|<<([^<>]+)\|route://member/([a-zA-Z-0-9]+)>>';
  static const String apiKey = "apiKey";
  static const String uuid = "uuid";
  static const String userName = "userName";
  static const String authToken = "authToken";
  static const String accessToken = "accessToken";
  static const String refreshToken = 'refreshToken';

  static const String underReviewKey = 'under_review';
  static const String rejectedKey = 'rejected';
  static const String postApprovalNeeded = 'post_approval_needed';
}
