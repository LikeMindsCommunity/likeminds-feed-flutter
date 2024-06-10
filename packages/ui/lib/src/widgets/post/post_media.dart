import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';

class LMFeedPostMedia extends StatefulWidget {
  const LMFeedPostMedia({
    super.key,
    required this.postId,
    required this.attachments,
    this.title,
    this.subtitle,
    this.onError,
    this.style,
    this.onMediaTap,
    this.carouselIndicatorBuilder,
    this.videoBuilder,
    this.imageBuilder,
    this.pollBuilder,
    this.poll,
  });

  final List<LMAttachmentViewData> attachments;
  final String postId;

  final LMFeedText? title;
  final LMFeedText? subtitle;

  final Function(String, StackTrace)? onError;

  final Function(int)? onMediaTap;

  final LMFeedPostMediaStyle? style;
  final LMFeedCarouselIndicatorBuilder? carouselIndicatorBuilder;

  final LMFeedVideoBuilder? videoBuilder;
  final LMFeedImageBuilder? imageBuilder;
  final LMFeedPollBuilder? pollBuilder;

  final LMFeedPoll? poll;

  @override
  State<LMFeedPostMedia> createState() => _LMPostMediaState();

  LMFeedPostMedia copyWith({
    List<LMAttachmentViewData>? attachments,
    String? postId,
    LMFeedText? title,
    LMFeedText? subtitle,
    Function(VideoController)? initialiseVideoController,
    Function(String, StackTrace)? onError,
    LMFeedPostMediaStyle? style,
    Widget Function(BuildContext, int, int, Widget)? carouselIndicatorBuilder,
    Function(int)? onMediaTap,
    LMFeedVideoBuilder? videoBuilder,
    LMFeedImageBuilder? imageBuilder,
    LMFeedPollBuilder? pollBuilder,
    LMFeedPoll? poll,
  }) {
    return LMFeedPostMedia(
      attachments: attachments ?? this.attachments,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      onError: onError ?? this.onError,
      style: style ?? this.style,
      carouselIndicatorBuilder:
          carouselIndicatorBuilder ?? this.carouselIndicatorBuilder,
      onMediaTap: onMediaTap ?? this.onMediaTap,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      videoBuilder: videoBuilder ?? this.videoBuilder,
      pollBuilder: pollBuilder ?? this.pollBuilder,
      poll: poll ?? this.poll,
    );
  }
}

class _LMPostMediaState extends State<LMFeedPostMedia> {
  List<LMAttachmentViewData>? attachments;
  late Size screenSize;
  LMFeedPostMediaStyle? style;

  void initialiseAttachments() {
    attachments = [...widget.attachments];
    attachments?.removeWhere((element) =>
        (element.attachmentType == LMMediaType.widget ||
            element.attachmentType == LMMediaType.repost));
  }

  @override
  void initState() {
    super.initState();
    initialiseAttachments();
  }

