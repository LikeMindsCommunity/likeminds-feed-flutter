import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMNotificationFeedItemViewData {
  String id;
  int action;
  List<LMUserViewData> actionBy;
  String actionOn;
  LMActivityEntityViewData? activityEntityData;
  String activityText;
  String? cta;
  DateTime createdAt;
  String entityId;
  String? entityOwnerId;
  int entityType;
  bool isRead;
  DateTime updatedAt;

  LMNotificationFeedItemViewData._({
    required this.id,
    required this.action,
    required this.actionBy,
    required this.actionOn,
    this.activityEntityData,
    required this.activityText,
    this.cta,
    required this.createdAt,
    required this.entityId,
    this.entityOwnerId,
    required this.entityType,
    required this.isRead,
    required this.updatedAt,
  });
}

class LMNotificationFeedItemViewDataBuilder {
  String? _id;
  int? _action;
  List<LMUserViewData>? _actionBy;
  String? _actionOn;
  LMActivityEntityViewData? _activityEntityData;
  String? _activityText;
  String? _cta;
  DateTime? _createdAt;
  String? _entityId;
  String? _entityOwnerId;
  int? _entityType;
  bool? _isRead;
  DateTime? _updatedAt;

  void id(String id) {
    _id = id;
  }

  void action(int action) {
    _action = action;
  }

  void actionBy(List<LMUserViewData> actionBy) {
    _actionBy = actionBy;
  }

  void actionOn(String actionOn) {
    _actionOn = actionOn;
  }

  void activityEntityViewData(LMActivityEntityViewData activityEntityData) {
    _activityEntityData = activityEntityData;
  }

  void activityText(String activityText) {
    _activityText = activityText;
  }

  void cta(String cta) {
    _cta = cta;
  }

  void createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  void entityId(String entityId) {
    _entityId = entityId;
  }

  void entityOwnerId(String entityOwnerId) {
    _entityOwnerId = entityOwnerId;
  }

  void entityType(int entityType) {
    _entityType = entityType;
  }

  void isRead(bool isRead) {
    _isRead = isRead;
  }

  void updatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
  }

  LMNotificationFeedItemViewData build() {
    return LMNotificationFeedItemViewData._(
      id: _id!,
      action: _action!,
      actionBy: _actionBy!,
      actionOn: _actionOn!,
      activityEntityData: _activityEntityData,
      activityText: _activityText!,
      cta: _cta,
      createdAt: _createdAt!,
      entityId: _entityId!,
      entityOwnerId: _entityOwnerId,
      entityType: _entityType!,
      isRead: _isRead!,
      updatedAt: _updatedAt!,
    );
  }
}
