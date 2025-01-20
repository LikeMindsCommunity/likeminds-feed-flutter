import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

class LMFeedPlatformMobile implements LMFeedPlatform {
  @override
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid;
  }

  @override
  bool isIOS() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isIOS;
  }

  @override
  bool isMacOS() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isMacOS;
  }

  @override
  bool isMobile() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  bool isWeb() {
    return kIsWeb;
  }

  @override
  Future<(int width, int height)?> getImageSize({
    String? path,
    Uint8List? bytes,
  }) async {
    if (path == null) return null;
    final Image image = Image(image: FileImage(File(path)));
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image info = await completer.future;
    int width = info.width;
    int height = info.height;

    return (width, height);
  }
}

LMFeedPlatform getLMFeedPlatform() => LMFeedPlatformMobile();
