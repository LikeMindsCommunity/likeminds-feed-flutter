import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMPollOptionViewDataConvertor {
  static LMPollOptionViewData fromPollOption({
    required Map<String, dynamic> option,
    required Map<String, LMUserViewData> users,
  }) {
    String? id = option['_id'] as String?;
    String? text = option['text'] as String?;
    int? voteCount = option['vote_count'] as int?;
    num? percentage = option['percentage'] as num?;
    bool? isSelected = option['is_selected'] as bool?;
    String? userId = option['uuid'] as String?;

    LMPostOptionViewDataBuilder pollOptionViewDataBuilder =
        LMPostOptionViewDataBuilder();
    if (id != null) {
      pollOptionViewDataBuilder.id(id);
    }
    if (text != null) {
      pollOptionViewDataBuilder.text(text);
    }
    if (voteCount != null) {
      pollOptionViewDataBuilder.votes(voteCount);
    }
    if (percentage != null) {
      pollOptionViewDataBuilder.percentage(percentage.toDouble());
    }
    if (isSelected != null) {
      pollOptionViewDataBuilder.isSelected(isSelected);
    }
    if (userId != null && users[userId] != null) {
      pollOptionViewDataBuilder.userViewData(users[userId]!);
    }
    return pollOptionViewDataBuilder.build();
  }
}
