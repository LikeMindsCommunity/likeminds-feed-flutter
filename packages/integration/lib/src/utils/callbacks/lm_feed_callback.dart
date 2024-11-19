import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCoreCallback {
  Function(String accessToken, String refreshToken)?
      onAccessTokenExpiredAndRefreshed;
  Future<LMAuthToken> Function()? onRefreshTokenExpired;

  /// callback to be triggered when a guest user tries to access a restricted route
  void Function(BuildContext context)? loginRequired;

  LMFeedCoreCallback({
    this.onAccessTokenExpiredAndRefreshed,
    this.onRefreshTokenExpired,
    this.loginRequired,
  });
}

class LMSDKCallbackImplementation implements LMSDKCallback {
  LMFeedCoreCallback? _lmFeedCallback;
  LMSDKCallbackImplementation({LMFeedCoreCallback? lmFeedCallback})
      : _lmFeedCallback = lmFeedCallback;
  @override
  void eventFiredCallback(
      String eventKey, Map<String, dynamic> propertiesMap) {}

  @override
  void loginRequiredCallback() {}

  @override
  void logoutCallback() {}

  @override
  void onAccessTokenExpiredAndRefreshed(
      String accessToken, String refreshToken) {
    //TODO can be removed
    LMFeedLocalPreference.instance.storeCache((LMCacheBuilder()
          ..key(LMFeedStringConstants.accessToken)
          ..value(accessToken))
        .build());
    LMFeedLocalPreference.instance.storeCache((LMCacheBuilder()
          ..key(LMFeedStringConstants.refreshToken)
          ..value(refreshToken))
        .build());
    //Redirecting from core to example app
    _lmFeedCallback?.onAccessTokenExpiredAndRefreshed
        ?.call(accessToken, refreshToken);
  }

  @override
  Future<LMAuthToken> onRefreshTokenExpired() async {
    String? apiKey = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.apiKey)
        ?.value as String?;

    if (apiKey != null) {
      LMUserViewData? userViewData =
          LMFeedLocalPreference.instance.fetchUserData();
      if (userViewData == null) {
        throw Exception("User data not found");
      }

      InitiateUserRequest initiateUserRequest = (InitiateUserRequestBuilder()
            ..apiKey(apiKey)
            ..userName(userViewData.name)
            ..uuid(userViewData.sdkClientInfo.uuid))
          .build();

      LMResponse<InitiateUserResponse> initiateUserResponse = await LMFeedCore
          .instance
          .initiateUser(initiateUserRequest: initiateUserRequest);

      if (initiateUserResponse.success) {
        return (LMAuthTokenBuilder()
              ..accessToken(initiateUserResponse.data!.accessToken!)
              ..refreshToken(initiateUserResponse.data!.refreshToken!))
            .build();
      } else {
        throw Exception(initiateUserResponse.errorMessage);
      }
    } else {
      final onRefreshTokenExpired = _lmFeedCallback?.onRefreshTokenExpired;
      if (onRefreshTokenExpired == null) {
        throw Exception("onRefreshTokenExpired callback is not implemented");
      }

      return onRefreshTokenExpired();
    }
  }

  @override
  void profileRouteCallback({required String uuid}) {}

  @override
  void routeToCompanyCallback({required String companyId}) {}
}
