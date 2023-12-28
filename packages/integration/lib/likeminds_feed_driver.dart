library likeminds_feed_driver_fl;

import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/utils/persistence/user_local_preference.dart';

export 'package:likeminds_feed_driver_fl/src/views/views.dart';
export 'package:likeminds_feed_driver_fl/src/utils/persistence/user_local_preference.dart';

class LMFeedIntegration {
  late final LMFeedClient lmFeedClient;
  late final MediaService? mediaService;

  static LMFeedIntegration? _instance;

  static LMFeedIntegration get instance => _instance ??= LMFeedIntegration._();

  LMFeedIntegration._();

  void initialize(
      {required LMFeedClient lmFeedClient, MediaService? mediaService}) {
    this.lmFeedClient = lmFeedClient;
    this.mediaService = mediaService;
  }

  Future<void> closeBlocs() async {
    await LMPostBloc.instance.close();
    await LMRoutingBloc.instance.close();
    await LMProfileBloc.instance.close();
    await LMAnalyticsBloc.instance.close();
  }

  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    return lmFeedClient.initiateUser(request)
      ..then((value) async {
        if (value.success) {
          await UserLocalPreference.instance
              .setUserDataFromInitiateUserResponse(value);
        }
        return value;
      });
  }

  Future<MemberStateResponse> getMemberState() async {
    return lmFeedClient.getMemberState()
      ..then((value) async {
        if (value.success) {
          await UserLocalPreference.instance
              .storeMemberRightsFromMemberStateResponse(value);
        }
        return value;
      });
  }
}
