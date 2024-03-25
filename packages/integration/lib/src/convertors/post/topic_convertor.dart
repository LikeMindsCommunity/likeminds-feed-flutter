import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMTopicViewDataConvertor {
  static LMTopicViewData fromTopic(Topic topic,
      {Map<String, LMWidgetViewData>? widgets}) {
    LMTopicViewDataBuilder topicBuilder = LMTopicViewDataBuilder();

    topicBuilder.name(topic.name);

    topicBuilder.id(topic.id);

    topicBuilder.isEnabled(topic.isEnabled);

    if (topic.level != null) {
      topicBuilder.level(topic.level!);
    }

    if (topic.parentId != null) {
      topicBuilder.parentId(topic.parentId!);
    }

    if (topic.parentName != null) {
      topicBuilder.parentName(topic.parentName!);
    }

    if (topic.priority != null) {
      topicBuilder.priority(topic.priority!);
    }

    if (topic.isSearchable != null) {
      topicBuilder.isSearchable(topic.isSearchable!);
    }

    if (topic.widgetId != null) {
      topicBuilder.widgetId(topic.widgetId!);
      if (widgets != null && widgets.containsKey(topic.widgetId)) {
        topicBuilder.widgetViewData(widgets[topic.widgetId]!);
      }
    }

    if (topic.numberOfPosts != null) {
      topicBuilder.numberOfPosts(topic.numberOfPosts!);
    }

    if (topic.totalChildCount != null) {
      topicBuilder.totalChildCount(topic.totalChildCount!);
    }

    return topicBuilder.build();
  }

  static Topic toTopic(LMTopicViewData topicViewData) {
    return Topic.fromEntity(
      TopicEntity(
        name: topicViewData.name,
        id: topicViewData.id,
        isEnabled: topicViewData.isEnabled,
        isSearchable: topicViewData.isSearchable,
        level: topicViewData.level,
        parentId: topicViewData.parentId,
        parentName: topicViewData.parentName,
        priority: topicViewData.priority,
        widgetId: topicViewData.widgetId,
        numberOfPosts: topicViewData.numberOfPosts,
        totalChildCount: topicViewData.totalChildCount,
      ),
    );
  }
}
