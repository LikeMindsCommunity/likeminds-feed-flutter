class LMWidgetViewData {
  final String id;
  Map<String, dynamic>? lmMeta;
  int createdAt;
  Map<String, dynamic> metadata;
  String parentEntityId;
  String parentEntityType;
  int updatedAt;

  LMWidgetViewData._({
    required this.id,
    this.lmMeta,
    required this.createdAt,
    required this.metadata,
    required this.parentEntityId,
    required this.parentEntityType,
    required this.updatedAt,
  });
}

class LMWidgetViewDataBuilder {
  String? _id;
  Map<String, dynamic>? _lmMeta;
  int? _createdAt;
  Map<String, dynamic>? _metadata;
  String? _parentEntityId;
  String? _parentEntityType;
  int? _updatedAt;

  void id(String id) {
    _id = id;
  }

  void lmMeta(Map<String, dynamic> lmMeta) {
    _lmMeta = lmMeta;
  }

  void createdAt(int createdAt) {
    _createdAt = createdAt;
  }

  void metadata(Map<String, dynamic> metadata) {
    _metadata = metadata;
  }

  void parentEntityId(String parentEntityId) {
    _parentEntityId = parentEntityId;
  }

  void parentEntityType(String parentEntityType) {
    _parentEntityType = parentEntityType;
  }

  void updatedAt(int updatedAt) {
    _updatedAt = updatedAt;
  }

  LMWidgetViewData build() {
    return LMWidgetViewData._(
      id: _id!,
      lmMeta: _lmMeta,
      createdAt: _createdAt!,
      metadata: _metadata!,
      parentEntityId: _parentEntityId!,
      parentEntityType: _parentEntityType!,
      updatedAt: _updatedAt!,
    );
  }
}
