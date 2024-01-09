part of 'media_provider.dart';

class LMFeedGetPostVideoControllerResponse {
  final String postId;
  final VideoPlayerController videoPlayerController;

  const LMFeedGetPostVideoControllerResponse._(
      {required this.postId, required this.videoPlayerController});
}
