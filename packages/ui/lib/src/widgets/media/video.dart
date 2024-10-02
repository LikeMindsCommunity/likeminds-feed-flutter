import 'dart:async';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;

/// {@template lm_feed_video}
/// A widget that displays a video in a feed post with
/// customizable controls and styles.
///
/// The [LMFeedVideo] widget is a stateful widget that provides video
/// playback functionality with options for play, pause, and mute buttons.
/// It also supports auto-play, custom styles, and visibility detection to
/// pause the video when it is not visible.
///
/// The widget requires a [postId] and a [video] asset to be provided.
/// Optional parameters include custom buttons for play, pause,
/// and mute actions, a custom style, a callback for media tap events,
/// a video controller, and an initial playback position.
///
/// The widget uses the [VisibilityAwareState] to manage the
/// visibility of the video and
/// pause playback when the video is not visible.
///
/// The [LMFeedPostVideoStyle] class provides various styling options for the
/// video, including dimensions, padding, margin, border, and custom widgets
/// for loader, error, and shimmer states.
/// {@endtemplate}
class LMFeedVideo extends StatefulWidget {
  const LMFeedVideo({
    super.key,
    required this.postId,
    required this.video,
    this.playButton,
    this.pauseButton,
    this.muteButton,
    this.style,
    this.onMediaTap,
    this.videoController,
    this.position,
    this.autoPlay = false,
  });

  /// Video asset variables
  final LMAttachmentViewData video;
  final VideoController? videoController;
  final int? position;

  /// Post identifier
  final String postId;

  /// Customizable buttons for video controls
  final LMFeedButton? playButton;
  final LMFeedButton? pauseButton;
  final LMFeedButton? muteButton;

  /// Customizable style for the video widget
  final LMFeedPostVideoStyle? style;

  /// Auto-play functionality
  final bool autoPlay;

  /// Callback for media tap events
  final Function(int)? onMediaTap;

  @override
  State<LMFeedVideo> createState() => _LMFeedVideoState();

