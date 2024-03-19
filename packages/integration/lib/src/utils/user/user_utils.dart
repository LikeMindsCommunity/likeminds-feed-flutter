import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedUserUtils {
  static bool checkIfCurrentUserIsCM() {
    MemberStateResponse? response =
        LMFeedLocalPreference.instance.fetchMemberState();

    if (response == null) {
      return false;
    } else {
      return response.state == 1;
    }
  }

  static bool checkPostCreationRights() {
    final MemberStateResponse? memberStateResponse =
        LMFeedLocalPreference.instance.fetchMemberState();
    if (memberStateResponse == null ||
        !memberStateResponse.success ||
        memberStateResponse.state == 1) {
      return true;
    }
    int? index = memberStateResponse.memberRights
        ?.indexWhere((element) => element.state == 9);
    if (index == -1) {
      return false;
    } else {
      return true;
    }
  }

  static bool checkCommentRights() {
    final MemberStateResponse? memberStateResponse =
        LMFeedLocalPreference.instance.fetchMemberState();
    if (memberStateResponse == null ||
        !memberStateResponse.success ||
        memberStateResponse.state == 1) {
      return true;
    }
    int? index = memberStateResponse.memberRights
        ?.indexWhere((element) => element.state == 10);
    if (index == -1) {
      return false;
    } else {
      return true;
    }
  }
}
