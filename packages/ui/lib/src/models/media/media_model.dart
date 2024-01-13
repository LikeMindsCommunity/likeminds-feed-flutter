import 'dart:io';

import 'package:likeminds_feed_flutter_ui/src/models/models.dart';

enum LMMediaType { video, image, document, link, widget }

class LMMediaModel {
  // defines the type of media
  LMMediaType mediaType;
  // one of mediaFile or link must be provided
  File? mediaFile; // Photo Video or Document File
  String? link; // Photo Video, Document or Link Preview URL
  int? duration; // required for video url
  String? format; // required for documents
  int? size; // required for documents
  LMOgTagsViewData? ogTags; // required for links (attachment type 4)
  Map<String, dynamic>? widgetsMeta; //required for widgets (attachment type 5)

  LMMediaModel({
    required this.mediaType,
    this.mediaFile,
    this.link,
    this.duration,
    this.format,
    this.size,
    this.ogTags,
    this.widgetsMeta,
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
    } else if (mediaType == LMMediaType.widget) {
      return 5;
    } else {
      throw 'no valid media type provided';
    }
  }
}

LMMediaType mapIntToMediaType(int attachmentType) {
  if (attachmentType == 1) {
    return LMMediaType.image;
  } else if (attachmentType == 2) {
    return LMMediaType.video;
  } else if (attachmentType == 3) {
    return LMMediaType.document;
  } else if (attachmentType == 4) {
    return LMMediaType.link;
  } else if (attachmentType == 5) {
    return LMMediaType.widget;
  } else {
    throw 'no valid media type provided';
  }
}
