library likeminds_feed_flutter_core;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:media_kit/media_kit.dart';

export 'package:likeminds_feed_flutter_core/src/views/views.dart';
export 'package:likeminds_feed_flutter_core/src/utils/constants/constants.dart';
export 'package:likeminds_feed_flutter_core/src/bloc/lm_bloc.dart';
export 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';

class LMFeedCore {
  late final LMFeedClient lmFeedClient;
  late final LMFeedMediaService? media;

  static LMFeedCore? _instance;

  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  static LMFeedClient get client => instance.lmFeedClient;

  LMFeedCore._();

  Future<void> initialize({
    required LMFeedClient lmFeedClient,
    ThemeData? theme,
  }) async {
    this.lmFeedClient = lmFeedClient;
    media = LMFeedMediaService(bucketName: "", poolId: "");
    await LMFeedUserLocalPreference.instance.initialize();
    MediaKit.ensureInitialized();
    await LMFeedUserLocalPreference.instance.initialize();
    if (theme != null) {
      LMThemeData.instance.setTheme = theme;
    }
  }

  Future<void> closeBlocs() async {
    await LMFeedPostBloc.instance.close();
    await LMFeedRoutingBloc.instance.close();
    await LMFeedProfileBloc.instance.close();
    await LMFeedAnalyticsBloc.instance.close();
  }

  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    return lmFeedClient.initiateUser(request)
      ..then((value) async {
        if (value.success) {
          await LMFeedUserLocalPreference.instance
              .setUserDataFromInitiateUserResponse(value);
        }
        return value;
      });
  }

  Future<MemberStateResponse> getMemberState() async {
    return lmFeedClient.getMemberState()
      ..then((value) async {
        if (value.success) {
          await LMFeedUserLocalPreference.instance
              .storeMemberRightsFromMemberStateResponse(value);
        }
        return value;
      });
  }
}
