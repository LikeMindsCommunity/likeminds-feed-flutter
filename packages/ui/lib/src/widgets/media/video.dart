import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;

class LMFeedPostVideo extends StatefulWidget {
  // late final LMFeedVideo? _instance;

  const LMFeedPostVideo({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.playButton,
    this.pauseButton,
    this.muteButton,
    this.isMute,
    this.initialiseVideoController,
    this.style,
  }) : assert(videoUrl != null || videoFile != null);

  //Video asset variables
  final String? videoUrl;
  final File? videoFile;

  final Function(VideoController)? initialiseVideoController;

  final LMFeedButton? playButton;
  final LMFeedButton? pauseButton;
  final LMFeedButton? muteButton;

  final LMFeedPostVideoStyle? style;
  // Video functionality control variables
  final bool? isMute;

  @override
  State<LMFeedPostVideo> createState() => _LMFeedPostVideoState();

  LMFeedPostVideo copyWith({
    String? videoUrl,
    File? videoFile,
    LMFeedButton? playButton,
    LMFeedButton? pauseButton,
    LMFeedButton? muteButton,
    bool? isMute,
    Function(VideoController)? initialiseVideoController,
    LMFeedPostVideoStyle? style,
  }) {
    return LMFeedPostVideo(
      videoUrl: videoUrl ?? this.videoUrl,
      videoFile: videoFile ?? this.videoFile,
      playButton: playButton ?? this.playButton,
      pauseButton: pauseButton ?? this.pauseButton,
      muteButton: muteButton ?? this.muteButton,
      isMute: isMute ?? this.isMute,
      initialiseVideoController:
          initialiseVideoController ?? this.initialiseVideoController,
      style: style ?? this.style,
    );
  }
}

class _LMFeedPostVideoState extends State<LMFeedPostVideo> {
  ValueNotifier<bool> rebuildOverlay = ValueNotifier(false);
  bool _onTouch = true;
  bool initialiseOverlay = false;
  ValueNotifier<bool> isMuted = ValueNotifier(false);
  ValueNotifier<bool> rebuildVideo = ValueNotifier(false);

  Player player = Player();
  VideoController? controller;

  Timer? _timer;

  LMFeedPostVideoStyle? style;

