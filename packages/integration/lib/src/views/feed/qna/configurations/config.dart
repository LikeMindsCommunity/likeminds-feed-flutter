import 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/styles.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/qna/configurations/styles.dart';

class LMFeedQnaScreenConfig {
  final LMFeedQnaScreenBuilderDelegate builder;
  final LMFeedQnaScreenSetting setting;
  final LMFeedQnaScreenStyle style;

  const LMFeedQnaScreenConfig({
    this.builder = const LMFeedQnaScreenBuilderDelegate(),
    this.setting = const LMFeedQnaScreenSetting(),
    this.style = const LMFeedQnaScreenStyle(),
  });
}
