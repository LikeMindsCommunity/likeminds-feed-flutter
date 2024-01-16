import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/helper/attachment/attachment_view_data.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/theme.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/media/image.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/media/video.dart';
import 'package:media_kit_video/media_kit_video.dart';

class LMFeedCarousel extends StatefulWidget {
  final List<LMAttachmentViewData> attachments;
  final Function(VideoController)? initialiseVideoController;

  final LMFeedPostImage? imageItem;
  final LMFeedPostVideo? videoItem;

  final Widget Function(LMFeedPostImage)? imageBuilder;
  final Widget Function(LMFeedPostVideo)? videoBuilder;

  final LMFeedPostVideoStyle? videoStyle;
  final LMFeedPostImageStyle? imageStyle;
  final LMFeedPostCarouselStyle? style;

  final Function(String, StackTrace)? onError;

  const LMFeedCarousel({
    Key? key,
    required this.attachments,
    this.imageItem,
    this.videoItem,
    this.initialiseVideoController,
    this.onError,
    this.imageBuilder,
    this.videoBuilder,
    this.videoStyle,
    this.imageStyle,
    this.style,
  }) : super(key: key);

  @override
  State<LMFeedCarousel> createState() => _LMCarouselState();

  static LMFeedCarousel defCarousel(
    List<LMAttachmentViewData> attachments, {
    LMFeedPostImage? imageItem,
    LMFeedPostVideo? videoItem,
    Function(String, StackTrace)? onError,
    Function(VideoController)? initialiseVideoController,
  }) {
    return LMFeedCarousel(
      attachments: attachments,
      imageItem: imageItem,
      videoItem: videoItem,
      onError: onError,
      initialiseVideoController: initialiseVideoController,
    );
  }
}

class _LMCarouselState extends State<LMFeedCarousel> {
  final ValueNotifier<bool> rebuildCurr = ValueNotifier(false);
  List<Widget> mediaWidgets = [];
  int currPosition = 0;
  LMFeedPostCarouselStyle? style;

  @override
  void initState() {
    super.initState();
  }

  bool checkIfMultipleAttachments() {
    return ((widget.attachments.isNotEmpty && widget.attachments.length > 1));
  }

