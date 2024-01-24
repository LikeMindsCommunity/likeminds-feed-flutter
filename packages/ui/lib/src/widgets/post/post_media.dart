import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';

class LMFeedPostMedia extends StatefulWidget {
  const LMFeedPostMedia({
    super.key,
    required this.attachments,
    this.title,
    this.subtitle,
    this.initialiseVideoController,
    this.onError,
    this.style,
    this.onMediaTap,
  });

  final List<LMAttachmentViewData> attachments;
  final Function(VideoController)? initialiseVideoController;

  final LMFeedText? title;
  final LMFeedText? subtitle;

  final Function(String, StackTrace)? onError;

  final VoidCallback? onMediaTap;

  final LMFeedPostMediaStyle? style;

  @override
  State<LMFeedPostMedia> createState() => _LMPostMediaState();

  LMFeedPostMedia copyWith({
    List<LMAttachmentViewData>? attachments,
    LMFeedText? title,
    LMFeedText? subtitle,
    Function(VideoController)? initialiseVideoController,
    Function(String, StackTrace)? onError,
    LMFeedPostMediaStyle? style,
  }) {
    return LMFeedPostMedia(
      attachments: attachments ?? this.attachments,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      initialiseVideoController:
          initialiseVideoController ?? this.initialiseVideoController,
      onError: onError ?? this.onError,
      style: style ?? this.style,
    );
  }
}

class _LMPostMediaState extends State<LMFeedPostMedia> {
  List<LMAttachmentViewData>? attachments;
  late Size screenSize;
  LMFeedPostMediaStyle? style;

  void initialiseAttachments() {
    attachments = [...widget.attachments];
    attachments?.removeWhere((element) => element.attachmentType == 5);
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
    style = widget.style ?? LMFeedTheme.of(context).mediaStyle;
    if (attachments == null || attachments!.isEmpty) {
      return const SizedBox();
    }
    // attachments = InheritedPostProvider.of(context)?.post.attachments ?? [];
    if (attachments!.first.attachmentType == 3) {
      /// If the attachment is a document,
      /// we need to call the method 'getDocumentList'
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: getPostDocuments(),
      );
    } else if (attachments!.first.attachmentType == 4) {
      return LMFeedPostLinkPreview(
        attachment: attachments![0],
        title: widget.title,
        subtitle: widget.subtitle,
        onError: widget.onError,
        style: widget.style?.linkStyle,
      );
    } else if (attachments!.first.attachmentType == 1 ||
        attachments!.first.attachmentType == 2) {
      return GestureDetector(
        onTap: widget.onMediaTap,
        child: LMFeedCarousel(
          initialiseVideoController: widget.initialiseVideoController,
          attachments: attachments!,
          onError: widget.onError,
          imageStyle: widget.style?.imageStyle,
          videoStyle: widget.style?.videoStyle,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
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

  const LMFeedPostMediaStyle({
    required this.videoStyle,
    required this.imageStyle,
    required this.documentStyle,
    required this.linkStyle,
    required this.carouselStyle,
  });

  LMFeedPostMediaStyle copyWith({
    LMFeedPostVideoStyle? videoStyle,
    LMFeedPostImageStyle? imageStyle,
    LMFeedPostDocumentStyle? documentStyle,
    LMFeedPostLinkPreviewStyle? linkStyle,
    LMFeedPostCarouselStyle? carouselStyle,
  }) {
    return LMFeedPostMediaStyle(
      videoStyle: videoStyle ?? this.videoStyle,
      imageStyle: imageStyle ?? this.imageStyle,
      documentStyle: documentStyle ?? this.documentStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      carouselStyle: carouselStyle ?? this.carouselStyle,
    );
  }

  factory LMFeedPostMediaStyle.basic() => LMFeedPostMediaStyle(
        carouselStyle: const LMFeedPostCarouselStyle(),
        documentStyle: const LMFeedPostDocumentStyle(),
        imageStyle: const LMFeedPostImageStyle(),
        linkStyle: LMFeedPostLinkPreviewStyle.basic(),
        videoStyle: const LMFeedPostVideoStyle(),
      );
}
