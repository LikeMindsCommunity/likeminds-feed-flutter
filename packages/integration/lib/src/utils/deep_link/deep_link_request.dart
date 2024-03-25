part of 'deep_link_handler.dart';

class LMFeedDeepLinkRequest {
  LMFeedDeepLinkPath path;
  Map<String, dynamic>? data;
  String uuid;
  String userName;

  LMFeedDeepLinkRequest._({
    required this.path,
    this.data,
    required this.uuid,
    required this.userName,
  });
}

class LMFeedDeepLinkRequestBuilder {
  LMFeedDeepLinkPath? _path;
  Map<String, dynamic>? _data;
  String? _uuid;
  String? _userName;

  void path(LMFeedDeepLinkPath path) => _path = path;
  void data(Map<String, dynamic> data) => _data = data;
  void uuid(String uuid) => _uuid = uuid;
  void userName(String userName) => _userName = userName;

  LMFeedDeepLinkRequest build() {
    return LMFeedDeepLinkRequest._(
      path: _path!,
      data: _data,
      uuid: _uuid!,
      userName: _userName!,
    );
  }
}
