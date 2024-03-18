import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMTopicViewData {
  String name;
  String id;
  bool isEnabled;
  double? priority;
  String? parentId;
  String? parentName;
  int? level;
  bool? isSearchable;
  String? widgetId;
  int? numberOfPosts;
  int? totalChildCount;
  LMWidgetViewData? widgetViewData;

  LMTopicViewData._({
    required this.name,
    required this.id,
    required this.isEnabled,
    this.priority,
    this.parentId,
    this.parentName,
    this.level,
    this.isSearchable,
    this.widgetId,
    this.numberOfPosts,
    this.totalChildCount,
    this.widgetViewData,
  });
}

class LMTopicViewDataBuilder {
  String? _name;
  String? _id;
  bool? _isEnabled;
  double? _priority;
  String? _parentId;
  String? _parentName;
  int? _level;
  bool? _isSearchable;
  String? _widgetId;
  int? _numberOfPosts;
  int? _totalChildCount;
  LMWidgetViewData? _widgetViewData;

  void name(String name) {
    _name = name;
  }

  void id(String id) {
    _id = id;
  }

  void isEnabled(bool isEnabled) {
    _isEnabled = isEnabled;
  }

  void priority(double priority) {
    _priority = priority;
  }

  void parentId(String parentId) {
    _parentId = parentId;
  }

  void parentName(String parentName) {
    _parentName = parentName;
  }

  void level(int level) {
    _level = level;
  }

  void isSearchable(bool isSearchable) {
    _isSearchable = isSearchable;
  }

  void widgetId(String widgetId) {
    _widgetId = widgetId;
  }

  void numberOfPosts(int numberOfPosts) {
    _numberOfPosts = numberOfPosts;
  }

  void totalChildCount(int totalChildCount) {
    _totalChildCount = totalChildCount;
  }

  void widgetViewData(LMWidgetViewData widgetViewData) {
    _widgetViewData = widgetViewData;
  }

  LMTopicViewData build() {
    if (_name == null || _id == null || _isEnabled == null) {
      throw Exception(
          "LMTopicViewDataBuilder: name, id and isEnabled must be set");
    }
    return LMTopicViewData._(
      name: _name!,
      id: _id!,
      isEnabled: _isEnabled!,
      priority: _priority,
      parentId: _parentId,
      parentName: _parentName,
      level: _level,
      isSearchable: _isSearchable,
      widgetId: _widgetId,
      numberOfPosts: _numberOfPosts,
      totalChildCount: _totalChildCount,
      widgetViewData: _widgetViewData,
    );
  }
}
