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
  void eventFiredCallback(String eventKey, Map<String, dynamic> propertiesMap) {
    // TODO: implement eventFiredCallback
  }

  @override
  void loginRequiredCallback() {
    // TODO: implement loginRequiredCallback
  }

  @override
  void logoutCallback() {
    // TODO: implement logoutCallback
  }

  @override
  void onAccessTokenExpired(String accessToken, String refreshToken) {
    //TODO: update local preference with new tokens
    _lmFeedCallback?.onAccessTokenExpired?.call(accessToken, refreshToken);
  }

  @override
  Future<UpdateTokenRequest> onRefreshTokenExpired() async {
    //TODO: update local preference with new tokens
    if("apiKey" == null){
      if(_lmFeedCallback?.onRefreshTokenExpired == null){
        throw Exception("onRefreshTokenExpired is not implemented in LMFeedCallback");
      }
      return _lmFeedCallback!.onRefreshTokenExpired!.call();
    }else{
      // return UpdateTokenRequestBuilder().apiKey(apiKey!).build();
    }

    return _lmFeedCallback!.onRefreshTokenExpired!.call();
  }

  @override
  void profileRouteCallback({required String uuid}) {
    // TODO: implement profileRouteCallback
  }

  @override
  void routeToCompanyCallback({required String companyId}) {
    // TODO: implement routeToCompanyCallback
  }
}
