import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedUserUtils {
  // util function to check if the current user is a guest user
  static bool isGuestUser() {
    final currentUser = LMFeedLocalPreference.instance.fetchUserData();
    return currentUser?.isGuest ?? false;
  }

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
    bool isPostCreationAllowed = true;
    memberStateResponse.memberRights?.forEach((element) {
      if (element.state == 9) {
        isPostCreationAllowed = element.isSelected;
      }
    });
    return isPostCreationAllowed;
  }

  static bool checkCommentRights() {
    final MemberStateResponse? memberStateResponse =
        LMFeedLocalPreference.instance.fetchMemberState();
    if (memberStateResponse == null ||
        !memberStateResponse.success ||
        memberStateResponse.state == 1) {
      return true;
    }
    bool isCommentCreationAllowed = true;
    memberStateResponse.memberRights?.forEach((element) {
      if (element.state == 10) {
        isCommentCreationAllowed = element.isSelected;
      }
    });
    return isCommentCreationAllowed;
  }
}
