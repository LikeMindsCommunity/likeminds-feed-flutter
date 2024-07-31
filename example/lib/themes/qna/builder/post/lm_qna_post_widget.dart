import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/post/lm_qna_post_footer.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_detail_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/report_bottomsheet.dart';

class LMQnAPostWidget extends StatefulWidget {
  final LMFeedPostWidget postWidget;
  final LMPostViewData postViewData;
  final LMFeedWidgetSource source;

  const LMQnAPostWidget({
    super.key,
    required this.postWidget,
    required this.postViewData,
    this.source = LMFeedWidgetSource.universalFeed,
  });

  @override
  State<LMQnAPostWidget> createState() => _LMQnAPostWidgetState();
}

class _LMQnAPostWidgetState extends State<LMQnAPostWidget> {
  LMPostViewData? postViewData;
  LMFeedPostWidget? postWidget;
  LMUserViewData userViewData = LMFeedLocalPreference.instance.fetchUserData()!;

  LMUserViewData? postCreator;
  String userSubText = "";

  @override
  void initState() {
    super.initState();
    postViewData = widget.postViewData;
    postWidget = widget.postWidget;
    postCreator = postViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnAPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    postViewData = widget.postViewData;
    postWidget = widget.postWidget;
    postCreator = postViewData?.user;
    userSubText = "";
    userSubText = generateUserSubText(userSubText);
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return GestureDetector(
      onTap: () {
        postWidget?.onPostTap?.call(context, postViewData!);
      },
      child: Container(
        padding: postWidget!.style?.padding,
        margin: postWidget!.style?.margin,
        decoration: BoxDecoration(
          boxShadow: postWidget!.style?.boxShadow,
          borderRadius: postWidget!.style?.borderRadius,
          border: postWidget!.style?.border,
          color: postWidget!.style?.backgroundColor ?? feedThemeData.container,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postWidget!.header != null)
              postWidget!.header!.copyWith(
                createdAt: null,
                customTitle: LMFeedText(
                  text:
                      "• ${LMFeedTimeAgo.instance.format(postViewData!.createdAt)}",
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                subTextSeparator: LMFeedText(
                  text: "•",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: feedThemeData.onContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                subText: userSubText.isEmpty
                    ? null
                    : LMFeedText(
                        text: userSubText,
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: feedThemeData.onContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                menuBuilder: (menu) => menu.copyWith(
                    removeItemIds: {},
                    action: menu.action?.copyWith(onPostReport: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        useSafeArea: true,
                        isScrollControlled: true,
                        elevation: 10,
                        enableDrag: true,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                          minHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        backgroundColor: feedThemeData.container,
                        clipBehavior: Clip.hardEdge,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        builder: (context) => QnAReportBottomSheet(
                          entityId: postViewData?.id ?? '',
                          entityType: 5,
                          entityCreatorId: postViewData?.uuid ?? '',
                        ),
                      );
                    })),
              ),
            if (((postViewData!.heading?.isNotEmpty ?? false) ||
                    postViewData!.text.isNotEmpty) &&
                postWidget!.content != null)
              postWidget!.content!,
            if (postWidget!.media != null)
              postWidget!.media!,
            if (postWidget!.topicWidget != null)
              postWidget!.topicWidget!.copyWith(
                onTopicTap: (context, topicViewData) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LMFeedTopicDetailsScreen(
                        topicViewData: topicViewData,
                      ),
                    ),
                  );
                },
              ),
            //postTopics,
            if (postWidget!.footer != null)
              LMQnAPostFooter(
                feedThemeData: feedThemeData,
                footer: postWidget!.footer!,
                postViewData: postViewData!,
                source: widget.source,
              ),
          ],
        ),
      ),
    );
  }

  // This functions calculates the no of countries followed by the user
  // and the tag that they are given
  String generateUserSubText(String subText) {
    if (postCreator != null) {
      // calculate the no of countries followed by the user
      // and add it in the subtext string
      userSubText = LMQnAFeedUtils.calculateNoCountriesFollowedByUser(
          userSubText, postCreator!.topics ?? []);

      // parse the tag given to user from
      // widgets and append it in the subtext string
      LMWidgetViewData? widgetViewData =
          postViewData!.widgets?[postCreator!.sdkClientInfo.widgetId];

      if (widgetViewData != null) {
        userSubText =
            LMQnAFeedUtils.getUserTagFromWidget(userSubText, widgetViewData);
      }

      if (userViewData.uuid == postCreator!.uuid) {
        LMCache cache = (LMCacheBuilder()
              ..key("user_sub_text")
              ..value(userSubText))
            .build();
        LMFeedCore.client.insertOrUpdateCache(cache);
      }

      return userSubText;
    } else {
      return "";
    }
  }
}