  @override
  void dispose() async {
    debugPrint("Disposing video");
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  void deactivate() async {
    debugPrint("Deactivating video");
    _timer?.cancel();
    player.pause();
    super.deactivate();
  }

  @override
  void didUpdateWidget(LMFeedPostVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> initialiseControllers() async {
    player = Player(
      configuration: PlayerConfiguration(
        bufferSize: 24 * 1024 * 1024,
        ready: () {
          if (widget.isMute != null && widget.isMute!) player.setVolume(0);
        },
      ),
    );
    controller = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        scale: 0.2,
      ),
    );
    if (widget.initialiseVideoController != null) {
      widget.initialiseVideoController!(controller!);
    }
    if (widget.videoUrl != null) {
      await player.open(
        Media(widget.videoUrl!),
        play: style?.autoPlay ?? false,
      );
    } else {
      await player.open(
        Media(widget.videoFile!.uri.toString()),
        play: style?.autoPlay ?? false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    style = widget.style ?? LMFeedTheme.of(context).mediaStyle.videoStyle;
    return GestureDetector(
      onTap: () {
        _timer?.cancel();
        if (controller == null) {
          return;
        }
        // controller!.player.state.playing
        //     ? controller!.player.pause()
        //     : controller!.player.play();
        _onTouch = !_onTouch;
        rebuildOverlay.value = !rebuildOverlay.value;
        _timer = Timer.periodic(
          const Duration(milliseconds: 2500),
          (_) {
            _onTouch = false;
            rebuildOverlay.value = !rebuildOverlay.value;
          },
        );
      },
      child: ValueListenableBuilder(
          valueListenable: rebuildVideo,
          builder: (context, _, __) {
            return FutureBuilder(
              future: initialiseControllers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LMPostMediaShimmer();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (!initialiseOverlay) {
                    _timer =
                        Timer.periodic(const Duration(milliseconds: 3000), (_) {
                      initialiseOverlay = true;
                      _onTouch = false;
                      rebuildOverlay.value = !rebuildOverlay.value;
                    });
                  }
                  return Stack(children: [
                    VisibilityDetector(
                      key: ObjectKey(player),
                      onVisibilityChanged: (visibilityInfo) {
                        if (mounted) {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100;
                          if (visiblePercentage <= 70 &&
                              visiblePercentage > 0) {
                            controller?.player.pause();
                          }
                          if (visiblePercentage > 70) {
                            controller?.player.play();
                            rebuildOverlay.value = !rebuildOverlay.value;
                          }
                        }
                      },
                      child: Container(
                        width: widget.style?.width ?? screenSize.width,
                        height: widget.style?.height,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              widget.style?.borderRadius ?? 0),
                          border: Border.all(
                            color:
                                widget.style?.borderColor ?? Colors.transparent,
                            width: 0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: MaterialVideoControlsTheme(
                          normal: MaterialVideoControlsThemeData(
                            bottomButtonBar: [
                              const MaterialPositionIndicator(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  if (player.state.volume > 0.0) {
                                    player.setVolume(0);
                                    isMuted.value = true;
                                  } else {
                                    player.setVolume(100);
                                    isMuted.value = false;
                                  }
                                },
                                icon: ValueListenableBuilder(
                                    valueListenable: isMuted,
                                    builder: (context, isMuted, __) {
                                      return LMFeedIcon(
                                        type: LMFeedIconType.icon,
                                        style: const LMFeedIconStyle(
                                          color: Colors.white,
                                        ),
                                        icon: isMuted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                      );
                                    }),
                              )
                            ],
                            seekBarMargin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            seekBarPositionColor: widget.style?.seekBarColor ??
                                const Color.fromARGB(255, 0, 137, 123),
                            seekBarThumbColor: widget.style?.seekBarColor ??
                                const Color.fromARGB(255, 0, 137, 123),
                          ),
                          fullscreen: const MaterialVideoControlsThemeData(),
                          child: Video(
                            controller: controller!,
                            controls: widget.style?.showControls != null &&
                                    widget.style!.showControls!
                                ? media_kit_video_controls.AdaptiveVideoControls
                                : (state) {
                                    return ValueListenableBuilder(
                                      valueListenable: rebuildOverlay,
                                      builder: (context, _, __) {
                                        return Visibility(
                                          visible: _onTouch,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                              style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                  const CircleBorder(
                                                    side: BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              child: Icon(
                                                controller != null &&
                                                        controller!.player.state
                                                            .playing
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 28,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                _timer?.cancel();
                                                if (controller == null) {
                                                  return;
                                                }
                                                controller!.player.state.playing
                                                    ? state.widget.controller
                                                        .player
                                                        .pause()
                                                    : state.widget.controller
                                                        .player
                                                        .play();
                                                rebuildOverlay.value =
                                                    !rebuildOverlay.value;
                                                _timer = Timer.periodic(
                                                  const Duration(
                                                      milliseconds: 2500),
                                                  (_) {
                                                    _onTouch = false;
                                                    rebuildOverlay.value =
                                                        !rebuildOverlay.value;
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                          ),
                        ),
                      ),
                    ),
                  ]);
                } else {
                  return widget.style?.errorWidget ?? const SizedBox();
                }
              },
            );
          }),
    );
  }
}

class LMFeedPostVideoStyle {
  // Video structure variables
  final double? height;
  final double? width;
  final double? aspectRatio; // defaults to 16/9
  final double? borderRadius; // defaults to 0
  final Color? borderColor;
  final double? borderWidth;
  final BoxFit? boxFit; // defaults to BoxFit.cover

  // Video styling variables
  final Color? seekBarColor;
  final Color? seekBarBufferColor;
  final TextStyle? progressTextStyle;
  final Widget? loaderWidget;
  final Widget? errorWidget;
  final Widget? shimmerWidget;
  final LMFeedButton? playButton;
  final LMFeedButton? pauseButton;
  final LMFeedButton? muteButton;
  // Video functionality control variables
  final bool? showControls;
  final bool? autoPlay;
  final bool? looping;
  final bool? allowFullScreen;
  final bool? allowMuting;

  const LMFeedPostVideoStyle({
    this.height,
    this.width,
    this.aspectRatio,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.boxFit,
    this.seekBarColor,
    this.seekBarBufferColor,
    this.progressTextStyle,
    this.loaderWidget,
    this.errorWidget,
    this.shimmerWidget,
    this.playButton,
    this.pauseButton,
    this.muteButton,
    this.showControls,
    this.autoPlay,
    this.looping,
    this.allowFullScreen,
    this.allowMuting,
  });

  LMFeedPostVideoStyle copyWith({
    double? height,
    double? width,
    double? aspectRatio,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    BoxFit? boxFit,
    Color? seekBarColor,
    Color? seekBarBufferColor,
    TextStyle? progressTextStyle,
    Widget? loaderWidget,
    Widget? errorWidget,
    Widget? shimmerWidget,
    LMFeedButton? playButton,
    LMFeedButton? pauseButton,
    LMFeedButton? muteButton,
    bool? showControls,
    bool? autoPlay,
    bool? looping,
    bool? allowFullScreen,
    bool? allowMuting,
  }) {
    return LMFeedPostVideoStyle(
      height: height ?? this.height,
      width: width ?? this.width,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      boxFit: boxFit ?? this.boxFit,
      seekBarColor: seekBarColor ?? this.seekBarColor,
      seekBarBufferColor: seekBarBufferColor ?? this.seekBarBufferColor,
      progressTextStyle: progressTextStyle ?? this.progressTextStyle,
      loaderWidget: loaderWidget ?? this.loaderWidget,
      errorWidget: errorWidget ?? this.errorWidget,
      shimmerWidget: shimmerWidget ?? this.shimmerWidget,
      playButton: playButton ?? this.playButton,
      pauseButton: pauseButton ?? this.pauseButton,
      muteButton: muteButton ?? this.muteButton,
      showControls: showControls ?? this.showControls,
      autoPlay: autoPlay ?? this.autoPlay,
      looping: looping ?? this.looping,
      allowFullScreen: allowFullScreen ?? this.allowFullScreen,
      allowMuting: allowMuting ?? this.allowMuting,
    );
  }
}
