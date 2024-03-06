class LMSDKClientInfoViewData {
  int community;
  int user;
  String uuid;

  LMSDKClientInfoViewData._({
    required this.community,
    required this.user,
    required this.uuid,
  });
}

class LMSDKClientInfoViewDataBuilder {
  int? _community;
  int? _user;
  String? _uuid;

  void community(int community) {
    _community = community;
  }

  void user(int user) {
    _user = user;
  }

  void uuid(String uuid) {
    _uuid = uuid;
  }

  LMSDKClientInfoViewData build() {
    return LMSDKClientInfoViewData._(
      community: _community!,
      user: _user!,
      uuid: _uuid!,
    );
  }
}
