import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCoreCallback {
  Function(String accessToken, String refreshToken)? onAccessTokenExpired;
  Future<UpdateTokenRequest> Function()? onRefreshTokenExpired;
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
  void onAccessTokenExpired(String accessToken, String refreshToken) {
    //Redirecting from core to example app
    LMFeedLocalPreference.instance.storeCache((LMCacheBuilder()
          ..key(LMFeedStringConstants.instance.accessToken)
          ..value(accessToken))
        .build());

    LMFeedLocalPreference.instance.storeCache((LMCacheBuilder()
          ..key(LMFeedStringConstants.instance.refreshToken)
          ..value(refreshToken))
        .build());
    _lmFeedCallback?.onAccessTokenExpired?.call(accessToken, refreshToken);
  }

  @override
  Future<UpdateTokenRequest> onRefreshTokenExpired() async {
    String? apiKey = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.instance.apiKey)
        ?.value as String?;

    debugPrint(
        "This is print ////// \n\n\n\n\n ////////// this is new ///////\n/////\n////\n/////");

    if (apiKey != null) {
      LMUserViewData? userViewData =
          LMFeedLocalPreference.instance.fetchUserData();

      if (userViewData == null) {
        throw Exception("User data not found");
      }

      LMResponse initiateUserRes = await LMFeedCore.instance.showFeedWithApiKey(
          apiKey, userViewData.sdkClientInfo.uuid, userViewData.name);

      if (initiateUserRes.success) {
        InitiateUserResponse initiateUserResponse =
            initiateUserRes.data as InitiateUserResponse;
        return (UpdateTokenRequestBuilder()
              ..accessToken(initiateUserResponse.accessToken!)
              ..refreshToken(initiateUserResponse.refreshToken!))
            .build();
      } else {
        throw Exception(initiateUserRes.errorMessage);
      }
    } else {
      final onRefreshTokenExpired = _lmFeedCallback?.onRefreshTokenExpired;
      if (onRefreshTokenExpired == null) {
        throw Exception("onRefreshTokenExpired callback is not implemented");
      }

      return onRefreshTokenExpired.call();
    }
  }

  @override
  void profileRouteCallback({required String uuid}) {}

  @override
  void routeToCompanyCallback({required String companyId}) {}
}
