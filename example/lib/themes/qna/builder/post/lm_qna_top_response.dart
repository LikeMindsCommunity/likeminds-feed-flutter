import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';

class LMQnATopResponseWidgetExample extends StatefulWidget {
  final List<LMCommentViewData> topResponses;
  final LMPostViewData postViewData;
  final LMFeedThemeData feedThemeData;

  const LMQnATopResponseWidgetExample(
      {super.key,
      required this.feedThemeData,
      required this.postViewData,
      required this.topResponses});

  @override
  State<LMQnATopResponseWidgetExample> createState() => _LMQnATopResponseWidgetExampleState();
}

class _LMQnATopResponseWidgetExampleState extends State<LMQnATopResponseWidgetExample> {
  LMCommentViewData? commentViewData;
  LMPostViewData? postViewData;
  LMUserViewData? commentCreator;
  String userSubText = "";

  String commentTitle = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  @override
  void initState() {
    super.initState();
    commentViewData = widget.topResponses.first;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnATopResponseWidgetExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    commentViewData = widget.topResponses.first;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
  }

  @override
  Widget build(BuildContext context) {
    return widget.topResponses.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LMFeedText(
                text: "Top $commentTitle",
                style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    color: textTertiary,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: LMFeedProfilePicture(
                      fallbackText: widget.topResponses.first.user.name,
                      imageUrl: widget.topResponses.first.user.imageUrl ?? "",
                      style: LMFeedProfilePictureStyle(
                        size: 35,
                        fallbackTextStyle: LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.feedThemeData.onPrimary,
                          ),
                        ),
                      ),
                      onTap: () {
                        LMFeedProfileBloc.instance.add(
                          LMFeedRouteToUserProfileEvent(
                            uuid: widget.topResponses.first.user.uuid,
                            context: context,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: widget.feedThemeData.backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              LMFeedProfileBloc.instance.add(
                                LMFeedRouteToUserProfileEvent(
                                  uuid: widget.topResponses.first.user.uuid,
                                  context: context,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LMFeedText(
                                  text: widget.topResponses.first.user.name,
                                  style: const LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                                if (userSubText.isNotEmpty)
                                  LMFeedText(
                                    text: userSubText,
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        color: LMFeedCore.theme.onContainer,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        height: 1.75,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          LMFeedExpandableText(
                            LMFeedTaggingHelper.convertRouteToTag(
                                widget.topResponses.first.text),
                            expandText: "Read More",
                            prefixStyle: const TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.66,
                            ),
                            expandOnTextTap: true,
                            onTagTap: (String uuid) {
                              LMFeedProfileBloc.instance.add(
                                LMFeedRouteToUserProfileEvent(
                                  uuid: uuid,
                                  context: context,
                                ),
                              );
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: textSecondary,
                              height: 1.66,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
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