  @override
  void didUpdateWidget(LMFeedPostMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    initialiseAttachments();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    style = widget.style ?? LMFeedTheme.instance.theme.mediaStyle;
    if (attachments == null || attachments!.isEmpty) {
      return const SizedBox();
    }

    /// if attachment is a poll
    if (attachments!.first.attachmentType == LMMediaType.poll) {
      Widget poll = widget.pollBuilder?.call(
            context,
            _defPoll(),
          ) ??
          _defPoll();
      return poll;
    }
    if (attachments!.first.attachmentType == LMMediaType.document) {
      /// If the attachment is a document,
      /// we need to call the method 'getDocumentList'
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: getPostDocuments(),
      );
    } else if (attachments!.first.attachmentType == LMMediaType.link) {
      return LMFeedLinkPreview(
        attachment: attachments![0],
        title: widget.title,
        subtitle: widget.subtitle,
        onError: widget.onError,
        style: widget.style?.linkStyle,
      );
    } else if (attachments!.first.attachmentType == LMMediaType.image ||
        attachments!.first.attachmentType == LMMediaType.video) {
      return LMFeedCarousel(
        postId: widget.postId,
        attachments: attachments!,
        onError: widget.onError,
        imageStyle: widget.style?.imageStyle,
        videoStyle: widget.style?.videoStyle,
        onMediaTap: widget.onMediaTap,
        carouselIndicatorBuilder: widget.carouselIndicatorBuilder,
        imageBuilder: widget.imageBuilder,
        videoBuilder: widget.videoBuilder,
        style: widget.style?.carouselStyle,
      );
    } else if (attachments!.first.attachmentType == LMMediaType.repost) {
      final repostData = attachments!.first.attachmentMeta.repost!;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: repostData.isDeleted ?? false
            ? Container(
                decoration: BoxDecoration(
                  color:
                      LMFeedTheme.instance.theme.onContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 120,
                width: double.infinity,
                child: const Center(
                  child: LMFeedText(
                    text: "This post was deleted",
                  ),
                ),
              )
            : LMFeedPostWidget(
                post: repostData,
                user: repostData.user,
                isFeed: true,
                topics: repostData.topics,
                footerBuilder: (context, footer, footerData) =>
                    const SizedBox.shrink(),
                headerBuilder: (context, header, headerData) {
                  return header.copyWith(menuBuilder: (_) {
                    return const SizedBox.shrink();
                  });
                },
                style: LMFeedTheme.instance.theme.postStyle.copyWith(
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.all(8),
                    border: Border.all(
                      color: LMFeedTheme.instance.theme.onContainer
                          .withOpacity(0.1),
                    )),
                onPostTap: (context, postData) {},
              ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  LMFeedPoll _defPoll() {
    return widget.poll ??
        LMFeedPoll(
            attachmentMeta: attachments!.first.attachmentMeta,
            style: widget.style?.pollStyle ?? LMFeedPollStyle.basic());
  }

  Widget getPostDocuments() {
    List<Widget> documents;
    bool isCollapsed = true;

    documents = attachments!
        .map(
          (e) => LMFeedDocument(
            // document: e,
            size: PostHelper.getFileSizeString(bytes: e.attachmentMeta.size!),
            documentUrl: e.attachmentMeta.url,

            type: e.attachmentMeta.format!,
            style: widget.style?.documentStyle,
            onTap: () {
              Uri fileUrl = Uri.parse(e.attachmentMeta.url!);
              launchUrl(fileUrl, mode: LaunchMode.externalApplication);
            },
          ),
        )
        .toList();

    return Align(
      child: SizedBox(
        width: screenSize.width - 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: documents.length > 3 && isCollapsed
                  ? documents.sublist(0, 3)
                  : documents,
            ),
            documents.length > 3 && isCollapsed
                ? GestureDetector(
                    onTap: () => setState(() {
                      isCollapsed = false;
                    }),
                    child: LMFeedText(
                      text: '+ ${documents.length - 3} more',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          color: widget.style?.documentStyle.textColor ??
                              style?.documentStyle.textColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class LMFeedPostMediaStyle {
  final LMFeedPostVideoStyle videoStyle;
  final LMFeedPostImageStyle imageStyle;
  final LMFeedPostDocumentStyle documentStyle;
  final LMFeedPostLinkPreviewStyle linkStyle;
  final LMFeedPostCarouselStyle carouselStyle;
  final LMFeedPollStyle? pollStyle;

  const LMFeedPostMediaStyle({
    required this.videoStyle,
    required this.imageStyle,
    required this.documentStyle,
    required this.linkStyle,
    required this.carouselStyle,
    this.pollStyle,
  });

  LMFeedPostMediaStyle copyWith({
    LMFeedPostVideoStyle? videoStyle,
    LMFeedPostImageStyle? imageStyle,
    LMFeedPostDocumentStyle? documentStyle,
    LMFeedPostLinkPreviewStyle? linkStyle,
    LMFeedPostCarouselStyle? carouselStyle,
    LMFeedPollStyle? pollStyle,
  }) {
    return LMFeedPostMediaStyle(
      videoStyle: videoStyle ?? this.videoStyle,
      imageStyle: imageStyle ?? this.imageStyle,
      documentStyle: documentStyle ?? this.documentStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      carouselStyle: carouselStyle ?? this.carouselStyle,
      pollStyle: pollStyle ?? this.pollStyle,
    );
  }

  factory LMFeedPostMediaStyle.basic(
          {Color? primaryColor, Color? containerColor, Color? inActiveColor}) =>
      LMFeedPostMediaStyle(
        carouselStyle: const LMFeedPostCarouselStyle(),
        documentStyle: const LMFeedPostDocumentStyle(),
        imageStyle: const LMFeedPostImageStyle(),
        linkStyle: LMFeedPostLinkPreviewStyle.basic(),
        videoStyle: const LMFeedPostVideoStyle(),
        pollStyle: LMFeedPollStyle.basic(
            primaryColor: primaryColor,
            containerColor: containerColor,
            inActiveColor: inActiveColor),
      );
}
