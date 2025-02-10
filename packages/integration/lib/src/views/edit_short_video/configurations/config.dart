import 'builder.dart';
import 'settings.dart';
import 'style.dart';

// export all config
export 'builder.dart';
export 'settings.dart';
export 'style.dart';

class LMFeedEditShortVideoConfig {
  final LMFeedEditShortVideoSettings setting;
  final LMFeedEditShortVideoStyle style;
  final LMFeedEditShortVideoBuilderDelegate builder;

  const LMFeedEditShortVideoConfig({
    this.setting = const LMFeedEditShortVideoSettings(),
    this.style = const LMFeedEditShortVideoStyle(),
    this.builder = const LMFeedEditShortVideoBuilderDelegate(),
  });
}
