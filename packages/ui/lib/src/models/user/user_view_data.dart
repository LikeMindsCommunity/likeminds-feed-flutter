import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:likeminds_feed_flutter_ui/src/models/sdk/sdk_client_info_view_data.dart';

/// {@template lm_user_view_data}
/// A data class to hold the user data.
/// {@endtemplate}
class LMUserViewData {
  /// unique indentifier of the user
  int id;

  /// name of the user
  String name;

  /// image url of the user
  String? imageUrl;
  bool? isGuest;
  bool? isDeleted;
  String uuid;
  String? organisationName;
  LMSDKClientInfoViewData sdkClientInfo;
  int? updatedAt;
  bool? isOwner;

  /// custom title of the user
  /// eg: Community Manager
  String? customTitle;

  /// date since the user is a member of the community
  String? memberSince;
  String? route;
  int? state;

  /// community id of the community to which the user belongs
  int? communityId;
  int? createdAt;

  List<LMTopicViewData>? topics;

  /// widget for storing custom data
  LMWidgetViewData? widget;

  /// {@macro user_view_data}
  LMUserViewData._({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isGuest,
    required this.uuid,
    this.organisationName,
    required this.sdkClientInfo,
    this.updatedAt,
    this.isOwner,
    this.customTitle,
    this.memberSince,
    this.route,
    this.state,
    this.communityId,
    this.createdAt,
    this.isDeleted,
    this.topics,
    this.widget,
  });
}

/// {@template user_view_data_builder}
/// A builder class to build [LMUserViewData]
/// {@endtemplate}
class LMUserViewDataBuilder {
  int? _id;
  String? _name;
  String? _imageUrl;
  bool? _isGuest;
  bool? _isDeleted;
  String? _uuid;
  String? _organisationName;
  LMSDKClientInfoViewData? _sdkClientInfo;
  int? _updatedAt;
  bool? _isOwner;
  String? _customTitle;
  String? _memberSince;
  String? _route;
  int? _state;
  int? _communityId;
  int? _createdAt;
  List<LMTopicViewData>? _topics;
  LMWidgetViewData? _widget;

  void id(int id) {
    _id = id;
  }

  void name(String name) {
    _name = name;
  }

  void imageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
  }

  void isGuest(bool isGuest) {
    _isGuest = isGuest;
  }

  void isDeleted(bool isDeleted) {
    _isDeleted = isDeleted;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  void organisationName(String organisationName) {
    _organisationName = organisationName;
  }

  void sdkClientInfo(LMSDKClientInfoViewData sdkClientInfo) {
    _sdkClientInfo = sdkClientInfo;
  }

  void updatedAt(int updatedAt) {
    _updatedAt = updatedAt;
  }

  void isOwner(bool isOwner) {
    _isOwner = isOwner;
  }

  void customTitle(String customTitle) {
    _customTitle = customTitle;
  }

  void memberSince(String memberSince) {
    _memberSince = memberSince;
  }

  void route(String route) {
    _route = route;
  }

  void state(int state) {
    _state = state;
  }

  void communityId(int communityId) {
    _communityId = communityId;
  }

  void createdAt(int createdAt) {
    _createdAt = createdAt;
  }

  void topics(List<LMTopicViewData> topics) {
    _topics = topics;
  }

  void widget(LMWidgetViewData widget) {
    _widget = widget;
  }

  /// {@macro user_view_data_builder}
  LMUserViewData build() {
    return LMUserViewData._(
      id: _id!,
      name: _name!,
      imageUrl: _imageUrl,
      isGuest: _isGuest,
      uuid: _uuid!,
      organisationName: _organisationName,
      sdkClientInfo: _sdkClientInfo!,
      updatedAt: _updatedAt,
      isOwner: _isOwner,
      customTitle: _customTitle,
      memberSince: _memberSince,
      route: _route,
      state: _state,
      communityId: _communityId,
      createdAt: _createdAt,
      isDeleted: _isDeleted,
      topics: _topics,
      widget: _widget,
    );
  }
}
