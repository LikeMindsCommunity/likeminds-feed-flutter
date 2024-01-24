class LMTopicViewData {
  String name;
  final String id;
  bool isEnabled;

  LMTopicViewData._(
      {required this.name, required this.id, required this.isEnabled});
}

class LMTopicViewDataBuilder {
  String? _name;
  String? _id;
  bool? _isEnabled;

  void name(String name) {
    _name = name;
  }

  void id(String id) {
    _id = id;
  }

  void isEnabled(bool isEnabled) {
    _isEnabled = isEnabled;
  }

  LMTopicViewData build() {
    if (_name == null || _id == null || _isEnabled == null) {
      throw Exception(
          "LMTopicViewDataBuilder: name, id and isEnabled must be set");
    }
    return LMTopicViewData._(name: _name!, id: _id!, isEnabled: _isEnabled!);
  }
}
