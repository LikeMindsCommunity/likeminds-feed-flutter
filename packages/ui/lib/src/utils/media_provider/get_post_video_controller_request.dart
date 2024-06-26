part of 'media_provider.dart';

enum LMFeedVideoSourceType { network, path, bytes }

class LMFeedGetPostVideoControllerRequest {
  final String postId;
  final String? videoSource;
  final Uint8List? videoBytes;
  final int position;
  final LMFeedVideoSourceType videoType;
  final bool autoPlay;

  LMFeedGetPostVideoControllerRequest._({
    required this.postId,
    this.videoSource,
    this.videoBytes,
    required this.videoType,
    this.position = 0,
    this.autoPlay = false,
  });
}

class LMFeedGetPostVideoControllerRequestBuilder {
  String? _postId;
  String? _videoSource;
  LMFeedVideoSourceType? _videoType;
  bool _autoPlay = false;
  int _position = 0;
  Uint8List? _videoBytes;

  void position(int position) {
    _position = position;
  }

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

  void videoBytes(Uint8List videoBytes) {
    _videoBytes = videoBytes;
  }

  LMFeedGetPostVideoControllerRequest build() {
    return LMFeedGetPostVideoControllerRequest._(
      postId: _postId!,
      videoSource: _videoSource,
      videoBytes: _videoBytes,
      videoType: _videoType!,
      autoPlay: _autoPlay,
      position: _position,
    );
  }
}
