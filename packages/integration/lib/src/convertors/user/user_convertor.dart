import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/sdk/sdk_client_info_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMUserViewDataConvertor {
  static LMUserViewData fromUser(User user) {
    LMUserViewDataBuilder userViewDataBuilder = LMUserViewDataBuilder();

    userViewDataBuilder.id(user.id);

    userViewDataBuilder.name(user.name);

    userViewDataBuilder.imageUrl(user.imageUrl);

    userViewDataBuilder.sdkClientInfo(
        LMSDKClientInfoViewDataConvertor.fromSDKClientInfo(user.sdkClientInfo));

    if (user.isGuest != null) {
      userViewDataBuilder.isGuest(user.isGuest!);
    }

    if (user.isDeleted != null) {
      userViewDataBuilder.isDeleted(user.isDeleted!);
    }

    userViewDataBuilder.uuid(user.uuid);
    if (user.organisationName != null) {
      userViewDataBuilder.organisationName(user.organisationName!);
    }

    if (user.updatedAt != null) {
      userViewDataBuilder.updatedAt(user.updatedAt!);
    }
    if (user.isOwner != null) {
      userViewDataBuilder.isOwner(user.isOwner!);
    }
    if (user.customTitle != null) {
      userViewDataBuilder.customTitle(user.customTitle!);
    }
    if (user.memberSince != null) {
      userViewDataBuilder.memberSince(user.memberSince!);
    }
    if (user.route != null) {
      userViewDataBuilder.route(user.route!);
    }
    if (user.state != null) {
      userViewDataBuilder.state(user.state!);
    }
    if (user.communityId != null) {
      userViewDataBuilder.communityId(user.communityId!);
    }
    if (user.createdAt != null) {
      userViewDataBuilder.createdAt(user.createdAt!);
    }

    return userViewDataBuilder.build();
  }

  static User toUser(LMUserViewData userViewData) {
    return User(
      id: userViewData.id,
      name: userViewData.name,
      imageUrl: userViewData.imageUrl,
      isGuest: userViewData.isGuest,
      uuid: userViewData.uuid,
      organisationName: userViewData.organisationName,
      sdkClientInfo: LMSDKClientInfoViewDataConvertor.toSDKClientInfo(
          userViewData.sdkClientInfo),
      updatedAt: userViewData.updatedAt,
      isOwner: userViewData.isOwner,
      customTitle: userViewData.customTitle,
      memberSince: userViewData.memberSince,
      route: userViewData.route,
      state: userViewData.state,
      communityId: userViewData.communityId,
      createdAt: userViewData.createdAt,
      isDeleted: userViewData.isDeleted,
    );
  }
}
