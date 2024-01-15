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

  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderSize;
  final Color? borderColor;
  final Color? activeIndicatorColor;
  final Color? inactiveIndicatorColor;

  final Widget? activeIndicator;
  final Widget? inactiveIndicator;

  final LMFeedImage? imageItem;
  final LMFeedVideo? videoItem;
  final Widget? errorWidget;
  final BoxFit? boxFit;
  final Function(String, StackTrace)? onError;

  const LMFeedCarousel({
    Key? key,
    required this.attachments,
    this.height,
    this.width,
    this.borderRadius,
    this.borderSize,
    this.borderColor,
    this.activeIndicator,
    this.inactiveIndicator,
    this.imageItem,
    this.videoItem,
    this.activeIndicatorColor,
    this.inactiveIndicatorColor,
    this.errorWidget,
    this.boxFit,
    this.initialiseVideoController,
    this.onError,
  }) : super(key: key);

  @override
  State<LMFeedCarousel> createState() => _LMCarouselState();

  static LMFeedCarousel defCarousel(
    List<LMAttachmentViewData> attachments, {
    double? height,
    double? width,
    double? borderRadius,
    double? borderSize,
    Color? borderColor,
    Color? activeIndicatorColor,
    Color? inactiveIndicatorColor,
    Widget? activeIndicator,
    Widget? inactiveIndicator,
    LMFeedImage? imageItem,
    LMFeedVideo? videoItem,
    Widget? errorWidget,
    BoxFit? boxFit,
    Function(String, StackTrace)? onError,
    Function(VideoController)? initialiseVideoController,
  }) {
    return LMFeedCarousel(
      attachments: attachments,
      height: height,
      width: width,
      borderRadius: borderRadius,
      borderSize: borderSize,
      borderColor: borderColor,
      activeIndicatorColor: activeIndicatorColor,
      inactiveIndicatorColor: inactiveIndicatorColor,
      activeIndicator: activeIndicator,
      inactiveIndicator: inactiveIndicator,
      imageItem: imageItem,
      videoItem: videoItem,
      errorWidget: errorWidget,
      boxFit: boxFit,
      onError: onError,
      initialiseVideoController: initialiseVideoController,
    );
  }
}

class _LMCarouselState extends State<LMFeedCarousel> {
  final ValueNotifier<bool> rebuildCurr = ValueNotifier(false);
  List<Widget> mediaWidgets = [];
  int currPosition = 0;

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
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: Center(
            child: widget.imageItem ??
                LMFeedImage(
                  imageUrl: e.attachmentMeta.url,
                  height: widget.height,
                  width: widget.width,
                  borderRadius: widget.borderRadius,
                  borderColor: widget.borderColor,
                  boxFit: widget.boxFit ?? BoxFit.contain,
                  errorWidget: widget.errorWidget,
                  onError: widget.onError,
                ),
          ),
        );
      } else if ((e.attachmentType == 2)) {
        return Container(
          color: Colors.black,
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: widget.videoItem ??
              LMFeedVideo(
                initialiseVideoController: widget.initialiseVideoController,
                videoUrl: e.attachmentMeta.url,
                width: widget.width,
                height: widget.height,
                borderRadius: widget.borderRadius,
                borderColor: widget.borderColor,
                boxFit: widget.boxFit ?? BoxFit.contain,
                showControls: false,
                errorWidget: widget.errorWidget,
              ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    mapAttachmentsToWidget();
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
        border: Border.all(
          color: widget.borderColor ?? Colors.transparent,
          width: widget.borderSize ?? 0,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
            child: CarouselSlider.builder(
              itemCount: mediaWidgets.length,
              itemBuilder: (context, index, _) => mediaWidgets[index],
              options: CarouselOptions(
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
          ValueListenableBuilder(
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
                                  ? widget.activeIndicator ??
                                      Container(
                                        width: 16.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 7.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                          color: widget.activeIndicatorColor ??
                                              feedTheme.primaryColor,
                                        ),
                                      )
                                  : widget.inactiveIndicator ??
                                      Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 7.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                          color:
                                              widget.inactiveIndicatorColor ??
                                                  Colors.grey,
                                        ),
                                      );
                            }).toList(),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
