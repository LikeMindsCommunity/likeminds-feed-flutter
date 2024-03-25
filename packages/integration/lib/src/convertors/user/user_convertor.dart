import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMUserViewDataConvertor {
  static LMUserViewData fromUser(User user,
      {Map<String, LMTopicViewData>? topics,
      Map<String, List<String>>? userTopics,
      Map<String, LMWidgetViewData>? widgets}) {
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

    if ((topics != null && topics.isNotEmpty) &&
        (userTopics != null && userTopics.isNotEmpty)) {
      List<LMTopicViewData> userTopicsList = [];

      userTopics[user.uuid]?.forEach((element) {
        if (topics[element] != null) {
          userTopicsList.add(topics[element]!);
        }
      });
      userViewDataBuilder.topics(userTopicsList);
    }
    if (widgets != null && widgets[user.sdkClientInfo.widgetId] != null) {
      userViewDataBuilder.widget(widgets[user.sdkClientInfo.widgetId]!);
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
