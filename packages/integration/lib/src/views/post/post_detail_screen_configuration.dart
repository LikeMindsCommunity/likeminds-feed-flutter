part of 'post_detail_screen.dart';

class LMPostDetailScreenConfig {
  const LMPostDetailScreenConfig({
    this.showCommentCountOnList = true,
    this.commentTextFieldHint,
  });

  /// [bool] to show comment count on list
  final bool showCommentCountOnList;

  /// [String] hint for comment text field
  final String? commentTextFieldHint;

  LMPostDetailScreenConfig copyWith({
    bool? showCommentCountOnList,
    String? commentTextFieldHint,
  }) {
    return LMPostDetailScreenConfig(
      showCommentCountOnList:
          showCommentCountOnList ?? this.showCommentCountOnList,
      commentTextFieldHint: commentTextFieldHint ?? this.commentTextFieldHint,
    );
  }
}
