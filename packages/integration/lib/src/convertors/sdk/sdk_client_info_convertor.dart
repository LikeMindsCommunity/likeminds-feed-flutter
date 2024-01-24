import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMSDKClientInfoViewDataConvertor {
  static LMSDKClientInfoViewData fromSDKClientInfo(
      SDKClientInfo sdkClientInfo) {
    LMSDKClientInfoViewDataBuilder sdkClientInfoViewDataBuilder =
        LMSDKClientInfoViewDataBuilder();

    sdkClientInfoViewDataBuilder.community(sdkClientInfo.community);

    sdkClientInfoViewDataBuilder.user(sdkClientInfo.user);

    sdkClientInfoViewDataBuilder.userUniqueId(sdkClientInfo.userUniqueId);

    return sdkClientInfoViewDataBuilder.build();
  }

  static SDKClientInfo toSDKClientInfo(
      LMSDKClientInfoViewData sdkClientInfoViewData) {
    return SDKClientInfo(
      community: sdkClientInfoViewData.community,
      user: sdkClientInfoViewData.user,
      userUniqueId: sdkClientInfoViewData.userUniqueId,
    );
  }
}
