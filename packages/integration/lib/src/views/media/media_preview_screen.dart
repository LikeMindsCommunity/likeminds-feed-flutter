import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
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
  late List<LMAttachmentViewData> postAttachments;
  late LMPostViewData post;
  late LMUserViewData user;
  late int? position;

  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  bool checkIfMultipleAttachments() {
    return (postAttachments.length > 1);
  }

  @override
  void initState() {
    postAttachments = widget.postAttachments;
    post = widget.post;
    user = widget.user;
    position = widget.position;
    _filterPostAttachments();
    super.initState();
  }

  _filterPostAttachments() {
    postAttachments.removeWhere((element) =>
        !(element.attachmentType == 1 || element.attachmentType == 2));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM d, hh:mm');
    final String formatted = formatter.format(post.createdAt);
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
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
                size: 28,
                boxSize: 64,
                boxPadding: 12,
              ),
            ),
          ),
        ),
        elevation: 0,
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
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                      initialPage: position ?? 0,
                      aspectRatio: 9 / 16,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
                        rebuildCurr.value = !rebuildCurr.value;
                      }),
                  itemCount: postAttachments.length,
                  itemBuilder: (context, index, realIndex) {
                    if (postAttachments[index].attachmentType == 2) {
                      return LMFeedPostVideo(
                        videoUrl: postAttachments[index].attachmentMeta.url,
                        style: LMFeedPostVideoStyle.basic().copyWith(
                          showControls: true,
                        ),
                      );
                    } else if (postAttachments[index].attachmentType == 1) {
                      return Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: ExtendedImage.network(
                            postAttachments[index].attachmentMeta.url!,
                            fit: BoxFit.contain,
                            mode: ExtendedImageMode.gesture,
                            initGestureConfigHandler: (state) {
                              return GestureConfig(
                                hitTestBehavior: HitTestBehavior.opaque,
                                minScale: 0.9,
                                animationMinScale: 0.7,
                                maxScale: 3.0,
                                animationMaxScale: 3.5,
                                inPageView: true,
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
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
                            children: postAttachments.map((url) {
                              int index = postAttachments.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 7.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currPosition == index
                                      ? feedTheme.primaryColor
                                      : feedTheme.container,
                                ),
                              );
                            }).toList())
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
