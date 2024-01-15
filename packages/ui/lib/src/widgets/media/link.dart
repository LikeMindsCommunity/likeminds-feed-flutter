import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/theme.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

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
                                fontSize: LikeMindsTheme.kFontMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                    LikeMindsTheme.kVerticalPaddingSmall,
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
                                fontSize: LikeMindsTheme.kFontSmall,
                              ),
                            ),
                          ),
                    ),
                    LikeMindsTheme.kVerticalPaddingXSmall,
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
                                  fontSize: LikeMindsTheme.kFontXSmall,
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

  /// copyWith function to get a new object of [LMFeedLinkPreview]
  /// with specific single values passed
  LMFeedLinkPreview copyWith({
    LMMediaModel? linkModel,
    LMAttachmentViewData? attachment,
    double? width,
    double? height,
    Color? backgroundColor,
    double? borderRadius,
    double? padding,
    VoidCallback? onTap,
    LMFeedText? title,
    LMFeedText? subtitle,
    LMFeedText? url,
    String? imageUrl,
    bool? showLinkUrl,
    Border? border,
    Widget? errorWidget,
    Function(String, StackTrace)? onError,
  }) {
    return LMFeedLinkPreview(
      linkModel: linkModel ?? this.linkModel,
      attachment: attachment ?? this.attachment,
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      onTap: onTap ?? this.onTap,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      showLinkUrl: showLinkUrl ?? this.showLinkUrl,
      border: border ?? this.border,
      errorWidget: errorWidget ?? this.errorWidget,
      onError: onError ?? this.onError,
    );
  }
}
