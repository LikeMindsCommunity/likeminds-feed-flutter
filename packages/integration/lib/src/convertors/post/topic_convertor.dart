import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicViewDataConvertor {
  static TopicViewData fromTopic(Topic topic) {
    TopicViewDataBuilder topicBuilder = TopicViewDataBuilder();

    topicBuilder.name(topic.name);

    topicBuilder.id(topic.id);

    topicBuilder.isEnabled(topic.isEnabled);

    return topicBuilder.build();
  }

  static Topic toTopic(TopicViewData topicViewData) {
    return Topic.fromEntity(
      TopicEntity(
          name: topicViewData.name,
          id: topicViewData.id,
          isEnabled: topicViewData.isEnabled),
    );
  }
}
