import 'dart:io';

import 'package:video_player/video_player.dart';

part 'get_post_video_controller_response.dart';
part 'get_post_video_controller_request.dart';

/// LMVideoProvider is a singleton class that provides video controllers for
/// post with videos.
/// It also manages the lifecycle of the video controllers.
/// Any Controller that goes out of scope is disposed by the LMVideoProvider.
class LMFeedVideoProvider {
  /// Map of postId to VideoPlayerController
  /// This map holds all the video controllers that are currently in use.
  /// The video controllers are disposed when they are removed from this map.
  /// This map is also used to check if a video controller is already in use.
  final Map<String, VideoPlayerController> _videoControllers = {};

  static LMFeedVideoProvider? _instance;

  static LMFeedVideoProvider get() => _instance ??= LMFeedVideoProvider._();

  LMFeedVideoProvider._();

  /// Returns a VideoPlayerController for the given postId.
  /// If a controller is already in use for the given postId, then the same
  /// controller is returned.
  ///
  /// If no controller is in use for the given postId, then a new controller
  /// is initialised and returned.
  ///
  /// The video controller must be disposed and removed from the map.
  /// when not in use anymore using [clearPostController] method
  Future<VideoPlayerController> getPostVideoController(
      LMFeedGetPostVideoControllerRequest request) async {
    String postId = request.postId;
    if (_videoControllers.containsKey(postId)) {
      return _videoControllers[postId]!;
    }
    return _videoControllers[postId] =
        await initialisePostVideoController(request);
  }

  /// Disposes the video controller for the given postId and removes it from
  /// the map.
  /// This method must be called when the video controller is not in use
  /// anymore.
  ///
  void clearPostController(String postId) {
    // dispose the controller if it exists
    _videoControllers[postId]?.dispose();
    // remove the controller from the map
    _videoControllers.remove(postId);
  }

  /// Initialises a new video controller for the given postId.
  /// The video controller is initialised based on the video source type.
  /// The video source type can be network or file.
  /// If the video source type is network, then the video source is a url.
  /// If the video source type is file, then the video source is a file path.
  Future<VideoPlayerController> initialisePostVideoController(
      LMFeedGetPostVideoControllerRequest request) async {
    VideoPlayerController controller;

    // initialise the controller based on the video source type
    // network or file
    if (request.videoType == LMFeedVideoSourceType.network) {
      // if the video source type is network, then the video source is a url
      controller =
          VideoPlayerController.networkUrl(Uri.parse(request.videoSource));
    } else {
      // if the video source type is file, then the video source is a file path
      controller = VideoPlayerController.file(File(request.videoSource));
    }

    // initialise the controller and return
    await controller.initialize();

    return controller;
  }
}
