import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

class LMFeedPlatformWeb implements LMFeedPlatform {
  @override
  bool isAndroid() {
    return false;
  }

  @override
  bool isIOS() {
    return false;
  }

  @override
  bool isMacOS() {
    return false;
  }

  @override
  bool isMobile() {
    return false;
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
    if (bytes == null) return null;
    final Image image = Image(image: MemoryImage(bytes));
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

LMFeedPlatform getLMFeedPlatform() => LMFeedPlatformWeb();
