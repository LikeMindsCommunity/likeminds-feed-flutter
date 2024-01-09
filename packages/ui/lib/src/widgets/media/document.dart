import 'dart:io';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class LMDocument extends StatefulWidget {
  const LMDocument({
    super.key,
    this.onTap,
    this.documentFile,
    this.documentUrl,
    this.height,
    this.width,
    this.type,
    this.size,
    this.borderRadius,
    this.borderSize,
    this.borderColor,
    this.title,
    this.subtitle,
    this.documentIcon,
    this.onRemove,
    this.removeIcon,
    this.showBorder = true,
    this.backgroundColor,
    this.textColor,
  }) : assert(documentFile != null || documentUrl != null);

  final Function()? onTap;

  final File? documentFile;
  final String? documentUrl;
  final String? type;
  final String? size;

  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderSize;
  final Color? borderColor;
  final Color? textColor;

  final LMFeedText? title;
  final LMFeedText? subtitle;
  final Widget? documentIcon;
  final LMFeedIcon? removeIcon;
  final Function? onRemove;
  final bool showBorder;
  final Color? backgroundColor;

  @override
  State<LMDocument> createState() => _LMDocumentState();
}

class _LMDocumentState extends State<LMDocument> {
  String? _fileName;
  String? _fileExtension;
  String? _fileSize;
  String? url;
  File? file;
  Future<File>? fileLoaderFuture;

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
    return FutureBuilder(
        future: fileLoaderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return GestureDetector(
              onTap: widget.onTap == null ? null : () => widget.onTap!(),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: kPaddingSmall,
                ),
                height: widget.height ?? 78,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  border: widget.showBorder
                      ? Border.all(
                          color: widget.borderColor ?? Colors.grey,
                          width: widget.borderSize ?? 1,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? kBorderRadiusMedium,
                  ),
                ),
                padding: const EdgeInsets.all(kPaddingLarge),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: widget.documentIcon ??
                          const LMFeedIcon(
                            type: LMIconType.icon,
                            icon: Icons.picture_as_pdf,
                            style: LMFeedIconStyle(
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                    ),
                    kHorizontalPaddingLarge,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.title ??
                              LMFeedText(
                                text: _fileName ?? '',
                                style: LMFeedTextStyle(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: widget.textColor ?? Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          kVerticalPaddingSmall,
                          widget.subtitle ??
                              Row(
                                children: [
                                  kHorizontalPaddingXSmall,
                                  Text(
                                    _fileSize!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: kFontSmall,
                                      color: widget.textColor ??
                                          Colors.grey.shade300,
                                    ),
                                  ),
                                  kHorizontalPaddingXSmall,
                                  Text(
                                    '·',
                                    style: TextStyle(
                                      fontSize: kFontSmall,
                                      color: widget.textColor ??
                                          Colors.grey.shade300,
                                    ),
                                  ),
                                  kHorizontalPaddingXSmall,
                                  Text(
                                    _fileExtension!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: kFontSmall,
                                      color: widget.textColor ??
                                          Colors.grey.shade300,
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
                            icon: widget.removeIcon ??
                                const LMFeedIcon(
                                    type: LMIconType.icon, icon: Icons.close),
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
            return const LMDocumentShimmer();
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
