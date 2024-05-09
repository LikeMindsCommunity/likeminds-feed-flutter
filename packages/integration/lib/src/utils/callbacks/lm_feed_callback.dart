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

    if (apiKey != null) {
      LMUserViewData? userViewData =
          LMFeedLocalPreference.instance.fetchUserData();

      if (userViewData == null) {
        throw Exception("User data not found");
      }

      InitiateUserRequest initiateUserRequest = (InitiateUserRequestBuilder()
            ..apiKey(apiKey)
            ..isGuest(false)
            ..userName(userViewData.name)
            ..uuid(userViewData.sdkClientInfo.uuid))
          .build();

      LMResponse<InitiateUserResponse> initiateUserRes = await LMFeedCore
          .instance
          .initiateUser(initiateUserRequest: initiateUserRequest);

      if (initiateUserRes.success) {
        return (UpdateTokenRequestBuilder()
              ..accessToken(initiateUserRes.data!.accessToken!)
              ..refreshToken(initiateUserRes.data!.refreshToken!))
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
