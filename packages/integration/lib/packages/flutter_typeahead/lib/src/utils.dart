import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

final LMFeedPlatform _feedPlatform = LMFeedPlatform.instance;

final supportedPlatform = (_feedPlatform.isWeb() || _feedPlatform.isMobile());
