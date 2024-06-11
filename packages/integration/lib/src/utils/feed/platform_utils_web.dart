import 'package:flutter/foundation.dart';
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
}

LMFeedPlatform getLMFeedPlatform() => LMFeedPlatformWeb();
