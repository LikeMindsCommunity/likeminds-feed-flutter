import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMSDKClientInfoViewDataConvertor {
  static LMSDKClientInfoViewData fromSDKClientInfo(
      SDKClientInfo sdkClientInfo) {
    LMSDKClientInfoViewDataBuilder sdkClientInfoViewDataBuilder =
        LMSDKClientInfoViewDataBuilder();

    sdkClientInfoViewDataBuilder.community(sdkClientInfo.community);

    sdkClientInfoViewDataBuilder.user(sdkClientInfo.user);

    sdkClientInfoViewDataBuilder.uuid(sdkClientInfo.uuid);

    if (sdkClientInfo.widgetId != null)
      sdkClientInfoViewDataBuilder.widgetId(sdkClientInfo.widgetId!);

    return sdkClientInfoViewDataBuilder.build();
  }

  static SDKClientInfo toSDKClientInfo(
      LMSDKClientInfoViewData sdkClientInfoViewData) {
    return SDKClientInfo(
      community: sdkClientInfoViewData.community,
      user: sdkClientInfoViewData.user,
      uuid: sdkClientInfoViewData.uuid,
      widgetId: sdkClientInfoViewData.widgetId,
    );
  }
}
