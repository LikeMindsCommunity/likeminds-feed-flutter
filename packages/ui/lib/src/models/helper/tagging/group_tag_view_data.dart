class LMGroupTagViewData {
  String? description;
  String? imageUrl;
  String? name;
  String? route;
  String? tag;

  LMGroupTagViewData._({
    this.description,
    this.imageUrl,
    this.name,
    this.route,
    this.tag,
  });
}

class LMGroupTagViewDataBuilder {
  String? _description;
  String? _imageUrl;
  String? _name;
  String? _route;
  String? _tag;

  void description(String description) {
    _description = description;
  }

  void imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }

  void name(String name) {
    _name = name;
  }

  void route(String route) {
    _route = route;
  }

  void tag(String tag) {
    _tag = tag;
  }

  LMGroupTagViewData build() {
    return LMGroupTagViewData._(
      description: _description,
      imageUrl: _imageUrl,
      name: _name,
      route: _route,
      tag: _tag,
    );
  }
}
