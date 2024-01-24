class LMPopUpMenuItemViewData {
  final String title;
  final int id;

  LMPopUpMenuItemViewData._({
    required this.title,
    required this.id,
  });
}

class LMPopUpMenuItemViewDataBuilder {
  String? _title;
  int? _id;

  void title(String title) {
    _title = title;
  }

  void id(int id) {
    _id = id;
  }

  LMPopUpMenuItemViewData build() {
    return LMPopUpMenuItemViewData._(
      title: _title!,
      id: _id!,
    );
  }
}
