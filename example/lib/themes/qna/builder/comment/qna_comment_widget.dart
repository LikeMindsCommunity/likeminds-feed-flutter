import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/report_bottomsheet.dart';

class LMQnACommentWidgetExample extends StatefulWidget {
  final LMCommentViewData commentViewData;
  final LMPostViewData postViewData;
  final LMFeedCommentWidget commentWidget;

  const LMQnACommentWidgetExample({
    super.key,
    required this.commentViewData,
    required this.postViewData,
    required this.commentWidget,
  });

  @override
  State<LMQnACommentWidgetExample> createState() => _LMQnACommentWidgetExampleState();
}

class _LMQnACommentWidgetExampleState extends State<LMQnACommentWidgetExample> {
  LMCommentViewData? commentViewData;
  LMPostViewData? postViewData;
  LMUserViewData? commentCreator;
  String userSubText = "";
  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  @override
  void initState() {
    super.initState();
    commentViewData = widget.commentViewData;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnACommentWidgetExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    commentViewData = widget.commentViewData;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = "";
    userSubText = generateUserSubText(userSubText);
  }

  @override
  Widget build(BuildContext context) {
    return widget.commentWidget.copyWith(
      customTitle: LMFeedText(
        text: " • ${LMFeedTimeAgo.instance.format(commentViewData!.createdAt)}",
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            color: textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
        ),
      ),
      menu: (menu) {
        return menu.copyWith(
          removeItemIds: {},
          action: menu.action?.copyWith(
            onCommentReport: () {
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
                  entityId: commentViewData?.id ?? '',
                  entityType: commentViewData!.level == 0
                      ? commentEntityId
                      : replyEntityId,
                  entityCreatorId: commentViewData?.uuid ?? '',
                ),
              );
            },
          ),
        );
      },
      likeButtonBuilder: (button) {
        return button.copyWith(
          onTextTap: () {
            LMQnAFeedUtils.showLikesBottomSheet(context, postViewData!.id,
                commentId: commentViewData!.id);
          },
          activeText: LMFeedText(
            text: commentViewData!.likesCount.toString(),
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: textSecondary,
                fontFamily: 'Inter',
                height: 1.25,
              ),
            ),
          ),
          text: LMFeedText(
            text: commentViewData!.likesCount.toString(),
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: textSecondary,
                fontFamily: 'Inter',
                height: 1.25,
              ),
            ),
          ),
        );
      },
      subtitleText: LMFeedText(
        text: userSubText,
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: kSecondaryColor700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // This functions calculates the no of countries followed by the user
  // and the tag that they are given
  String generateUserSubText(String subText) {
    if (commentCreator != null) {
      // calculate the no of countries followed by the user
      // and add it in the subtext string
      userSubText = LMQnAFeedUtils.calculateNoCountriesFollowedByUser(
          userSubText, commentCreator!.topics ?? []);

      // parse the tag given to user from
      // widgets and append it in the subtext string
      LMWidgetViewData? widgetViewData =
          postViewData!.widgets?[commentCreator!.sdkClientInfo.widgetId];

      if (widgetViewData != null) {
        userSubText =
            LMQnAFeedUtils.getUserTagFromWidget(userSubText, widgetViewData);
      }

      return userSubText;
    } else {
      return "";
    }
  }
}
