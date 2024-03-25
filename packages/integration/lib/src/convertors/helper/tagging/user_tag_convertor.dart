import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/sdk/sdk_client_info_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

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

    if (userTag.uuid != null) {
      userTagViewDataBuilder.uuid(userTag.uuid!);
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
      uuid: userTagViewData.uuid,
      sdkClientInfo: userTagViewData.sdkClientInfo != null
          ? LMSDKClientInfoViewDataConvertor.toSDKClientInfo(
              userTagViewData.sdkClientInfo!)
          : null,
    );
  }
}
