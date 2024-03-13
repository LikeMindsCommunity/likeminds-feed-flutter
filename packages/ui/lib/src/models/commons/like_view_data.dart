class LMLikeViewData {
  String id;
  int createdAt;
  int updatedAt;
  String uuid;

  LMLikeViewData._({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.uuid,
  });
}

class LMLikeViewDataBuilder {
  String? _id;
  int? _createdAt;
  int? _updatedAt;
  String? _uuid;

  void id(String id) {
    _id = id;
  }

  void createdAt(int createdAt) {
    _createdAt = createdAt;
  }

  void updatedAt(int updatedAt) {
    _updatedAt = updatedAt;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  LMLikeViewData build() {
    return LMLikeViewData._(
      id: _id!,
      createdAt: _createdAt!,
      updatedAt: _updatedAt!,
      uuid: _uuid!,
    );
  }
}
