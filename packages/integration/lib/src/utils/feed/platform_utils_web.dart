import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

/// A web-specific implementation of the [LMFeedPlatform] interface.
class LMFeedPlatformWeb implements LMFeedPlatform {
  @override
  /// Returns `true` if the platform is Android.
  bool isAndroid() {
    return false;
  }

  @override
  /// Returns `true` if the platform is iOS.
  bool isIOS() {
    return false;
  }

  @override
  /// Returns `true` if the platform is macOS.
  bool isMacOS() {
    return false;
  }

  @override
  /// Returns `true` if the platform is Mobile (either Android or iOS).
  bool isMobile() {
    return false;
  }

  @override
  /// Returns `true` if the platform is Web.
  bool isWeb() {
    return kIsWeb;
  }

  @override
  /// Gets the dimensions of an image from the given [path] or [bytes].
  ///
  /// Returns a [Future] that completes with a map containing the width and height of the image.
  Future<({int width, int height})?> getImageDimensions({
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

    return (width: width, height: height);
  }
}

/// Returns an instance of [LMFeedPlatformWeb].
LMFeedPlatform getLMFeedPlatform() => LMFeedPlatformWeb();
