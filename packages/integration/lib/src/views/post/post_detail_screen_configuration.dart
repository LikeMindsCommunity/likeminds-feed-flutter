part of 'post_detail_screen.dart';

class LMPostDetailScreenConfig {
  const LMPostDetailScreenConfig({
    this.showCommentCountOnList = true,
  });

  /// [bool] to show comment count on list
  final bool showCommentCountOnList;

  LMPostDetailScreenConfig copyWith({
    bool? showCommentCountOnList,
  }) {
    return LMPostDetailScreenConfig(
      showCommentCountOnList:
          showCommentCountOnList ?? this.showCommentCountOnList,
    );
  }
}
