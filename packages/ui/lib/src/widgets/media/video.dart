import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;

class LMFeedVideo extends StatefulWidget {
  const LMFeedVideo({
    super.key,
    required this.postId,
    this.videoUrl,
    this.videoFile,
    this.playButton,
    this.pauseButton,
    this.muteButton,
    this.style,
    this.onMediaTap,
    this.videoController,
    this.position,
    this.autoPlay = false,
  }) : assert(videoUrl != null || videoFile != null);

  //Video asset variables
  final String? videoUrl;
  final File? videoFile;
  final VideoController? videoController;
  final int? position;

  final String postId;

  final LMFeedButton? playButton;
  final LMFeedButton? pauseButton;
  final LMFeedButton? muteButton;

  final LMFeedPostVideoStyle? style;

  final bool autoPlay;

  final Function(int)? onMediaTap;

  @override
  State<LMFeedVideo> createState() => _LMFeedVideoState();

  LMFeedVideo copyWith(
      {String? postId,
      String? videoUrl,
      File? videoFile,
      LMFeedButton? playButton,
      LMFeedButton? pauseButton,
      LMFeedButton? muteButton,
      LMFeedPostVideoStyle? style,
      Function(int)? onMediaTap,
      int? position}) {
    return LMFeedVideo(
      postId: postId ?? this.postId,
      videoUrl: videoUrl ?? this.videoUrl,
      videoFile: videoFile ?? this.videoFile,
      playButton: playButton ?? this.playButton,
      pauseButton: pauseButton ?? this.pauseButton,
      muteButton: muteButton ?? this.muteButton,
      style: style ?? this.style,
      onMediaTap: onMediaTap ?? this.onMediaTap,
      position: position ?? this.position,
    );
  }
}

class _LMFeedVideoState extends VisibilityAwareState<LMFeedVideo> {
  ValueNotifier<bool> rebuildOverlay = ValueNotifier(false);
  bool _onTouch = true;
  bool initialiseOverlay = false;
  ValueNotifier<bool>? isMuted;
  ValueNotifier<bool>? isFullscreen;
  ValueNotifier<bool> rebuildVideo = ValueNotifier(false);
  VideoController? controller;

  Timer? _timer;

  LMFeedPostVideoStyle? style;

  Future<void>? initialiseVideo;

  @override
  void dispose() async {
    debugPrint("Disposing video");
    _timer?.cancel();
    super.dispose();
  }

  @override
  void deactivate() async {
    debugPrint("Deactivating video");
    _timer?.cancel();
    controller?.player.pause();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    isMuted = LMFeedVideoProvider.instance.isMuted;
    isFullscreen = ValueNotifier(false);
    initialiseVideo = initialiseControllers();
  }

  @override
  void didUpdateWidget(LMFeedVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    isMuted = LMFeedVideoProvider.instance.isMuted;
    initialiseVideo = initialiseControllers();
  }

  @override
  void onVisibilityChanged(WidgetVisibility visibility) {
    if (visibility == WidgetVisibility.INVISIBLE) {
      controller?.player.pause();
    } else if (visibility == WidgetVisibility.GONE) {
      controller?.player.pause();
    }
    super.onVisibilityChanged(visibility);
  }

