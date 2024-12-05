/// {@template lm_feed_post_detail_screen_setting}
/// Setting configuration for PostDetail Screen
/// {@endtemplate}
class LMFeedPostDetailScreenSetting {
  /// {@macro lm_feed_post_detail_screen_setting}
  const LMFeedPostDetailScreenSetting({
    this.showCommentCountOnList = true,
    this.commentTextFieldHint,
  });

  /// [bool] to show comment count on list
  final bool showCommentCountOnList;

  /// [String] hint for comment text field
  final String? commentTextFieldHint;
}
