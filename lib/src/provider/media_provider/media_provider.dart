import 'dart:io';

import 'package:video_player/video_player.dart';

part 'get_post_video_controller_response.dart';
part 'get_post_video_controller_request.dart';

class LMVideoProvider {
  final Map<String, VideoPlayerController> _videoControllers = {};

  Future<VideoPlayerController> getPostVideoController(
      LMGetPostVideoControllerRequest request) async {
    String postId = request.postId;
    if (_videoControllers.containsKey(postId)) {
      return _videoControllers[postId]!;
    }
    return _videoControllers[postId] =
        await initialisePostVideoController(request);
  }

  void clearPostController(String postId) {
    _videoControllers[postId]?.dispose();
    _videoControllers.remove(postId);
  }

  Future<VideoPlayerController> initialisePostVideoController(
      LMGetPostVideoControllerRequest request) async {
    VideoPlayerController controller;

    if (request.videoType == LMVideoSourceType.network) {
      controller =
          VideoPlayerController.networkUrl(Uri.parse(request.videoSource));
    } else {
      controller = VideoPlayerController.file(File(request.videoSource));
    }

    await controller.initialize();

    return controller;
  }
}
