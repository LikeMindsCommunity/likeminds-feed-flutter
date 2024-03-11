class LMSDKClientInfoViewData {
  int community;
  int user;
  String userUniqueId;
  String? widgetId;

  LMSDKClientInfoViewData._({
    required this.community,
    required this.user,
    required this.userUniqueId,
    this.widgetId,
  });
}

class LMSDKClientInfoViewDataBuilder {
  int? _community;
  int? _user;
  String? _userUniqueId;
  String? _widgetId;

  void community(int community) {
    _community = community;
  }

  void user(int user) {
    _user = user;
  }

  void userUniqueId(String userUniqueId) {
    _userUniqueId = userUniqueId;
  }

  void widgetId(String widgetId) {
    _widgetId = widgetId;
  }

  LMSDKClientInfoViewData build() {
    return LMSDKClientInfoViewData._(
      community: _community!,
      user: _user!,
      userUniqueId: _userUniqueId!,
      widgetId: _widgetId,
    );
  }
}
