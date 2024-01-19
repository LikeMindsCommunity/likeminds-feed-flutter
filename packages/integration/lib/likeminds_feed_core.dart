library likeminds_feed_flutter_core;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:media_kit/media_kit.dart';

export 'package:likeminds_feed_flutter_core/src/views/views.dart';
export 'package:likeminds_feed_flutter_core/src/utils/constants/constants.dart';
export 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
export 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
export 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
export 'package:likeminds_feed/likeminds_feed.dart';
export 'package:likeminds_feed_flutter_core/src/utils/deep_link/deep_link_handler.dart';
export 'package:likeminds_feed_flutter_core/src/utils/notification_handler.dart';
export 'package:likeminds_feed_flutter_core/src/utils/post/post_utils.dart';

class LMFeedCore {
  late final LMFeedClient lmFeedClient;
  late final LMFeedMediaService? mediaService;

  /// This is the domain of the client. This is used to show
  /// generate link for sharing post
  String? clientDomain;

  static LMFeedCore? _instance;

  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  static LMFeedClient get client => instance.lmFeedClient;
  static LMFeedMediaService get media => instance.mediaService!;

  static String? get domain => instance.clientDomain;

  LMFeedCore._();

  Future<void> initialize({
    String? apiKey,
    LMFeedClient? lmFeedClient,
    ThemeData? theme,
    String? domain,
  }) async {
    assert(apiKey != null || lmFeedClient != null);
    this.lmFeedClient =
        lmFeedClient ?? (LMFeedClientBuilder()..apiKey(apiKey!)).build();
    clientDomain = domain;
    mediaService = LMFeedMediaService(false);
    await LMFeedUserLocalPreference.instance.initialize();
    MediaKit.ensureInitialized();
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
      ..then(
        (value) async {
          if (value.success) {
            await LMFeedUserLocalPreference.instance
                .storeMemberRightsFromMemberStateResponse(value);
          }
          return value;
        },
      );
  }
}
