import 'package:likeminds_feed_flutter_ui/src/models/sdk/sdk_client_info_view_data.dart';

class LMUserTagViewData {
  String? name;
  String? imageUrl;
  String? customTitle;
  int? id;
  bool? isGuest;
  String? userUniqueId;
  LMSDKClientInfoViewData? sdkClientInfo;

  LMUserTagViewData._({
    this.name,
    this.imageUrl,
    this.customTitle,
    this.id,
    this.isGuest,
    this.userUniqueId,
    this.sdkClientInfo,
  });
}

class LMUserTagViewDataBuilder {
  String? _name;
  String? _imageUrl;
  String? _customTitle;
  int? _id;
  bool? _isGuest;
  String? _userUniqueId;
  LMSDKClientInfoViewData? _sdkClientInfo;

  void name(String name) {
    _name = name;
  }

  void imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }

  void customTitle(String customTitle) {
    _customTitle = customTitle;
  }

  void id(int id) {
    _id = id;
  }

  void isGuest(bool isGuest) {
    _isGuest = isGuest;
  }

  void userUniqueId(String userUniqueId) {
    _userUniqueId = userUniqueId;
  }

  void sdkClientInfo(LMSDKClientInfoViewData sdkClientInfo) {
    _sdkClientInfo = sdkClientInfo;
  }

  LMUserTagViewData build() {
    return LMUserTagViewData._(
      name: _name,
      imageUrl: _imageUrl,
      customTitle: _customTitle,
      id: _id,
      isGuest: _isGuest,
      userUniqueId: _userUniqueId,
      sdkClientInfo: _sdkClientInfo,
    );
  }
}
