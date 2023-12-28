import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/sdk/sdk_client_info_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMUserTagViewDataConvertor {
  static LMUserTagViewData fromUserTag(UserTag userTag) {
    LMUserTagViewDataBuilder userTagViewDataBuilder =
        LMUserTagViewDataBuilder();

    if (userTag.name != null) {
      userTagViewDataBuilder.name(userTag.name!);
    }

    if (userTag.imageUrl != null) {
      userTagViewDataBuilder.imageUrl(userTag.imageUrl!);
    }

    if (userTag.customTitle != null) {
      userTagViewDataBuilder.customTitle(userTag.customTitle!);
    }

    if (userTag.id != null) {
      userTagViewDataBuilder.id(userTag.id!);
    }

    if (userTag.isGuest != null) {
      userTagViewDataBuilder.isGuest(userTag.isGuest!);
    }

    if (userTag.userUniqueId != null) {
      userTagViewDataBuilder.userUniqueId(userTag.userUniqueId!);
    }

    if (userTag.sdkClientInfo != null) {
      userTagViewDataBuilder.sdkClientInfo(
          LMSDKClientInfoViewDataConvertor.fromSDKClientInfo(
              userTag.sdkClientInfo!));
    }

    return userTagViewDataBuilder.build();
  }

  static UserTag toUserTag(LMUserTagViewData userTagViewData) {
    return UserTag(
      name: userTagViewData.name,
      imageUrl: userTagViewData.imageUrl,
      customTitle: userTagViewData.customTitle,
      id: userTagViewData.id,
      isGuest: userTagViewData.isGuest,
      userUniqueId: userTagViewData.userUniqueId,
      sdkClientInfo: userTagViewData.sdkClientInfo != null
          ? LMSDKClientInfoViewDataConvertor.toSDKClientInfo(
              userTagViewData.sdkClientInfo!)
          : null,
    );
  }
}
