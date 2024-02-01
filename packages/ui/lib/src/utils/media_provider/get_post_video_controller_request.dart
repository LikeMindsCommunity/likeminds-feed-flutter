part of 'media_provider.dart';

enum LMFeedVideoSourceType { network, file }

class LMFeedGetPostVideoControllerRequest {
  final String postId;
  final String videoSource;
  final LMFeedVideoSourceType videoType;
  final bool autoPlay;
  final bool isMuted;

  const LMFeedGetPostVideoControllerRequest._({
    required this.postId,
    required this.videoSource,
    required this.videoType,
    this.autoPlay = false,
    this.isMuted = true,
  });
}

class LMFeedGetPostVideoControllerRequestBuilder {
  String? _postId;
  String? _videoSource;
  LMFeedVideoSourceType? _videoType;
  bool _autoPlay = false;
  bool _isMuted = true;

  void postId(String postId) {
    _postId = postId;
  }

  void videoSource(String videoSource) {
    _videoSource = videoSource;
  }

  void videoType(LMFeedVideoSourceType videoType) {
    _videoType = videoType;
  }

  void autoPlay(bool autoPlay) {
    _autoPlay = autoPlay;
  }

  void isMuted(bool isMuted) {
    _isMuted = isMuted;
  }

  LMFeedGetPostVideoControllerRequest build() {
    return LMFeedGetPostVideoControllerRequest._(
      postId: _postId!,
      videoSource: _videoSource!,
      videoType: _videoType!,
      autoPlay: _autoPlay,
      isMuted: _isMuted,
    );
  }
}
