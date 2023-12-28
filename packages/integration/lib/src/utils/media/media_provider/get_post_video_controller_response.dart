part of 'media_provider.dart';

class LMGetPostVideoControllerResponse {
  final String postId;
  final VideoPlayerController videoPlayerController;

  const LMGetPostVideoControllerResponse._(
      {required this.postId, required this.videoPlayerController});
}
