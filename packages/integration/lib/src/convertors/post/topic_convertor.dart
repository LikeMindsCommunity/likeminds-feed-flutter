import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicViewDataConvertor {
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
