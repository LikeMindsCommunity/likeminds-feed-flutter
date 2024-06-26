import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_mobile.dart'
    if (dart.library.html) 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_web.dart'
    if (dart.library.io) 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils_mobile.dart';

abstract class LMFeedPlatform {
  bool isAndroid();

  bool isIOS();

  bool isWeb();

  bool isMobile();

  bool isMacOS();

  static LMFeedPlatform? _instance;

  static LMFeedPlatform get instance => _instance ??= getLMFeedPlatform();
}
