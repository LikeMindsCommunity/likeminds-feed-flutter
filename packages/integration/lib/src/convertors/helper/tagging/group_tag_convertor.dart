import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMGroupTagViewDataConvertor {
  static LMGroupTagViewData fromGroupTag(GroupTag groupTag) {
    LMGroupTagViewDataBuilder groupTagViewDataBuilder =
        LMGroupTagViewDataBuilder();

    if (groupTag.description != null) {
      groupTagViewDataBuilder.description(groupTag.description!);
    }

    if (groupTag.imageUrl != null) {
      groupTagViewDataBuilder.imageUrl(groupTag.imageUrl!);
    }

    if (groupTag.name != null) {
      groupTagViewDataBuilder.name(groupTag.name!);
    }

    if (groupTag.route != null) {
      groupTagViewDataBuilder.route(groupTag.route!);
    }

    if (groupTag.tag != null) {
      groupTagViewDataBuilder.tag(groupTag.tag!);
    }

    return groupTagViewDataBuilder.build();
  }

  static GroupTag toGroupTag(LMGroupTagViewData groupTagViewData) {
    return GroupTag(
      description: groupTagViewData.description,
      imageUrl: groupTagViewData.imageUrl,
      name: groupTagViewData.name,
      route: groupTagViewData.route,
      tag: groupTagViewData.tag,
    );
  }
}
