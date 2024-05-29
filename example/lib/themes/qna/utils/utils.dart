import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/components/likes_bottom_sheet.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/components/post_detail_app_bar.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/widgets_builder.dart';

class LMQnAFeedUtils {
  static void navigateToLMPostDetailsScreen(
    String postId, {
    GlobalKey<NavigatorState>? navigatorKey,
    BuildContext? context,
  }) async {
    if (context == null && navigatorKey == null) {
      throw Exception('''
Either context or navigator key must be
         provided to navigate to PostDetailScreen''');
    }
    LMFeedVideoProvider.instance.pauseCurrentVideo();

    LMFeedQnAWidgets qNaFeedWidgets = LMFeedQnAWidgets.instance;

    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => LMFeedPostDetailScreen(
        postId: postId,
        postBuilder: qNaFeedWidgets.postWidgetBuilder,
        commentBuilder: qNaFeedWidgets.commentBuilder,
        appBarBuilder: qNaPostDetailScreenAppBarBuilder,
      ),
    );
    if (navigatorKey != null) {
      await navigatorKey.currentState!.push(
        route,
      );
    } else {
      await Navigator.of(context!, rootNavigator: true).push(route);
    }
  }

  static void showLikesBottomSheet(BuildContext context, String postId,
      {String? commentId}) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 10,
      enableDrag: true,
      showDragHandle: true,
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
      builder: (context) => LMFeedLikesBottomSheet(
        postId: postId,
        commentId: commentId,
      ),
    );
  }

  static void showDeleteBottomSheet(BuildContext context,
      LMPostViewData postViewData, LMFeedThemeData feedThemeData) {
    bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

    showModalBottomSheet(
      context: context,
      builder: (childContext) => LMFeedBottomSheet(
        children: [
          const LMFeedText(text: "Are you sure?"),
          const LMFeedText(
              text:
                  "You will not be able to recover this post once you delete it"),
          Row(
            children: <Widget>[
              LMFeedButton(
                onTap: () {},
                text: const LMFeedText(
                  text: "Go back",
                ),
                style: LMFeedButtonStyle(
                  borderRadius: 50,
                  border: Border.all(
                    width: 1,
                  ),
                  padding: const EdgeInsets.all(15.0),
                ),
              ),
              LMFeedButton(
                onTap: () {
                  String? reason;
                  Navigator.of(childContext).pop();

                  String postType =
                      LMFeedPostUtils.getPostType(postViewData.attachments);

                  LMFeedAnalyticsBloc.instance.add(
                    LMFeedFireAnalyticsEvent(
                      eventName: LMFeedAnalyticsKeys.postDeleted,
                      eventProperties: {
                        "post_id": postViewData.id,
                        "post_type": postType,
                        "user_id": postViewData.uuid,
                        "user_state": isCm ? "CM" : "member",
                      },
                    ),
                  );

                  LMFeedPostBloc.instance.add(
                    LMFeedDeletePostEvent(
                      postId: postViewData.id,
                      reason: reason ?? "",
                      isRepost: postViewData.isRepost,
                    ),
                  );
                },
                text: LMFeedText(
                  text: "Delete",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: feedThemeData.errorColor,
                    ),
                  ),
                ),
                style: LMFeedButtonStyle(
                  borderRadius: 50,
                  border: Border.all(
                    width: 1,
                    color: feedThemeData.errorColor,
                  ),
                  padding: const EdgeInsets.all(15.0),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  static Future<GetUserFeedMetaResponse> getUserMetaForCurrentUser() {
    GetUserFeedMetaRequestBuilder getUserFeedMetaRequestBuilder =
        GetUserFeedMetaRequestBuilder();

    LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();

    if (user == null) {
      throw Exception("User not found");
    }

    getUserFeedMetaRequestBuilder.uuid(user.uuid);

    GetUserFeedMetaRequest request = getUserFeedMetaRequestBuilder.build();

    return LMFeedCore.client.getUserFeedMeta(request);
  }

  static Future<GetTopicsResponse> getParentTopics() async {
    GetTopicsRequestBuilder getTopicsRequestBuilder = GetTopicsRequestBuilder();

    getTopicsRequestBuilder
      ..isEnabled(true)
      ..orderBy(["priority_desc"])
      ..page(1)
      ..pageSize(2);

    GetTopicsResponse response =
        await LMFeedCore.client.getTopics(getTopicsRequestBuilder.build());

    updateCacheForParentTopics(response);

    return response;
  }

  static Future<GetTopicsResponse> getChildTopics(List<String> parentTopicId,
      {int page = 1}) async {
    GetTopicsRequestBuilder getTopicsRequestBuilder = GetTopicsRequestBuilder();

    getTopicsRequestBuilder
      ..isEnabled(true)
      ..orderBy(["number_of_posts_desc", "priority_desc"])
      ..page(page)
      ..pageSize(10)
      ..parentIds(parentTopicId);

    GetTopicsRequest request = getTopicsRequestBuilder.build();

    GetTopicsResponse response = await LMFeedCore.client.getTopics(request);

    return response;
  }

  static Future<GetTopicsResponse> getParentTopicsFromCache() async {
    LMResponse<LMCache> response = LMFeedCore.client.getCache("hashtag#page0");

    if (response.success) {
      Map<String, dynamic> data = response.data!.value;

      GetTopicsResponseEntity getTopicsResponseEntity =
          GetTopicsResponseEntity.fromJson(data);

      GetTopicsResponse getTopicsResponse =
          GetTopicsResponse.fromEntity(getTopicsResponseEntity);

      return getTopicsResponse;
    } else {
      GetTopicsResponse getTopicsResponse = await getParentTopics();

      updateCacheForParentTopics(getTopicsResponse);

      return getTopicsResponse;
    }
  }

  static Future<LMResponse> updateCacheForParentTopics(
      GetTopicsResponse getTopicsResponse) async {
    GetTopicsResponseEntity getTopicsResponseEntity =
        getTopicsResponse.toEntity();

    if (getTopicsResponse.success) {
      LMCache parentTopicsCache = (LMCacheBuilder()
            ..key("hashtag#page0")
            ..value(getTopicsResponseEntity.toJson()))
          .build();

      await LMFeedCore.client.insertOrUpdateCache(parentTopicsCache);

      if (getTopicsResponse.topics != null &&
          getTopicsResponse.topics!.isNotEmpty) {
        LMCache maxPriorityTopicCache = (LMCacheBuilder()
              ..key("maximum_priority_topic")
              ..value(getTopicsResponseEntity.topics!.first))
            .build();

        return await LMFeedCore.client
            .insertOrUpdateCache(maxPriorityTopicCache);
      } else {
        return LMResponse(success: false, errorMessage: "Topics not found");
      }
    } else {
      return LMResponse(success: false, errorMessage: "Topics not found");
    }
  }

// This function calculates the no of countries followed by a user
  static String calculateNoCountriesFollowedByUser(
      String userSubText, List<LMTopicViewData> userTopics) {
    int followedCountries = 0;

    LMResponse cacheResponse =
        LMFeedCore.client.getCache("maximum_priority_topic");

    String countryTopicId;

    if (cacheResponse.success) {
      Map<String, dynamic> data =
          cacheResponse.data!.value as Map<String, dynamic>;
      if (data.containsKey("_id")) {
        countryTopicId = data["_id"];
      } else {
        return "";
      }
    } else {
      return "";
    }

    for (LMTopicViewData topic in userTopics) {
      if (topic.parentId == countryTopicId) {
        followedCountries++;
      }
    }

    if (followedCountries == 1) {
      userSubText += "$followedCountries country";
    } else {
      userSubText += "$followedCountries countries";
    }

    return userSubText;
  }

  // This function is used to get the tag given to the user
  // from the widgets
  static String getUserTagFromWidget(
      String userSubText, LMWidgetViewData widgetViewData) {
    if (widgetViewData.metadata.containsKey('tag') &&
        widgetViewData.metadata['tag'] != null) {
      String tag = widgetViewData.metadata['tag'] ?? "";
      if (userSubText.isEmpty) {
        userSubText = tag;
      } else {
        userSubText = "$userSubText • $tag";
      }
    }
    return userSubText;
  }

  // This function checks if the topic added in post by user
  // is followed by the user or not
  // If not followed then it will update the topic
  static Future<UpdateUserTopicsResponse?> checkIfTopicFollowInPost(
      String uuid,
      List<LMTopicViewData> postTopics,
      List<LMTopicViewData> userTopics) async {
    Map<String, bool> selectedTopicMap = {};

    for (LMTopicViewData topic in postTopics) {
      if (userTopics.indexWhere((userTopic) => userTopic.id == topic.id) ==
          -1) {
        selectedTopicMap[topic.id] = true;
      }
    }

    if (selectedTopicMap.isNotEmpty) {
      UpdateUserTopicsRequestBuilder requestBuilder =
          UpdateUserTopicsRequestBuilder();

      requestBuilder
        ..uuid(uuid)
        ..topicsId(selectedTopicMap);

      UpdateUserTopicsResponse response =
          await LMFeedCore.client.updateUserTopics(requestBuilder.build());
    }

    return null;
  }
}
