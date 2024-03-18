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
}
