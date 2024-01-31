part of 'media_provider.dart';

enum LMFeedVideoSourceType { network, file }

class LMFeedGetPostVideoControllerRequest {
  final String postId;
  final String videoSource;
  final LMFeedVideoSourceType videoType;

  const LMFeedGetPostVideoControllerRequest._({
    required this.postId,
    required this.videoSource,
    required this.videoType,
  });
}

class LMFeedGetPostVideoControllerRequestBuilder {
  String? _postId;
  String? _videoSource;
  LMFeedVideoSourceType? _videoType;

  void postId(String postId) {
    _postId = postId;
  }

  void videoSource(String videoSource) {
    _videoSource = videoSource;
  }

  void videoType(LMFeedVideoSourceType videoType) {
    _videoType = videoType;
  }

  LMFeedGetPostVideoControllerRequest build() {
    return LMFeedGetPostVideoControllerRequest._(
      postId: _postId!,
      videoSource: _videoSource!,
      videoType: _videoType!,
    );
  }
}
