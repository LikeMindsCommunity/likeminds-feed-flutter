import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:media_kit_video/media_kit_video.dart';

class LMFeedCarousel extends StatefulWidget {
  final List<LMAttachmentViewData> attachments;
  final String postId;

  /// {@macro feed_image}
  final LMFeedImage? imageItem;
  final LMFeedVideo? videoItem;

  /// {@macro feed_image_builder}
  final LMFeedImageBuilder? imageBuilder;

  /// {@macro feed_video_builder}
  final LMFeedVideoBuilder? videoBuilder;

  /// {@macro feed_carousel_indicator_builder}
  final LMFeedCarouselIndicatorBuilder? carouselIndicatorBuilder;

  final LMFeedPostVideoStyle? videoStyle;
  final LMFeedPostImageStyle? imageStyle;
  final LMFeedPostCarouselStyle? style;

  /// {@macro feed_error_handler}
  final LMFeedErrorHandler? onError;
  final Function(int)? onMediaTap;

  const LMFeedCarousel({
    Key? key,
    required this.attachments,
    required this.postId,
    this.imageItem,
    this.videoItem,
    this.onError,
    this.imageBuilder,
    this.videoBuilder,
    this.videoStyle,
    this.imageStyle,
    this.style,
    this.onMediaTap,
    this.carouselIndicatorBuilder,
  }) : super(key: key);

  @override
  State<LMFeedCarousel> createState() => _LMCarouselState();

  LMFeedCarousel copyWith(
    List<LMAttachmentViewData>? attachments,
    String? postId, {
    LMFeedImage? imageItem,
    LMFeedVideo? videoItem,
    Function(String, StackTrace)? onError,
    LMFeedPostVideoStyle? videoStyle,
    LMFeedPostImageStyle? imageStyle,
    LMFeedPostCarouselStyle? style,
    Function(VideoController)? initialiseVideoController,
    Function(int)? onMediaTap,
    Widget Function(LMFeedImage)? imageBuilder,
    Widget Function(LMFeedVideo)? videoBuilder,
    LMFeedCarouselIndicatorBuilder? carouselIndicatorBuilder,
  }) {
    return LMFeedCarousel(
      postId: postId ?? this.postId,
      attachments: attachments ?? this.attachments,
      imageItem: imageItem ?? this.imageItem,
      videoItem: videoItem ?? this.videoItem,
      onError: onError ?? this.onError,
      videoStyle: videoStyle ?? this.videoStyle,
      imageStyle: imageStyle ?? this.imageStyle,
      style: style ?? this.style,
      onMediaTap: onMediaTap ?? this.onMediaTap,
      carouselIndicatorBuilder:
          carouselIndicatorBuilder ?? this.carouselIndicatorBuilder,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      videoBuilder: videoBuilder ?? this.videoBuilder,
    );
  }
}

class _LMCarouselState extends State<LMFeedCarousel> {
  late Size screenSize;
  final ValueNotifier<bool> rebuildCurr = ValueNotifier(false);
  LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;
  CarouselSliderController carouselController = CarouselSliderController();

  List<Widget> mediaWidgets = [];
  int currPosition = 0;
  late LMFeedPostCarouselStyle? style;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LMFeedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  bool checkIfMultipleAttachments() {
    return ((widget.attachments.isNotEmpty && widget.attachments.length > 1));
  }

  void mapAttachmentsToWidget() {
    mediaWidgets = [];
    widget.attachments.forEachIndexed((index, e) {
      if (e.attachmentType == LMMediaType.image) {
        mediaWidgets.add(Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: style?.carouselBorderRadius,
            color: Colors.black,
          ),
          width: style?.carouselWidth ?? screenSize.width,
          child: Center(
            child: widget.imageItem ??
                LMFeedImage(
                  image: e,
                  style: widget.imageStyle,
                  onError: widget.onError,
                  onMediaTap: widget.onMediaTap,
                  position: index,
                ),
          ),
        ));
      } else if (e.attachmentType == LMMediaType.video) {
        mediaWidgets.add(Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: style?.carouselBorderRadius,
            color: Colors.black,
          ),
          width: style?.carouselWidth ?? screenSize.width,
          child: widget.videoItem ??
              LMFeedVideo(
                video: e,
                style: widget.videoStyle,
                postId: widget.postId,
                onMediaTap: widget.onMediaTap,
                position: index,
              ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    style = widget.style ?? feedTheme.mediaStyle.carouselStyle;
    mapAttachmentsToWidget();
    return GestureDetector(
      onTap: () => widget.onMediaTap?.call(currPosition),
      child: Container(
        width: style!.carouselWidth ?? screenSize.width,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CarouselSlider.builder(
                    carouselController: carouselController,
                    itemCount: mediaWidgets.length,
                    itemBuilder: (context, index, _) {
                      return mediaWidgets[index];
                    },
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
                  if (checkIfMultipleAttachments() && kIsWeb)
                    ValueListenableBuilder(
                      valueListenable: rebuildCurr,
                      builder: (context, _, __) {
                        return Positioned(
                          bottom: 0,
                          top: 0,
                          child: SizedBox(
                            width: style!.carouselWidth ?? screenSize.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                currPosition > 0
                                    ? InkWell(
                                        onTap: () {
                                          if (currPosition > 0) {
                                            currPosition--;
                                            carouselController
                                                .animateToPage(currPosition);
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 50,
                                          width: (style!.carouselWidth ??
                                                  screenSize.width) *
                                              0.25,
                                          child: Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            color: feedTheme.container
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                currPosition != mediaWidgets.length - 1
                                    ? InkWell(
                                        onTap: () {
                                          if (currPosition <
                                              mediaWidgets.length - 1) {
                                            currPosition++;
                                            carouselController
                                                .animateToPage(currPosition);
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          height: 50,
                                          width: (style!.carouselWidth ??
                                                  screenSize.width) *
                                              0.25,
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: feedTheme.container
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            (style!.showIndicator ?? true) && checkIfMultipleAttachments()
                ? ValueListenableBuilder(
                    valueListenable: rebuildCurr,
                    builder: (context, _, __) {
                      Widget carouselIndicator =
                          defCarouselIndicator(feedTheme);
                      return widget.carouselIndicatorBuilder?.call(
                              context,
                              currPosition,
                              mediaWidgets.length,
                              carouselIndicator) ??
                          carouselIndicator;
                    },
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget defCarouselIndicator(LMFeedThemeData feedTheme) {
    return Column(
      children: [
        LikeMindsTheme.kVerticalPaddingMedium,
        Row(
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
                            vertical: 7.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: style!.indicatorBorderRadius ??
                          const BorderRadius.all(
                            Radius.circular(4),
                          ),
                      color:
                          style!.activeIndicatorColor ?? feedTheme.primaryColor,
                    ),
                  )
                : Container(
                    width: style!.indicatorWidth ?? 8.0,
                    height: style!.indicatorHeight ?? 8.0,
                    padding: style!.indicatorPadding,
                    margin: style!.indicatorMargin ??
                        const EdgeInsets.symmetric(
                            vertical: 7.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: style!.indicatorBorderRadius ??
                          const BorderRadius.all(
                            Radius.circular(4),
                          ),
                      color: style!.inActiveIndicatorColor ??
                          feedTheme.inActiveColor,
                    ),
                  );
          }).toList(),
        )
      ],
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