  void mapAttachmentsToWidget() {
    mediaWidgets = widget.attachments.map((e) {
      if (e.attachmentType == 1) {
        return Container(
          color: Colors.black,
          width: style?.carouselWidth ?? MediaQuery.of(context).size.width,
          child: Center(
            child: widget.imageItem ??
                LMFeedPostImage(
                  imageUrl: e.attachmentMeta.url,
                  style: widget.imageStyle,
                  onError: widget.onError,
                ),
          ),
        );
      } else if ((e.attachmentType == 2)) {
        return Container(
          color: Colors.black,
          width: style?.carouselWidth ?? MediaQuery.of(context).size.width,
          child: widget.videoItem ??
              LMFeedPostVideo(
                initialiseVideoController: widget.initialiseVideoController,
                videoUrl: e.attachmentMeta.url,
                style: widget.videoStyle,
              ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    style = widget.style ?? feedTheme.postStyle.mediaStyle.carouselStyle;
    mapAttachmentsToWidget();
    return Container(
      width: style!.carouselWidth ?? MediaQuery.of(context).size.width,
      height: style!.carouselHeight,
      padding: style!.carouselPadding,
      margin: style!.carouselMargin,
      decoration: BoxDecoration(
        borderRadius: style!.carouselBorderRadius,
        border: style!.carouselBorder ??
            Border.all(
              color: Colors.transparent,
              width: 0,
            ),
        boxShadow: style!.carouselShadow,
      ),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: style!.carouselBorderRadius ?? BorderRadius.zero,
            child: CarouselSlider.builder(
              itemCount: mediaWidgets.length,
              itemBuilder: (context, index, _) => mediaWidgets[index],
              options: style!.carouselOptions?.copyWith(
                    onPageChanged: (index, reason) {
                      currPosition = index;
                      rebuildCurr.value = !rebuildCurr.value;
                    },
                  ) ??
                  CarouselOptions(
                    animateToClosest: false,
                    aspectRatio: 1,
                    enableInfiniteScroll: false,
                    enlargeFactor: 0.0,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      currPosition = index;
                      rebuildCurr.value = !rebuildCurr.value;
                    },
                  ),
            ),
          ),
          (style!.showIndicator ?? true)
              ? ValueListenableBuilder(
                  valueListenable: rebuildCurr,
                  builder: (context, _, __) {
                    return Column(
                      children: [
                        checkIfMultipleAttachments()
                            ? LikeMindsTheme.kVerticalPaddingMedium
                            : const SizedBox(),
                        checkIfMultipleAttachments()
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.attachments.map((url) {
                                  int index = widget.attachments.indexOf(url);
                                  return currPosition == index
                                      ? Container(
                                          width: style!.indicatorWidth ?? 16.0,
                                          height: style!.indicatorHeight ?? 8.0,
                                          padding: style!.indicatorPadding,
                                          margin: style!.indicatorMargin ??
                                              const EdgeInsets.symmetric(
                                                  vertical: 7.0,
                                                  horizontal: 2.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                style!.indicatorBorderRadius ??
                                                    const BorderRadius.all(
                                                      Radius.circular(4),
                                                    ),
                                            color:
                                                style!.activeIndicatorColor ??
                                                    feedTheme.primaryColor,
                                          ),
                                        )
                                      : Container(
                                          width: style!.indicatorWidth ?? 8.0,
                                          height: style!.indicatorHeight ?? 8.0,
                                          padding: style!.indicatorPadding,
                                          margin: style!.indicatorMargin ??
                                              const EdgeInsets.symmetric(
                                                  vertical: 7.0,
                                                  horizontal: 2.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                style!.indicatorBorderRadius ??
                                                    const BorderRadius.all(
                                                      Radius.circular(4),
                                                    ),
                                            color:
                                                style!.inActiveIndicatorColor ??
                                                    feedTheme.inActiveColor,
                                          ),
                                        );
                                }).toList(),
                              )
                            : const SizedBox(),
                      ],
                    );
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class LMFeedPostCarouselStyle {
  final CarouselOptions? carouselOptions;
  final Color? activeIndicatorColor;
  final Color? inActiveIndicatorColor;

  final double? indicatorHeight;
  final double? indicatorWidth;

  final EdgeInsets? indicatorMargin;
  final EdgeInsets? indicatorPadding;

  final BorderRadius? indicatorBorderRadius;

  final bool? showIndicator;

  final double? carouselHeight;
  final double? carouselWidth;

  final BorderRadius? carouselBorderRadius;
  final Border? carouselBorder;

  final EdgeInsets? carouselMargin;
  final EdgeInsets? carouselPadding;

  final List<BoxShadow>? carouselShadow;

  const LMFeedPostCarouselStyle({
    this.carouselOptions,
    this.activeIndicatorColor,
    this.inActiveIndicatorColor,
    this.indicatorHeight,
    this.indicatorWidth,
    this.indicatorBorderRadius,
    this.showIndicator,
    this.carouselHeight,
    this.carouselWidth,
    this.carouselBorderRadius,
    this.carouselBorder,
    this.carouselMargin,
    this.carouselPadding,
    this.carouselShadow,
    this.indicatorMargin,
    this.indicatorPadding,
  });

  LMFeedPostCarouselStyle copyWith({
    CarouselOptions? carouselOptions,
    Color? activeIndicatorColor,
    Color? inActiveIndicatorColor,
    double? indicatorHeight,
    double? indicatorWidth,
    BorderRadius? indicatorBorderRadius,
    bool? showIndicator,
    double? carouselHeight,
    double? carouselWidth,
    BorderRadius? carouselBorderRadius,
    Border? carouselBorder,
    EdgeInsets? carouselMargin,
    EdgeInsets? carouselPadding,
    List<BoxShadow>? carouselShadow,
    EdgeInsets? indicatorMargin,
    EdgeInsets? indicatorPadding,
  }) {
    return LMFeedPostCarouselStyle(
      carouselOptions: carouselOptions ?? this.carouselOptions,
      activeIndicatorColor: activeIndicatorColor ?? this.activeIndicatorColor,
      inActiveIndicatorColor:
          inActiveIndicatorColor ?? this.inActiveIndicatorColor,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorWidth: indicatorWidth ?? this.indicatorWidth,
      indicatorBorderRadius:
          indicatorBorderRadius ?? this.indicatorBorderRadius,
      showIndicator: showIndicator ?? this.showIndicator,
      carouselHeight: carouselHeight ?? this.carouselHeight,
      carouselWidth: carouselWidth ?? this.carouselWidth,
      carouselBorderRadius: carouselBorderRadius ?? this.carouselBorderRadius,
      carouselBorder: carouselBorder ?? this.carouselBorder,
      carouselMargin: carouselMargin ?? this.carouselMargin,
      carouselPadding: carouselPadding ?? this.carouselPadding,
      carouselShadow: carouselShadow ?? this.carouselShadow,
      indicatorMargin: indicatorMargin ?? this.indicatorMargin,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
    );
  }
}
