library likeminds_feed_ss_fl;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/social_feedroom/koshiqa_theme.dart';
export 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedKoshiqa extends StatefulWidget {
  final int? feedRoomId;
  final Function(BuildContext)? openChatCallback;

  const LMFeedKoshiqa({
    super.key,
    this.feedRoomId,
    this.openChatCallback,
  });

  @override
  State<LMFeedKoshiqa> createState() => _LMFeedKoshiqaState();

  static Future<void> setupFeed({
    String? domain,
    LMFeedThemeData? lmTheme,
    LMFeedConfig? lmConfig,
  }) async {
    await LMFeedCore.instance.initialize(
      domain: domain,
      theme: lmTheme ?? koshiqaTheme,
      config: lmConfig ??
          LMFeedConfig(
            globalSystemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
    );
  }
}

class _LMFeedKoshiqaState extends State<LMFeedKoshiqa> {
  late bool isCm;

  @override
  void initState() {
    super.initState();
    isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(
      builder: (context) {
        if (!isCm && widget.feedRoomId == null) {
          return const Center(
            child: Text(
                "You need to provide an LM FeedRoom ID if the user being logged in is not a community manager"),
          );
        }
        return isCm
            ? const LMFeedRoomListScreen()
            : LMFeedRoomScreen(feedroomId: widget.feedRoomId!);
      },
    ));
  }
}
