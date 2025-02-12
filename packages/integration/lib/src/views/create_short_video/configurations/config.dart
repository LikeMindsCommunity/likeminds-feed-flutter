import 'builder.dart';
import 'settings.dart';
import 'style.dart';

// export all config
export 'builder.dart';
export 'settings.dart';
export 'style.dart';

class LMFeedCreateShortVideoConfig {
  final LMFeedCreateShortVideoSettings setting;
  final LMFeedCreateShortVideoStyle style;
  final LMFeedCreateShortVideoBuilderDelegate builder;

  const LMFeedCreateShortVideoConfig({
    this.setting = const LMFeedCreateShortVideoSettings(),
    this.style = const LMFeedCreateShortVideoStyle(),
    this.builder = const LMFeedCreateShortVideoBuilderDelegate(),
  });
}
