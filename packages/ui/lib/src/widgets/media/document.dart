import 'dart:io';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class LMFeedDocument extends StatefulWidget {
  const LMFeedDocument({
    super.key,
    this.onTap,
    this.documentFile,
    this.documentUrl,
    this.type = 'pdf',
    this.size,
    this.title,
    this.subtitle,
    this.onRemove,
    this.style,
  }) : assert(documentFile != null || documentUrl != null);

  final Function()? onTap;

  final File? documentFile;
  final String? documentUrl;
  final String? type;
  final String? size;

  final LMFeedText? title;
  final LMFeedText? subtitle;

  final Function? onRemove;

  final LMFeedPostDocumentStyle? style;

  @override
  State<LMFeedDocument> createState() => _LMDocumentState();

  LMFeedDocument copyWith({
    Function()? onTap,
    File? documentFile,
    String? documentUrl,
    String? type,
    String? size,
    LMFeedText? title,
    LMFeedText? subtitle,
    Function? onRemove,
    LMFeedPostDocumentStyle? style,
  }) {
    return LMFeedDocument(
      onTap: onTap ?? this.onTap,
      documentFile: documentFile ?? this.documentFile,
      documentUrl: documentUrl ?? this.documentUrl,
      type: type ?? this.type,
      size: size ?? this.size,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      onRemove: onRemove ?? this.onRemove,
      style: style ?? this.style,
    );
  }
}

class _LMDocumentState extends State<LMFeedDocument> {
  String? _fileName;
  String? _fileExtension;
  String? _fileSize;
  String? url;
  File? file;
  Future<File>? fileLoaderFuture;
  LMFeedPostDocumentStyle? style;

  Future<File> loadFile() async {
    File file;
    if (widget.documentUrl != null) {
      final String url = widget.documentUrl!;
      file = File(url);
    } else {
      file = widget.documentFile!;
    }
    _fileExtension = widget.type;
    _fileSize = widget.size;
    _fileName = basenameWithoutExtension(file.path);
    return file;
  }

  @override
  void initState() {
    super.initState();
    fileLoaderFuture = loadFile();
  }

  @override
  Widget build(BuildContext context) {
    style = widget.style ?? LMFeedTheme.of(context).mediaStyle.documentStyle;
    Size screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: fileLoaderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return GestureDetector(
              onTap: widget.onTap == null ? null : () => widget.onTap!(),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: LikeMindsTheme.kPaddingSmall,
                ),
                width: style?.width ?? screenSize.width - 40,
                height: 72, //style!.height ?? 72,
                decoration: BoxDecoration(
                  color: style!.backgroundColor,
                  border: style!.showBorder
                      ? Border.all(
                          color: style!.borderColor ?? Colors.grey,
                          width: style!.borderSize ?? 1,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                    style!.borderRadius ?? LikeMindsTheme.kBorderRadiusMedium,
                  ),
                ),
                padding: const EdgeInsets.all(LikeMindsTheme.kPaddingLarge),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: style!.documentIcon ??
                          const LMFeedIcon(
                            type: LMFeedIconType.icon,
                            icon: Icons.picture_as_pdf,
                            style: LMFeedIconStyle(
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                    ),
                    LikeMindsTheme.kHorizontalPaddingLarge,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.title ??
                              LMFeedText(
                                text: _fileName ?? '',
                                style: widget.style?.titleStyle ??
                                    LMFeedTextStyle(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: style!.textColor ?? Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              ),
                          LikeMindsTheme.kVerticalPaddingSmall,
                          widget.subtitle ??
                              Row(
                                children: [
                                  LikeMindsTheme.kHorizontalPaddingXSmall,
                                  LMFeedText(
                                      text: _fileSize?.toUpperCase() ?? '--',
                                      style: LMFeedTextStyle(
                                        textStyle: TextStyle(
                                          fontSize: LikeMindsTheme.kFontSmall,
                                          color: style!.textColor ??
                                              Colors.grey.shade300,
                                        ),
                                      )),
                                  LikeMindsTheme.kHorizontalPaddingXSmall,
                                  LMFeedText(
                                    text: '·',
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: style!.textColor ??
                                            Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  LikeMindsTheme.kHorizontalPaddingXSmall,
                                  LMFeedText(
                                    text: _fileExtension!.toUpperCase(),
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: style!.textColor ??
                                            Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    widget.documentFile != null
                        ? LMFeedButton(
                            style: LMFeedButtonStyle(
                              icon: style!.removeIcon ??
                                  const LMFeedIcon(
                                      type: LMFeedIconType.icon,
                                      icon: Icons.close),
                            ),
                            onTap: () {
                              if (widget.onRemove != null) {
                                widget.onRemove!();
                              }
                            },
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const LMFeedDocumentShimmer();
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}

class LMFeedPostDocumentStyle {
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderSize;
  final Color? borderColor;
  final Color? textColor;
  final Widget? documentIcon;
  final LMFeedIcon? removeIcon;
  final bool showBorder;
  final Color? backgroundColor;
  final LMFeedTextStyle? titleStyle;
  final LMFeedTextStyle? subtitleStyle;

  const LMFeedPostDocumentStyle({
    this.height,
    this.width,
    this.borderRadius,
    this.borderSize,
    this.borderColor,
    this.textColor,
    this.documentIcon,
    this.removeIcon,
    this.showBorder = true,
    this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  LMFeedPostDocumentStyle copyWith({
    double? height,
    double? width,
    double? borderRadius,
    double? borderSize,
    Color? borderColor,
    Color? textColor,
    Widget? documentIcon,
    LMFeedIcon? removeIcon,
    bool? showBorder,
    Color? backgroundColor,
    LMFeedTextStyle? titleStyle,
    LMFeedTextStyle? subtitleStyle,
  }) {
    return LMFeedPostDocumentStyle(
      height: height ?? this.height,
      width: width ?? this.width,
      borderRadius: borderRadius ?? this.borderRadius,
      borderSize: borderSize ?? this.borderSize,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      documentIcon: documentIcon ?? this.documentIcon,
      removeIcon: removeIcon ?? this.removeIcon,
      showBorder: showBorder ?? this.showBorder,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    );
  }

  factory LMFeedPostDocumentStyle.basic({Color? primaryColor}) =>
      LMFeedPostDocumentStyle(
        height: 72,
        width: double.infinity,
        borderRadius: LikeMindsTheme.kBorderRadiusMedium,
        borderSize: 1,
        borderColor: primaryColor ?? Colors.grey.shade300,
        textColor: primaryColor ?? Colors.grey.shade300,
        documentIcon: const LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.picture_as_pdf,
          style: LMFeedIconStyle(
            size: 24,
            color: Colors.red,
          ),
        ),
        removeIcon: const LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.close,
        ),
        backgroundColor: Colors.white,
        titleStyle: const LMFeedTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}
