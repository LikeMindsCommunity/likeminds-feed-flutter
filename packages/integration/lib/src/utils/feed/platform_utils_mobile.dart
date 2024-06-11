import 'dart:io';

import 'package:flutter/foundation.dart';
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
}

LMFeedPlatform getLMFeedPlatform() => LMFeedPlatformMobile();
