import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/sdk/sdk_client_info_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMUserViewDataConvertor {
  static LMUserViewData fromUser(User user,
      {Map<String, WidgetModel>? widgets}) {
    LMUserViewDataBuilder userViewDataBuilder = LMUserViewDataBuilder();

    userViewDataBuilder.id(user.id);

    userViewDataBuilder.name(user.name);

    userViewDataBuilder.imageUrl(user.imageUrl);

    if (user.isGuest != null) {
      userViewDataBuilder.isGuest(user.isGuest!);
    }

    if (user.isDeleted != null) {
      userViewDataBuilder.isDeleted(user.isDeleted!);
    }

    userViewDataBuilder.userUniqueId(user.userUniqueId);
    if (user.organisationName != null) {
      userViewDataBuilder.organisationName(user.organisationName!);
    }

    if (user.sdkClientInfo != null) {
      userViewDataBuilder.sdkClientInfo(
          LMSDKClientInfoViewDataConvertor.fromSDKClientInfo(
              user.sdkClientInfo!));
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
    if (widgets != null && widgets[user.sdkClientInfo?.widgetId] != null) {
      userViewDataBuilder.widget(LMWidgetViewDataConvertor.fromWidgetModel(
          widgets[user.sdkClientInfo?.widgetId]!));
    }
    return userViewDataBuilder.build();
  }

  static User toUser(LMUserViewData userViewData) {
    return User(
      id: userViewData.id,
      name: userViewData.name,
      imageUrl: userViewData.imageUrl,
      isGuest: userViewData.isGuest,
      userUniqueId: userViewData.userUniqueId,
      organisationName: userViewData.organisationName,
      sdkClientInfo: userViewData.sdkClientInfo != null
          ? LMSDKClientInfoViewDataConvertor.toSDKClientInfo(
              userViewData.sdkClientInfo!)
          : null,
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
