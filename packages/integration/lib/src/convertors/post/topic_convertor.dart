import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMTopicViewDataConvertor {
  static LMTopicViewData fromTopic(Topic topic) {
    LMTopicViewDataBuilder topicBuilder = LMTopicViewDataBuilder();

    topicBuilder.name(topic.name);

    topicBuilder.id(topic.id);

    topicBuilder.isEnabled(topic.isEnabled);

    return topicBuilder.build();
  }

  static Topic toTopic(LMTopicViewData topicViewData) {
    return Topic.fromEntity(
      TopicEntity(
          name: topicViewData.name,
          id: topicViewData.id,
          isEnabled: topicViewData.isEnabled),
    );
  }
}
