import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_mobile.dart'
    if (dart.library.html) 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_web.dart'
    if (dart.library.io) 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_mobile.dart';

/// An abstract class that defines platform-specific utilities for the LMFeed.
abstract class LMFeedPlatform {
  /// Returns `true` if the platform is Android.
  bool isAndroid();

  /// Returns `true` if the platform is iOS.
  bool isIOS();

  /// Returns `true` if the platform is Web.
  bool isWeb();

  /// Returns `true` if the platform is Mobile (either Android or iOS).
  bool isMobile();

  /// Returns `true` if the platform is macOS.
  bool isMacOS();

  /// Gets the dimensions of an image from the given [path] or [bytes].
  ///
  /// Returns a [Future] that completes with a map containing the width and height of the image.
  Future<({int width, int height})?> getImageDimensions({
    String? path,
    Uint8List? bytes,
  });

  static LMFeedPlatform? _instance;

  /// Gets the singleton instance of [LMFeedPlatform].
  static LMFeedPlatform get instance => _instance ??= getLMFeedPlatform();
}
