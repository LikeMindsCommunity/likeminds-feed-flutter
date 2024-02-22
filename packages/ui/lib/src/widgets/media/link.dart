import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/*
* Topic chip widget
* This widget is used to display link preview
* A [LMFeedLinkPreview] displays link heading, description and URL
* The [LMFeedLinkPreview] can be customized 
* by passing in the required parameters
*/
class LMFeedLinkPreview extends StatelessWidget {
  const LMFeedLinkPreview({
    super.key,
    this.attachment,
    this.linkModel,
    this.onTap,
    this.title,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.onError,
    this.style,
  });

  // data class to provide link preview data
  final LMMediaModel? linkModel;
  final LMAttachmentViewData? attachment;

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
  /// {@macro feed_error_handler}
  final LMFeedErrorHandler? onError;

  final LMFeedPostLinkPreviewStyle? style;

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
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    final LMFeedPostLinkPreviewStyle style =
        this.style ?? feedTheme.mediaStyle.linkStyle;
    return GestureDetector(
      onTap: () {
        onTap?.call();
        String uri = linkModel?.link ??
            linkModel?.ogTags!.url ??
            attachment?.attachmentMeta.ogTags?.url ??
            '';
        launchUrl(Uri.parse(uri));
      },
      child: Container(
        margin: style.margin,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: feedTheme.container,
          border: style.border ??
              Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
          borderRadius: style.borderRadius ?? BorderRadius.circular(8.0),
        ),
        height: style.height ?? 344,
        width: style.width ?? MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            checkNullMedia()
                ? style.errorWidget ??
                    SizedBox(
                      height: style.imageHeight ?? 216,
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    )
                : LMFeedImage(
                    style: LMFeedPostImageStyle(
                      height: style.imageHeight ?? 216,
                      errorWidget: style.errorWidget,
                    ),
                    onError: onError,
                    imageUrl: imageUrl ??
                        (linkModel != null
                            ? linkModel!.ogTags!.image!
                            : attachment!.attachmentMeta.ogTags!.image!),
                  ),
            const Spacer(),
            Container(
              color: style.backgroundColor,
              padding: style.padding ?? const EdgeInsets.all(8.0),
              child: SizedBox(
                width: style.width ?? MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: style.width ?? MediaQuery.of(context).size.width,
                      child: title ??
                          LMFeedText(
                            text: linkModel != null
                                ? linkModel!.ogTags!.title!
                                : attachment!.attachmentMeta.ogTags!.title ??
                                    '- -',
                            style: style.titleStyle ??
                                const LMFeedTextStyle(
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
                      width: style.width ?? MediaQuery.of(context).size.width,
                      child: subtitle ??
                          LMFeedText(
                            text: linkModel != null
                                ? linkModel!.ogTags!.description!
                                : attachment!
                                        .attachmentMeta.ogTags!.description ??
                                    '-- --',
                            style: style.subtitleStyle ??
                                LMFeedTextStyle(
                                  maxLines: 2,
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade300,
                                    fontSize: LikeMindsTheme.kFontSmall,
                                  ),
                                ),
                          ),
                    ),
                    LikeMindsTheme.kVerticalPaddingMedium,
                    style.showLinkUrl
                        ? SizedBox(
                            width: style.width ??
                                MediaQuery.of(context).size.width,
                            child: LMFeedText(
                              text: linkModel != null
                                  ? linkModel!.link ?? linkModel!.ogTags!.url!
                                  : attachment!.attachmentMeta.ogTags!.url !=
                                          null
                                      ? attachment!.attachmentMeta.ogTags!.url!
                                          .toLowerCase()
                                      : 'NOT PRODUCING',
                              style: style.linkStyle ??
                                  LMFeedTextStyle(
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
    LMFeedPostLinkPreviewStyle? style,
  }) {
    return LMFeedLinkPreview(
      linkModel: linkModel ?? this.linkModel,
      attachment: attachment ?? this.attachment,
      onTap: onTap ?? this.onTap,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      onError: onError ?? this.onError,
      style: style ?? this.style,
    );
  }
}

class LMFeedPostLinkPreviewStyle {
// defaults to width of screen
  final double? width;

  // defaults to null
  final double? height;

  final double? imageHeight;

  // defaults to null
  final Color? backgroundColor;

  // defaults to 8.0
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showLinkUrl;
  final Border? border;
  final Widget? errorWidget;

  final LMFeedTextStyle? titleStyle;
  final LMFeedTextStyle? subtitleStyle;
  final LMFeedTextStyle? linkStyle;

  const LMFeedPostLinkPreviewStyle({
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.showLinkUrl = false,
    this.border,
    this.errorWidget,
    this.titleStyle,
    this.subtitleStyle,
    this.linkStyle,
    this.margin,
    this.imageHeight,
  });

  LMFeedPostLinkPreviewStyle copyWith({
    double? width,
    double? height,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    bool? showLinkUrl,
    Border? border,
    Widget? errorWidget,
    LMFeedTextStyle? titleStyle,
    LMFeedTextStyle? subtitleStyle,
    LMFeedTextStyle? linkStyle,
    EdgeInsets? margin,
    double? imageHeight,
  }) {
    return LMFeedPostLinkPreviewStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      showLinkUrl: showLinkUrl ?? this.showLinkUrl,
      border: border ?? this.border,
      errorWidget: errorWidget ?? this.errorWidget,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      margin: margin ?? this.margin,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  factory LMFeedPostLinkPreviewStyle.basic() => LMFeedPostLinkPreviewStyle(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        height: 344,
        imageHeight: 216,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        showLinkUrl: true,
        titleStyle: const LMFeedTextStyle(
          textStyle: TextStyle(
            color: LikeMindsTheme.headingColor,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitleStyle: const LMFeedTextStyle(
          maxLines: 2,
          textStyle: TextStyle(
            color: LikeMindsTheme.greyColor,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        linkStyle: const LMFeedTextStyle(
          maxLines: 1,
          textStyle: TextStyle(
            color: LikeMindsTheme.greyColor,
            fontSize: 12,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}
