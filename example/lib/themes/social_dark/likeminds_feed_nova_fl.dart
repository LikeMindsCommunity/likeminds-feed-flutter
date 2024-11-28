library likeminds_feed_ss_fl;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/social_dark/builder/post/post_builder.dart';
export 'builder/post/post_builder.dart';
export 'model/company_view_data.dart';
export 'builder/utils/analytics/analytics.dart';
export 'builder/utils/constants/ui_constants.dart';
export 'widget/company_feed.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return Scaffold(
      body: LMFeedSocialScreen(
        topicBarBuilder: (topicBar) {
          return topicBar.copyWith(
            style: topicBar.style?.copyWith(
              height: 60,
              backgroundColor: feedTheme.backgroundColor,
            ),
          );
        },
        customWidgetBuilder: (customWidget, context) {
          return const SizedBox.shrink();
        },
        postBuilder: (context, postWidget, postViewData) => novaPostBuilder(
          context,
          postWidget,
          postViewData,
          true,
        ),
        settings: const LMFeedSocialScreenSetting(
          topicSelectionWidgetType:
              LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet,
          showCustomWidget: true,
        ),
      ),
    );
  }
}
