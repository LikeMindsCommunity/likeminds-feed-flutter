import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicConvertor {
  static LMTopicViewData fromTopic(Topic topic) {
    LMTopicViewDataBuilder topicViewDataBuilder = LMTopicViewDataBuilder();

    topicViewDataBuilder.name(topic.name);

    topicViewDataBuilder.id(topic.id);

    topicViewDataBuilder.isEnabled(topic.isEnabled);

    return topicViewDataBuilder.build();
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
