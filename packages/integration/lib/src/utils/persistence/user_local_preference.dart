import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedLocalPreference {
  static LMFeedLocalPreference? _instance;

  static LMFeedLocalPreference get instance =>
      _instance ??= LMFeedLocalPreference._();

  LMFeedLocalPreference._();

  Future<LMResponse> storeUserData(User user) async {
    return await LMFeedCore.client.insertOrUpdateLoggedInUser(user);
  }

  LMUserViewData? fetchUserData() {
    LMResponse response = LMFeedCore.client.getLoggedInUser();

    if (response.success) {
      return LMUserViewDataConvertor.fromUser(response.data!);
    } else {
      return null;
    }
  }

  Future<LMResponse> clearUserData() async {
    return await LMFeedCore.client.deleteLoggedInUser();
  }

  Future<LMResponse> storeCommunityConfiguration(
      CommunityConfigurations communityConfiguration) async {
    return await LMFeedCore.client
        .insertOrUpdateCommunityConfigurationsDB([communityConfiguration]);
  }

  CommunityConfigurations? fetchCommunityConfiguration(String type) {
    LMResponse response = LMFeedCore.client.getCommunityConfigurationsDB(type);

    if (response.success) {
      return response.data!;
    } else {
      return null;
    }
  }

  Future<LMResponse> storeMemberState(MemberStateResponse memberStateResponse) {
    return LMFeedCore.client
        .insertOrUpdateLoggedInMemberState(memberStateResponse);
  }

  Future<LMResponse> clearMemberState() {
    return LMFeedCore.client.deleteLoggedInMemberState();
  }

  Future<LMResponse> clearCommunityConfiguration() {
    return LMFeedCore.client.clearCommunityConfigurationsDB();
  }

  MemberStateResponse? fetchMemberState() {
    LMResponse response = LMFeedCore.client.getLoggedInMemberState();

    if (response.success) {
      return response.data!;
    } else {
      return null;
    }
  }

  Future<LMResponse> storeCache(LMCache cache) {
    return LMFeedCore.client.insertOrUpdateCache(cache);
  }

  LMCache? fetchCache(String key) {
    LMResponse response = LMFeedCore.client.getCache(key);

    if (response.success) {
      return response.data!;
    } else {
      return null;
    }
  }

  Future<LMResponse> deleteCache(String key) {
    return LMFeedCore.client.deleteCache(key);
  }

  Future<LMResponse> clearCache() {
    return LMFeedCore.client.clearCache();
  }

  String getPostVariable() {
    LMFeedThemeType themeType = LMFeedCore.config.feedThemeType;
    String postVar = themeType == LMFeedThemeType.qna ? "Question" : "Post";

    LMCache? postCache = fetchCache("lm-feed-post-var");

    if (postCache != null) {
      postVar = postCache.value as String;
    } else {
      CommunityConfigurations? communityConfigurations =
          fetchCommunityConfiguration("feed_metadata");

      if (communityConfigurations != null &&
          communityConfigurations.value != null &&
          communityConfigurations.value!.containsKey('post')) {
        postVar = communityConfigurations.value?['post'] ?? "Post";
        storePostVariable(postVar);
      }
    }

    return postVar;
  }

  String getCommentVariable() {
    LMFeedThemeType themeType = LMFeedCore.config.feedThemeType;
    String commentVar = themeType == LMFeedThemeType.qna ? "Answer" : "Comment";

    LMCache? commentCache = fetchCache("lm-feed-comment-var");

    if (commentCache != null) {
      commentVar = commentCache.value as String;
    } else {
      CommunityConfigurations? communityConfigurations =
          fetchCommunityConfiguration("feed_metadata");

      if (communityConfigurations != null &&
          communityConfigurations.value != null &&
          communityConfigurations.value!.containsKey('comment')) {
        commentVar = communityConfigurations.value?['comment'] ?? "Comment";
        storeCommentVariable(commentVar);
      }
    }

    return commentVar;
  }

  Future<LMResponse> storePostVariable(String postVar) {
    LMCache cache = (LMCacheBuilder()
          ..key("lm-feed-post-var")
          ..value(postVar))
        .build();

    return storeCache(cache);
  }

  Future<LMResponse> storeCommentVariable(String commentVar) async {
    LMCache cache = (LMCacheBuilder()
          ..key("lm-feed-comment-var")
          ..value(commentVar))
        .build();

    return storeCache(cache);
  }
}
