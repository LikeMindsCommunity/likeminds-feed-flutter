import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

part 'get_post_video_controller_response.dart';
part 'get_post_video_controller_request.dart';

/// LMVideoProvider is a singleton class that provides video controllers for
/// post with videos.
/// It also manages the lifecycle of the video controllers.
/// Any Controller that goes out of scope is disposed by the LMVideoProvider.
class LMFeedVideoProvider with ChangeNotifier {
  // This variable holds the mute state of the video controllers.
  // If the value is true, then all the video controllers are muted.
  // If the value is false, then all the video controllers are unmuted.
  ValueNotifier<bool> isMuted = ValueNotifier(true);

  /// Map of postId to VideoPlayerController
  /// This map holds all the video controllers that are currently in use.
  /// The video controllers are disposed when they are removed from this map.
  /// This map is also used to check if a video controller is already in use.
  final int _maxControllers = 6;
  final LinkedHashMap<String, Map<int, VideoController>> _videoControllers =
      LinkedHashMap();

  /// set of postId + position
  /// that are currently in progress of being initialized.
  /// This set is used to check if a controller is already in progress of being
  /// initialized. If the controller is already in progress of being initialized
  /// then the same controller is returned.
  /// This set is also used to wait for the controller to be initialized and
  /// then return it.
  final Set<String> _inProgressVideoControllers = {};

  /// This variable holds the postId of the post that is currently visible.
  /// It variable is used to pause the video when the post is not visible
  /// or to resume the video when the post becomes visible.
  String? currentVisiblePostId;

  int? currentVisiblePostPosition;

  static LMFeedVideoProvider? _instance;

  static LMFeedVideoProvider get instance =>
      _instance ??= LMFeedVideoProvider._();
  LMFeedVideoProvider._();

  // VideoController? getVideoController(String postId) {
  //   return _videoControllers[postId]?.values.first;
  // }

  VideoController? getVideoControllers(String postId, int position) {
    return _videoControllers[postId]?[position];
  }

  Future<void> pauseCurrentVideo() async {
    if (currentVisiblePostId != null && currentVisiblePostPosition != null) {
      await _videoControllers[currentVisiblePostId]![
              currentVisiblePostPosition]!
          .player
          .pause();
    }
  }

  void playCurrentVideo() {
    if (currentVisiblePostId != null && currentVisiblePostPosition != null) {
      _videoControllers[currentVisiblePostId]![currentVisiblePostPosition]!
          .player
          .play();
    }
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
    // tempId is used to uniquely identify the controller according to the
    // postId and position. it is used to check if the controller is already in
    // progress of being initialized. If the controller is already in progress
    // of being initialized, then the same controller is returned.
    String tempId = postId + request.position.toString();
    VideoController videoController;
    if (_videoControllers.containsKey(postId) &&
        _videoControllers[postId]!.containsKey(request.position)) {
      videoController = _videoControllers[postId]![request.position]!;
      // Move the accessed controller to the end to mark it as recently used
      _videoControllers[postId]!.remove(request.position);
      _videoControllers[postId]![request.position] = videoController;
    } else {
      if (!_inProgressVideoControllers.contains(tempId)) {
        _inProgressVideoControllers.add(tempId);
        videoController = await initialisePostVideoController(request);
        _videoControllers[postId] ??= {};
        _videoControllers[postId]![request.position] = videoController;
        _checkAndEvictControllers();
      } else {
        // wait for the controller to be initialised and then return it
        Completer<VideoController> completer = Completer();
        Timer.periodic(Duration(milliseconds: 500), (timer) {
          if (_videoControllers.containsKey(postId) &&
              _videoControllers[postId]!.containsKey(request.position)) {
            videoController = _videoControllers[postId]![request.position]!;
            completer.complete(videoController);
            timer.cancel();
          }
        });
        videoController = await completer.future;
      }
    }

    if (isMuted.value) {
      videoController.player.setVolume(0.0);
    } else {
      videoController.player.setVolume(100.0);
    }
    _inProgressVideoControllers.remove(tempId);
    return videoController;
  }

  void _checkAndEvictControllers() {
    while (_videoControllers.length > _maxControllers) {
      String oldestPostId = _videoControllers.keys.first;
      clearPostController(oldestPostId);
    }
  }

  /// Disposes the video controller for the given postId and removes it from
  /// the map.
  /// This method must be called when the video controller is not in use
  /// anymore.
  void clearPostController(String postId) {
    // dispose the controller if it exists
    _videoControllers[postId]?.values.forEach((element) {
      element.player.dispose();
    });
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
        bufferSize: 4 * 1024 * 1024,
        ready: () {},
        muted: isMuted.value,
      ),
    );
    controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        scale: 0.5,
      ),
    );

    // initialise the controller based on the video source type
    // network or file
    if (request.videoType == LMFeedVideoSourceType.network) {
      // if the video source type is network, then the video source is a url
      await player.open(
        Media(request.videoSource!),
        play: request.autoPlay,
      );
    } else if (request.videoType == LMFeedVideoSourceType.bytes) {
      // if the video source type is file, then the video source is a file path
      await player.open(
        await Media.memory(request.videoBytes!),
        play: request.autoPlay,
      );
    } else if (request.videoType == LMFeedVideoSourceType.path) {
      // if the video source type is file, then the video source is a file path
      await player.open(
        Media(request.videoSource!),
        play: request.autoPlay,
      );
    }

    return controller;
  }

  /// This functions mutes all the controller in the map.
  void forceMuteAllControllers() {
    for (var controller in _videoControllers.values) {
      for (var element in controller.values) {
        element.player.setVolume(0.0);
      }
    }
    isMuted.value = true;
  }

  void toggleVolumeState() {
    if (isMuted.value) {
      for (var controller in _videoControllers.values) {
        for (var element in controller.values) {
          element.player.setVolume(100.0);
        }
      }
      isMuted.value = false;
    } else {
      for (var controller in _videoControllers.values) {
        for (var element in controller.values) {
          element.player.setVolume(0.0);
        }
      }
      isMuted.value = true;
    }
    notifyListeners();
  }

  /// This functions pause all the controller in the map.
  void forcePauseAllControllers() {
    for (var controller in _videoControllers.values) {
      for (var element in controller.values) {
        if (element.player.state.playing) {
          element.player.pause();
        }
      }
    }
  }
}
