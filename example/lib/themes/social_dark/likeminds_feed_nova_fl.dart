library likeminds_feed_ss_fl;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/social_dark/src/builder/post/post_builder.dart';
export 'src/builder/post/post_builder.dart';
export 'src/model/company_view_data.dart';
export 'src/utils/analytics/analytics.dart';
export 'src/utils/constants/ui_constants.dart';
export 'src/widget/company_feed.dart';

class LMFeedNova extends StatefulWidget {
  const LMFeedNova({
    super.key,
  });

  @override
  State<LMFeedNova> createState() => _LMFeedNovaState();
}

class _LMFeedNovaState extends State<LMFeedNova> {
  Future<InitiateUserResponse>? initiateUser;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    super.initState();
    // var env = DotEnv(includePlatformEnvironment: true)..load();
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return Scaffold(
      body: LMFeedScreen(
        topicBarBuilder: (topicBar) {
          return topicBar.copyWith(
            style: topicBar.style?.copyWith(
              height: 60,
              backgroundColor: feedTheme.backgroundColor,
            ),
          );
        },
        customWidgetBuilder: (context) {
          return const SizedBox.shrink();
        },
        postBuilder: (context, postWidget, postViewData) => novaPostBuilder(
          context,
          postWidget,
          postViewData,
          true,
        ),
        config: const LMFeedScreenConfig(
          topicSelectionWidgetType:
              LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet,
          showCustomWidget: true,
        ),
      ),
    );
  }
}
