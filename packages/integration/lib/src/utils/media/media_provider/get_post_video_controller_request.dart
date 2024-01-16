part of 'media_provider.dart';

enum LMFeedVideoSourceType { network, file }

class LMFeedGetPostVideoControllerRequest {
  final String postId;
  final String videoSource;
  final LMFeedVideoSourceType videoType;

  const LMFeedGetPostVideoControllerRequest._(
      {required this.postId,
      required this.videoSource,
      required this.videoType});
}
