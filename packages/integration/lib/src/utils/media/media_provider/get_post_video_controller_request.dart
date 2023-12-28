part of 'media_provider.dart';

enum LMVideoSourceType { network, file }

class LMGetPostVideoControllerRequest {
  final String postId;
  final String videoSource;
  final LMVideoSourceType videoType;

  const LMGetPostVideoControllerRequest._(
      {required this.postId,
      required this.videoSource,
      required this.videoType});
}
