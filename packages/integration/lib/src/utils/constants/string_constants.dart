class LMFeedStringConstants {
  LMFeedStringConstants._();
  static final LMFeedStringConstants instance = LMFeedStringConstants._();

  String kStringLike = "Like";
  String kStringLikes = "Likes";
  String kStringAddComment = "Add Comment";
  String kRegexLinksAndTags =
      r'((?:http|https|ftp|www)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(?::[a-zA-Z0-9]*)?\/?[^\s\n]+|@([^<>~]+)~|<<([^<>]+)\|route://member/([a-zA-Z-0-9]+)>>';
  String apiKey = "apiKey";
  String uuid = "uuid";
  String userName = "userName";
  String authToken = "authToken";
  String accessToken = "accessToken";
  String refreshToken = 'refreshToken';

  static const String underReviewKey = 'under_review';
  static const String rejectedKey = 'rejected';
  static const String postApprovalNeeded = 'post_approval_needed';
}