  Future<void> initialiseControllers() async {
    if (widget.videoController != null) {
      controller = widget.videoController;
      return;
    }

    LMFeedGetPostVideoControllerRequestBuilder requestBuilder =
        LMFeedGetPostVideoControllerRequestBuilder();

    requestBuilder.postId(widget.postId);

    if (widget.videoUrl != null) {
      requestBuilder
        ..autoPlay(widget.autoPlay)
        ..videoSource(widget.videoUrl!)
        ..videoType(LMFeedVideoSourceType.network)
        ..position(widget.position ?? 0);
    } else {
      requestBuilder
        ..autoPlay(widget.autoPlay)
        ..videoSource(widget.videoFile!.uri.toString())
        ..videoType(LMFeedVideoSourceType.file)
        ..position(widget.position ?? 0);
    }

    controller = await LMFeedVideoProvider.instance
        .videoControllerProvider(requestBuilder.build());

    if (widget.position != null && widget.position != 0) {
      LMFeedVideoProvider.instance.currentVisiblePostPosition =
          widget.position!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;
    style = widget.style ?? feedTheme.mediaStyle.videoStyle;
    return GestureDetector(
      onTap: () {
        if (_onTouch) {
          widget.onMediaTap?.call(widget.position ?? 0);
        }
        _timer?.cancel();
        if (controller == null) {
          return;
        }
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
      child: Container(
        padding: style?.padding,
        margin: style?.margin,
        child: ValueListenableBuilder(
          valueListenable: rebuildVideo,
          builder: (context, _, __) {
            return FutureBuilder(
              future: initialiseVideo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return style?.shimmerWidget ??
                      LMPostMediaShimmer(
                        style: LMPostMediaShimmerStyle(
                          width: widget.style?.width ?? screenSize.width,
                          height: widget.style?.height,
                        ),
                      );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (!initialiseOverlay) {
                    _timer =
                        Timer.periodic(const Duration(milliseconds: 3000), (_) {
                      initialiseOverlay = true;
                      _onTouch = false;
                      rebuildOverlay.value = !rebuildOverlay.value;
                    });
                  }
                  return VisibilityDetector(
                    key: ObjectKey(controller!.player),
                    onVisibilityChanged: (visibilityInfo) {
                      if (mounted) {
                        var visiblePercentage =
                            visibilityInfo.visibleFraction * 100;
                        if (visiblePercentage < 100) {
                          controller?.player.pause();
                        }
                        if (visiblePercentage == 100 && widget.autoPlay) {
                          LMFeedVideoProvider.instance.currentVisiblePostId =
                              widget.postId;
                          controller?.player.play();
                          rebuildOverlay.value = !rebuildOverlay.value;
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: widget.style?.width ?? screenSize.width,
                          height: widget.style?.height,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: widget.style?.borderRadius,
                            border: Border.all(
                              color: widget.style?.borderColor ??
                                  Colors.transparent,
                              width: 0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: MaterialVideoControlsTheme(
                            normal: MaterialVideoControlsThemeData(
                              bottomButtonBar: [
                                widget.muteButton ?? _defMuteButton(),
                                const Spacer(),
                                const MaterialFullscreenButton(),
                              ],
                              bottomButtonBarMargin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              seekBarMargin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              seekBarPositionColor:
                                  widget.style?.seekBarColor ??
                                      feedTheme.primaryColor,
                              seekBarThumbColor: widget.style?.seekBarColor ??
                                  feedTheme.primaryColor,
                            ),
                            fullscreen: MaterialVideoControlsThemeData(
                              seekBarMargin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              seekBarPositionColor:
                                  widget.style?.seekBarColor ??
                                      feedTheme.primaryColor,
                              seekBarThumbColor: widget.style?.seekBarColor ??
                                  feedTheme.primaryColor,
                              bottomButtonBar: [
                                const MaterialPositionIndicator(),
                                const Spacer(),
                                widget.muteButton ?? _defMuteButton(),
                                const SizedBox(width: 4),
                                const MaterialFullscreenButton(),
                              ],
                              bottomButtonBarMargin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Video(
                              fit: style?.boxFit ?? BoxFit.contain,
                              aspectRatio: style?.aspectRatio,
                              onEnterFullscreen: () async {
                                LMFeedVideoProvider.instance.playCurrentVideo();
                              },
                              controller: controller!,
                              controls: widget.style?.showControls != null &&
                                      widget.style!.showControls!
                                  ? media_kit_video_controls
                                      .AdaptiveVideoControls
                                  : (state) {
                                      return _defVideoControls(state);
                                    },
                            ),
                          ),
                        ),
                        // widget.muteButton ?? _defMuteButton()
                      ],
                    ),
                  );
                } else {
                  return widget.style?.errorWidget ?? const SizedBox();
                }
              },
            );
          },
        ),
      ),
    );
  }

  _defMuteButton() {
    return ValueListenableBuilder(
      valueListenable: isMuted!,
      builder: (context, state, _) {
        return IconButton(
          onPressed: () {
            LMFeedVideoProvider.instance.toggleVolumeState();
          },
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            style: const LMFeedIconStyle(
              color: Colors.white,
            ),
            icon: state ? Icons.volume_off : Icons.volume_up,
          ),
        );
      },
    );
  }

  Stack _defVideoControls(VideoState state) {
    return Stack(
      children: [
        Positioned(
          bottom: 2,
          left: 2,
          child: widget.muteButton ?? _defMuteButton(),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          top: 0,
          child: ValueListenableBuilder(
            valueListenable: rebuildOverlay,
            builder: (context, _, __) {
              return Visibility(
                visible: _onTouch || !controller!.player.state.playing,
                child: Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        const CircleBorder(
                          side: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child:
                        controller != null && controller!.player.state.playing
                            ? style?.pauseButton ??
                                const Icon(
                                  Icons.pause,
                                  size: 28,
                                  color: Colors.white,
                                )
                            : style?.playButton ??
                                const Icon(
                                  Icons.play_arrow,
                                  size: 28,
                                  color: Colors.white,
                                ),
                    onPressed: () {
                      _timer?.cancel();
                      if (controller == null) {
                        return;
                      }
                      controller!.player.state.playing
                          ? state.widget.controller.player.pause()
                          : state.widget.controller.player.play();
                      rebuildOverlay.value = !rebuildOverlay.value;
                      _timer = Timer.periodic(
                        const Duration(milliseconds: 2500),
                        (_) {
                          _onTouch = false;
                          rebuildOverlay.value = !rebuildOverlay.value;
                        },
                      );
                      // enterFullscreen(
                      //     context);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LMFeedPostVideoStyle {
  // Video structure variables
  final double? height;
  final double? width;
  final double? aspectRatio; // defaults to 16/9
  final BorderRadius? borderRadius; // defaults to 0
  final Color? borderColor;
  final double? borderWidth;
  final BoxFit? boxFit; // defaults to BoxFit.cover
  final EdgeInsets? padding;
  final EdgeInsets? margin;

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
    this.padding,
    this.margin,
  });

  LMFeedPostVideoStyle copyWith({
    double? height,
    double? width,
    double? aspectRatio,
    BorderRadius? borderRadius,
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
    EdgeInsets? padding,
    EdgeInsets? margin,
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
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  factory LMFeedPostVideoStyle.basic({Color? primaryColor}) =>
      const LMFeedPostVideoStyle(
        loaderWidget: LMPostMediaShimmer(),
      );
}
