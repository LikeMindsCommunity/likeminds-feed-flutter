import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class LMFeedMediaPreviewScreen extends StatefulWidget {
  final List<LMAttachmentViewData> postAttachments;
  final LMPostViewData post;
  final LMUserViewData user;
  final int? position;

  const LMFeedMediaPreviewScreen({
    Key? key,
    required this.postAttachments,
    required this.post,
    required this.user,
    this.position,
  }) : super(key: key);

  @override
  State<LMFeedMediaPreviewScreen> createState() =>
      _LMFeedMediaPreviewScreenState();
}

class _LMFeedMediaPreviewScreenState extends State<LMFeedMediaPreviewScreen> {
  late Size screenSize;
  final DateFormat formatter = DateFormat('MMMM d, hh:mm');
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedMediaPreviewScreenBuilderDelegate _widgetBuilder =
      LMFeedCore.config.mediaPreviewScreenConfig.builder;
  late List<LMAttachmentViewData> postAttachments;
  late LMPostViewData post;
  late LMUserViewData user;
  late int? position;

  int currPosition = 0;
  int mediaLength = 0;

  CarouselSliderController controller = CarouselSliderController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  @override
  void initState() {
    postAttachments = widget.postAttachments;
    post = widget.post;
    user = widget.user;
    position = widget.position;
    currPosition = widget.position ?? 0;
    _filterPostAttachments();

    super.initState();
  }

  @override
  void didUpdateWidget(LMFeedMediaPreviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    position = widget.position;
    currPosition = widget.position ?? 0;
  }

  _filterPostAttachments() {
    postAttachments.removeWhere((element) =>
        !(element.attachmentType == LMMediaType.image ||
            element.attachmentType == LMMediaType.video));
    mediaLength = postAttachments.length;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    final String formattedTimeStamp = formatter.format(post.createdAt);
    return _widgetBuilder.scaffold(
      source: LMFeedWidgetSource.mediaPreviewScreen,
      backgroundColor: Colors.black,
      appBar: _widgetBuilder.appBarBuilder(
        context,
        _defAppBar(context, formattedTimeStamp),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CarouselSlider.builder(
                          carouselController: controller,
                          options: CarouselOptions(
                              initialPage: position ?? 0,
                              enableInfiniteScroll: false,
                              enlargeFactor: 0.0,
                              viewportFraction: 1.0,
                              aspectRatio: 9 / 16,
                              onPageChanged: (index, reason) {
                                currPosition = index;
                                rebuildCurr.value = !rebuildCurr.value;
                              }),
                          itemCount: postAttachments.length,
                          itemBuilder: (context, index, realIndex) {
                            if (postAttachments[index].attachmentType ==
                                LMMediaType.video) {
                              return LMFeedVideo(
                                video: postAttachments[index],
                                postId: widget.post.id,
                                autoPlay: true,
                                style: LMFeedPostVideoStyle.basic().copyWith(
                                  showControls: true,
                                ),
                                position: index,
                              );
                            } else if (postAttachments[index].attachmentType ==
                                LMMediaType.image) {
                              return Container(
                                color: Colors.black,
                                width: screenSize.width,
                                child: LMFeedImage(
                                  image: postAttachments[index],
                                  style: LMFeedPostImageStyle(
                                    boxFit: BoxFit.contain,
                                    width: screenSize.width,
                                  ),
                                  position: index,
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                      if (mediaLength > 1 && kIsWeb)
                        ValueListenableBuilder(
                          valueListenable: rebuildCurr,
                          builder: (context, _, __) {
                            return Positioned(
                              bottom: 0,
                              top: 0,
                              child: SizedBox(
                                width: screenSize.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    currPosition > 0
                                        ? InkWell(
                                            onTap: () {
                                              if (currPosition > 0) {
                                                currPosition--;
                                                controller.animateToPage(
                                                    currPosition);
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: screenSize.width * 0.25,
                                              alignment: Alignment.centerLeft,
                                              child: Icon(
                                                Icons
                                                    .arrow_back_ios_new_rounded,
                                                color: feedTheme.container
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    currPosition != mediaLength - 1
                                        ? InkWell(
                                            onTap: () {
                                              if (currPosition <
                                                  mediaLength - 1) {
                                                currPosition++;
                                                controller.animateToPage(
                                                    currPosition);
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: screenSize.width * 0.25,
                                              alignment: Alignment.centerRight,
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
                if (mediaLength > 1)
                  ValueListenableBuilder(
                    valueListenable: rebuildCurr,
                    builder: (context, _, __) {
                      return _widgetBuilder.postMediaCarouselIndicatorBuilder(
                          context,
                          currPosition,
                          postAttachments.length,
                          carouselIndexIndicatorWidget());
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar(BuildContext context, String formatted) {
    return LMFeedAppBar(
      leading: LMFeedButton(
        onTap: () {
          Navigator.of(context).pop();
        },
        style: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: CupertinoIcons.xmark,
            style: LMFeedIconStyle(
              color: feedTheme.container,
              size: 24,
              boxPadding: 12,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LMFeedText(
            text: user.name,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: feedTheme.container,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: rebuildCurr,
            builder: (context, value, child) {
              return LMFeedText(
                text:
                    '${currPosition + 1} of ${postAttachments.length} media • $formatted',
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: feedTheme.container,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget carouselIndexIndicatorWidget() {
    return Column(
      children: [
        LikeMindsTheme.kVerticalPaddingMedium,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: postAttachments.map((url) {
              int index = postAttachments.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 7.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currPosition == index
                      ? feedTheme.primaryColor
                      : feedTheme.container,
                ),
              );
            }).toList())
      ],
    );
  }
}
