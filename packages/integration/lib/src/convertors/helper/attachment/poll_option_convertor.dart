import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMPollOptionViewDataConvertor {
  static LMPostOptionViewData fromPollOption({
    required Map<String,dynamic> option,
    required Map<String, LMUserViewData> users,
  }) {
    String? id = option['id'] as String?;
    String? text = option['text'] as String?;
    int? voteCount = option['vote_count'] as int?;
    int? percentage = option['percentage'] as int?;
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
      pollOptionViewDataBuilder.percentage(double.parse(percentage.toString()));
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
