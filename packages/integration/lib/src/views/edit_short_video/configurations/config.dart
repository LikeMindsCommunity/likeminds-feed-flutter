import 'builder.dart';
import 'settings.dart';
import 'style.dart';

// export all config
export 'builder.dart';
export 'settings.dart';
export 'style.dart';

class LMFeedEditShortVideoConfig {
  final LMFeedEditShortVideoSettings settings;
  final LMFeedEditShortVideoStyle style;
  final LMFeedEditShortVideoBuilderDelegate builder;

  const LMFeedEditShortVideoConfig({
    this.settings = const LMFeedEditShortVideoSettings(),
    this.style = const LMFeedEditShortVideoStyle(),
    this.builder = const LMFeedEditShortVideoBuilderDelegate(),
  });
}
