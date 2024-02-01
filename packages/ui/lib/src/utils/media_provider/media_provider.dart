import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  final Map<String, VideoController> _videoControllers = {};

  /// This variable holds the postId of the post that is currently visible.
  /// It variable is used to pause the video when the post is not visible
  /// or to resume the video when the post becomes visible.
  String? currentVisiblePostId;

  static LMFeedVideoProvider? _instance;

  static LMFeedVideoProvider get instance =>
      _instance ??= LMFeedVideoProvider._();
  LMFeedVideoProvider._();

  VideoController? getVideoController(String postId) {
    return _videoControllers[postId];
  }

  /// Returns a VideoPlayerController for the given postId.
  /// If a controller is already in use for the given postId, then the same
  /// controller is returned.
  ///
  /// If no controller is in use for the given postId, then a new controller
  /// is initialised and returned.
  ///
  /// The video controller must be disposed and removed from the map.
  /// when not in use anymore using [clearPostController] method
  Future<VideoController> videoControllerProvider(
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
    _videoControllers[postId]?.player.dispose();
    // remove the controller from the map
    _videoControllers.remove(postId);
  }

  /// Initialises a new video controller for the given postId.
  /// The video controller is initialised based on the video source type.
  /// The video source type can be network or file.
  /// If the video source type is network, then the video source is a url.
  /// If the video source type is file, then the video source is a file path.
  Future<VideoController> initialisePostVideoController(
      LMFeedGetPostVideoControllerRequest request) async {
    VideoController controller;

    Player player = Player(
      configuration: PlayerConfiguration(
        bufferSize: 24 * 1024 * 1024,
        ready: () {},
        muted: true,
      ),
    );
    controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        scale: 0.2,
      ),
    );

    // initialise the controller based on the video source type
    // network or file
    if (request.videoType == LMFeedVideoSourceType.network) {
      // if the video source type is network, then the video source is a url
      await player.open(
        Media(request.videoSource),
        play: false,
      );
    } else {
      // if the video source type is file, then the video source is a file path
      await player.open(
        Media(request.videoSource),
        play: false,
      );
    }

    return controller;
  }
}
