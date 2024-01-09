import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';

/*
* Topic chip widget
* This widget is used to display link preview
* A [LMFeedLinkPreview] displays link heading, description and URL
* The [LMFeedLinkPreview] can be customized by passing in the required parameters
*/
class LMFeedLinkPreview extends StatelessWidget {
  const LMFeedLinkPreview({
    super.key,
    this.attachment,
    this.linkModel,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.title,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.showLinkUrl = false,
    this.border,
    this.errorWidget,
    this.onError,
  });

  // data class to provide link preview data
  final LMMediaModel? linkModel;
  final LMAttachmentViewData? attachment;

  // defaults to width of screen
  final double? width;

  // defaults to null
  final double? height;

  // defaults to null
  final Color? backgroundColor;

  // defaults to 8.0
  final double? borderRadius;
  final double? padding;
  final VoidCallback? onTap;

  // defaults to null,
  final String? imageUrl;

  // defaults to null, for custom styling
  final LMFeedText? title;

  // defaults to null, for custom styling
  final LMFeedText? subtitle;

  // defaults to null, for custom styling
  final LMFeedText? url;

  // defaults to false, to show link url
  final bool showLinkUrl;
  final Border? border;
  final Widget? errorWidget;
  final Function(String, StackTrace)? onError;

  bool checkNullMedia() {
    return ((linkModel == null ||
            linkModel!.ogTags == null ||
            linkModel!.ogTags!.image == null ||
            linkModel!.ogTags!.image!.isEmpty) &&
        (attachment == null ||
            attachment!.attachmentMeta.ogTags == null ||
            attachment!.attachmentMeta.ogTags!.image == null));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          border: border ??
              Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: height,
        width: width ?? MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            checkNullMedia()
                ? const SizedBox.shrink()
                : LMFeedImage(
                    width: width,
                    height: 150,
                    borderRadius: borderRadius,
                    errorWidget: errorWidget,
                    onError: onError,
                    imageUrl: imageUrl ??
                        (linkModel != null
                            ? linkModel!.ogTags!.image!
                            : attachment!.attachmentMeta.ogTags!.image!),
                  ),
            Container(
              height: height != null ? (height! - 152) : null,
              color: backgroundColor,
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: width ?? MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: width ?? MediaQuery.of(context).size.width,
                      child: title ??
                          LMFeedText(
                            text: linkModel != null
                                ? linkModel!.ogTags!.title!
                                : attachment!.attachmentMeta.ogTags!.title ??
                                    'NOT PRODUCING',
                            style: const LMFeedTextStyle(
                              textStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: kFontMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                    kVerticalPaddingSmall,
                    SizedBox(
                      width: width ?? MediaQuery.of(context).size.width,
                      child: subtitle ??
                          LMFeedText(
                            text: linkModel != null
                                ? linkModel!.ogTags!.description!
                                : attachment!
                                        .attachmentMeta.ogTags!.description ??
                                    'NOT PRODUCING',
                            style: LMFeedTextStyle(
                              maxLines: 2,
                              textStyle: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: kFontSmall,
                              ),
                            ),
                          ),
                    ),
                    kVerticalPaddingXSmall,
                    showLinkUrl
                        ? SizedBox(
                            width: width ?? MediaQuery.of(context).size.width,
                            child: LMFeedText(
                              text: linkModel != null
                                  ? linkModel!.link ?? linkModel!.ogTags!.url!
                                  : attachment!.attachmentMeta.ogTags!.url !=
                                          null
                                      ? attachment!.attachmentMeta.ogTags!.url!
                                          .toLowerCase()
                                      : 'NOT PRODUCING',
                              style: LMFeedTextStyle(
                                maxLines: 1,
                                textStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: kFontXSmall,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