  LMFeedVideo copyWith(
      {String? postId,
      String? videoUrl,
      String? videoPath,
      LMFeedButton? playButton,
      LMFeedButton? pauseButton,
      LMFeedButton? muteButton,
      LMFeedPostVideoStyle? style,
      Function(int)? onMediaTap,
      int? position}) {
    return LMFeedVideo(
      postId: postId ?? this.postId,
      video: video,
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
  // Notifier to rebuild the overlay
  ValueNotifier<bool> rebuildOverlay = ValueNotifier(false);

  // Boolean to track touch state
  bool _onTouch = true;

  // Boolean to track if overlay is initialized
  bool initialiseOverlay = false;

  // Notifier to track mute state
  ValueNotifier<bool>? isMuted;

  // Notifier to track fullscreen state
  ValueNotifier<bool>? isFullscreen;

  // Notifier to rebuild the video
  ValueNotifier<bool> rebuildVideo = ValueNotifier(false);

  // Video controller
  VideoController? controller;

  // Timer for overlay visibility
  Timer? _timer;

  // URL for the video thumbnail
  String? thumbnailUrl;

  // Style for the video post
  LMFeedPostVideoStyle? style;

  // Future to initialize the video
  Future<void>? initialiseVideo;

  @override
  void dispose() async {
    // Print debug message
    debugPrint("Disposing video");

    // Cancel the timer
    _timer?.cancel();

    // Call the superclass dispose method
    super.dispose();
  }

  @override
  void deactivate() async {
    // Print debug message
    debugPrint("Deactivating video");

    // Cancel the timer
    _timer?.cancel();

    // Pause the video player
    controller?.player.pause();

    // Call the superclass deactivate method
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();

    // Set the thumbnail URL if available
    if (widget.video.attachmentMeta.thumbnailUrl != null) {
      thumbnailUrl = widget.video.attachmentMeta.thumbnailUrl;
    }

    // Initialize mute and fullscreen notifiers
    isMuted = LMFeedVideoProvider.instance.isMuted;
    isFullscreen = ValueNotifier(false);

    // Initialize the video controllers
    initialiseVideo = initialiseControllers();
  }

  @override
  void didUpdateWidget(LMFeedVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the thumbnail URL if available
    if (widget.video.attachmentMeta.thumbnailUrl != null) {
      thumbnailUrl = widget.video.attachmentMeta.thumbnailUrl;
    }

    // Update mute notifier
    isMuted = LMFeedVideoProvider.instance.isMuted;

    // Reinitialize the video controllers
    initialiseVideo = initialiseControllers();
  }

  @override
  void onVisibilityChanged(WidgetVisibility visibility) {
    // Pause the video if the widget is not visible
    if (visibility == WidgetVisibility.INVISIBLE) {
      controller?.player.pause();
    } else if (visibility == WidgetVisibility.GONE) {
      controller?.player.pause();
    } else if (visibility == WidgetVisibility.VISIBLE) {
      // Reinitialize the video controllers if needed
      if (!(controller?.player.platform?.isVideoControllerAttached ?? false)) {
        initialiseVideo = initialiseControllers();
        rebuildVideo.value = !rebuildVideo.value;
      }
    }
    super.onVisibilityChanged(visibility);
  }

  Future<void> initialiseControllers() async {
    // Use the provided video controller if available
    if (widget.videoController != null) {
      controller = widget.videoController;
      return;
    }

    // Build the request for the video controller
    LMFeedGetPostVideoControllerRequestBuilder requestBuilder =
        LMFeedGetPostVideoControllerRequestBuilder();

    requestBuilder.postId(widget.postId);

    // Set the video source based on the attachment metadata
    if (widget.video.attachmentMeta.url != null) {
      requestBuilder
        ..autoPlay(widget.autoPlay)
        ..videoSource(widget.video.attachmentMeta.url!)
        ..videoType(LMFeedVideoSourceType.network)
        ..position(widget.position ?? 0);
    } else if (widget.video.attachmentMeta.path != null) {
      requestBuilder
        ..autoPlay(widget.autoPlay)
        ..videoSource(widget.video.attachmentMeta.path!)
        ..videoType(LMFeedVideoSourceType.path)
        ..position(widget.position ?? 0);
    } else if (widget.video.attachmentMeta.bytes != null) {
      requestBuilder
        ..autoPlay(widget.autoPlay)
        ..videoBytes(widget.video.attachmentMeta.bytes!)
        ..videoType(LMFeedVideoSourceType.bytes)
        ..position(widget.position ?? 0);
    }

    // Get the video controller from the provider
    controller = await LMFeedVideoProvider.instance
        .videoControllerProvider(requestBuilder.build());

    // Update the current visible post position if needed
    if (widget.position != null && widget.position != 0) {
      LMFeedVideoProvider.instance.currentVisiblePostPosition =
          widget.position!;
    }

    // Wait until the first frame is rendered
    await controller?.waitUntilFirstFrameRendered;
    return;
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
                  if (thumbnailUrl != null) {
                    return Stack(alignment: Alignment.center, children: [
                      LMFeedImage(
                        image: LMAttachmentViewData.fromMediaUrl(
                          url: thumbnailUrl!,
                          attachmentType: LMMediaType.image,
                        ),
                      ),
                      const Center(
                        child: LMFeedLoader(),
                      ),
                    ]);
                  }
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
                      shape: WidgetStateProperty.all(
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
                    onPressed: () async {
                      _timer?.cancel();
                      if (controller == null) {
                        return;
                      }

                      if (!(controller
                              ?.player.platform?.isVideoControllerAttached ??
                          false)) {
                        await initialiseControllers();
                        rebuildVideo.value = !rebuildVideo.value;
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

/// {@template lm_feed_post_video_style}
/// A class representing the style configuration for a video post
/// in the LM feed.
///
/// This class is used to define various styling properties for video posts,
/// such as dimensions, border radius, and other visual aspects.
///
/// {@endtemplate}
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
