import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

enum LMPostSource {
  feed,
  postDetail,
}

class LMPostMetaData {
  final LMPostViewData postViewData;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData>? widgets;
  final Map<String, LMTopicViewData> topics;
  final LMPostSource source;

  const LMPostMetaData._({
    required this.postViewData,
    required this.users,
    this.widgets,
    required this.topics,
    this.source = LMPostSource.feed,
  });
}

class LMPostMetaDataBuilder {
  LMPostViewData? _postViewData;
  Map<String, LMUserViewData>? _users;
  Map<String, LMWidgetViewData>? _widgets;
  Map<String, LMTopicViewData>? _topics;
  LMPostSource? _source;

  void postViewData(LMPostViewData postViewData) {
    _postViewData = postViewData;
  }

  void users(Map<String, LMUserViewData> users) {
    _users = users;
  }

  void widgets(Map<String, LMWidgetViewData> widgets) {
    _widgets = widgets;
  }

  void topics(Map<String, LMTopicViewData> topics) {
    _topics = topics;
  }

  void source(LMPostSource? source) {
    _source = source;
  }

  LMPostMetaData build() {
    return LMPostMetaData._(
      postViewData: _postViewData!,
      users: _users!,
      widgets: _widgets,
      topics: _topics!,
      source: _source ?? LMPostSource.feed,
    );
  }
}
