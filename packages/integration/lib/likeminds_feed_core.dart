library likeminds_feed_driver_fl;

import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/utils/persistence/user_local_preference.dart';
import 'package:media_kit/media_kit.dart';

export 'package:likeminds_feed_driver_fl/src/views/views.dart';
export 'package:likeminds_feed_driver_fl/src/utils/persistence/user_local_preference.dart';

class LMFeedCore {
  late final LMFeedClient lmFeedClient;
  late final LMMediaService? mediaService;

  static LMFeedCore? _instance;

  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  static LMFeedClient get client => instance.lmFeedClient;

  LMFeedCore._();

  Future<void> initialize({
    required LMFeedClient lmFeedClient,
  }) async {
    this.lmFeedClient = lmFeedClient;
    mediaService = LMMediaService(bucketName: "", poolId: "");
    await LMUserLocalPreference.instance.initialize();
    MediaKit.ensureInitialized();
    await LMUserLocalPreference.instance.initialize();
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
          await LMUserLocalPreference.instance
              .setUserDataFromInitiateUserResponse(value);
        }
        return value;
      });
  }

  Future<MemberStateResponse> getMemberState() async {
    return lmFeedClient.getMemberState()
      ..then((value) async {
        if (value.success) {
          await LMUserLocalPreference.instance
              .storeMemberRightsFromMemberStateResponse(value);
        }
        return value;
      });
  }
}
