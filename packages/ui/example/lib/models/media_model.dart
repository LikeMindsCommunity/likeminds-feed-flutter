import 'dart:io';

import 'package:likeminds_feed/likeminds_feed.dart';

enum LMMediaType { video, image, document, link }

class LMMediaModel {
  // defines the type of media
  LMMediaType mediaType;
  // one of mediaFile or link must be provided
  File? mediaFile; // Photo Video or Document File
  String? link; // Photo Video, Document or Link Preview URL
  int? duration; // required for video url
  String? format; // required for documents
  int? size; // required for documents
  OgTags? ogTags; // required for links (attachment type 4)

  LMMediaModel({
    required this.mediaType,
    this.mediaFile,
    this.link,
    this.duration,
    this.format,
    this.size,
    this.ogTags,
  });

  // convert
  int mapMediaTypeToInt() {
    if (mediaType == LMMediaType.image) {
      return 1;
    } else if (mediaType == LMMediaType.video) {
      return 2;
    } else if (mediaType == LMMediaType.document) {
      return 3;
    } else if (mediaType == LMMediaType.link) {
      return 4;
    } else {
      throw 'no valid media type provided';
    }
  }
}
