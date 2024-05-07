library likeminds_feed_flutter_core;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/utils/builder/widget_utility.dart';
import 'package:likeminds_feed_flutter_core/src/utils/notification_handler.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';

import 'package:likeminds_feed_flutter_core/src/views/feed/feed_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/feedroom_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/post_detail_screen.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';

export 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';
export 'package:likeminds_feed_flutter_core/src/views/views.dart';
export 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
export 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
export 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart'
    hide kRegexLinksAndTags;
export 'package:likeminds_feed/likeminds_feed.dart';
export 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/index.dart';

class LMFeedCore {
  late final LMFeedClient lmFeedClient;
  LMFeedWidgetUtility _widgetUtility = LMFeedWidgetUtility.instance;

  /// This is the domain of the client. This is used to show
  /// generate link for sharing post
  String? clientDomain;

  late LMFeedConfig feedConfig;

  static LMFeedCore? _instance;

  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  static LMFeedClient get client => instance.lmFeedClient;

  static LMFeedConfig get config => instance.feedConfig;

  static String? get domain => instance.clientDomain;

  static LMFeedThemeData get theme => LMFeedTheme.instance.theme;

  static LMFeedWidgetUtility get widgetUtility => instance._widgetUtility;

  static void showSnackBar(BuildContext context, String snackBarMessage,
      LMFeedWidgetSource widgetSource,
      {LMFeedSnackBarStyle? style}) {
    SnackBar snackBarWidget = LMFeedCore.widgetUtility
        .snackBarBuilder(context, snackBarMessage, widgetSource, style: style);
    ScaffoldMessenger.of(context).showSnackBar(snackBarWidget);
  }

  LMFeedCore._();

  Future<void> initialize({
    LMFeedClient? lmFeedClient,
    String? domain,
    LMFeedConfig? config,
    LMFeedWidgetUtility? widgets,
    LMFeedThemeData? theme,
    Function(LMFeedAnalyticsEventFired)? analyticsListener,
    Function(LMFeedProfileState)? profileListener,
  }) async {
    this.lmFeedClient = lmFeedClient ?? LMFeedClientBuilder().build();

    clientDomain = domain;
    feedConfig = config ?? LMFeedConfig();
    if (widgets != null) _widgetUtility = widgets;
    LMFeedTheme.instance.initialise(theme: theme ?? LMFeedThemeData.light());
    MediaKit.ensureInitialized();
    if (analyticsListener != null)
      LMFeedAnalyticsBloc.instance.stream.listen((LMFeedAnalyticsState event) {
        if (event is LMFeedAnalyticsEventFired) {
          analyticsListener.call(event);
        }
      });
    if (profileListener != null)
      LMFeedProfileBloc.instance.stream.listen((event) {
        profileListener.call(event);
      });
  }

  Future<void> closeBlocs() async {
    await LMFeedPostBloc.instance.close();
    await LMFeedRoutingBloc.instance.close();
    await LMFeedProfileBloc.instance.close();
    await LMFeedAnalyticsBloc.instance.close();
  }

  Future<LMResponse> logout() async {
    LogoutResponse response =
        await lmFeedClient.logout(LogoutRequestBuilder().build());
    return LMResponse(
        success: response.success, errorMessage: response.errorMessage);
  }

  Future<LMResponse> initialiseFeed(ValidateUserRequest request) async {
    ValidateUserResponse validateUserResponse = await validateUser(request);
    if (validateUserResponse.success) {
      MemberStateResponse memberStateResponse = await getMemberState();
      GetCommunityConfigurationsResponse communityConfigurationsResponse =
          await getCommunityConfigurations();

      if (!memberStateResponse.success) {
        return LMResponse(
            success: false, errorMessage: memberStateResponse.errorMessage);
      } else if (!communityConfigurationsResponse.success) {
        return LMResponse(
            success: false,
            errorMessage: communityConfigurationsResponse.errorMessage);
      }
    } else {
      return LMResponse(
          success: false, errorMessage: validateUserResponse.errorMessage);
    }

    return LMResponse(success: true, data: validateUserResponse);
  }

  Future<ValidateUserResponse> validateUser(ValidateUserRequest request) async {
    ValidateUserResponse response = await lmFeedClient.validateUser(request);

    await LMFeedLocalPreference.instance.clearUserData();
    if (response.success) {
      await LMFeedLocalPreference.instance.storeUserData(response.user!);
      LMNotificationHandler.instance.registerDevice(
        response.user!.sdkClientInfo.uuid,
      );
    }

    return response;
  }

  Future<MemberStateResponse> getMemberState() async {
    MemberStateResponse response = await lmFeedClient.getMemberState();
    await LMFeedLocalPreference.instance.clearMemberState();

    if (response.success) {
      await LMFeedLocalPreference.instance.storeMemberState(response);
    }

    return response;
  }

  Future<GetCommunityConfigurationsResponse>
      getCommunityConfigurations() async {
    GetCommunityConfigurationsResponse response =
        await lmFeedClient.getCommunityConfigurations();
    await LMFeedLocalPreference.instance.clearCommunityConfiguration();

    if (response.success) {
      for (CommunityConfigurations conf in response.communityConfigurations!) {
        if (conf.type == 'feed_metadata') {
          String postVar = conf.value?['post'] ?? 'Post';
          String commentVar = conf.value?['comment'] ?? 'Comment';

          LMFeedLocalPreference.instance.storePostVariable(postVar);
          LMFeedLocalPreference.instance.storeCommentVariable(commentVar);
        }
        await LMFeedLocalPreference.instance.storeCommunityConfiguration(conf);
      }
    }

    return response;
  }
}

class LMFeedConfig {
  final LMFeedScreenConfig feedScreenConfig;
  final LMFeedComposeScreenConfig composeConfig;
  final LMPostDetailScreenConfig postDetailConfig;
  final LMFeedRoomScreenConfig feedRoomScreenConfig;
  final SystemUiOverlayStyle? globalSystemOverlayStyle;

  LMFeedConfig({
    this.feedScreenConfig = const LMFeedScreenConfig(),
    this.composeConfig = const LMFeedComposeScreenConfig(),
    this.postDetailConfig = const LMPostDetailScreenConfig(),
    this.feedRoomScreenConfig = const LMFeedRoomScreenConfig(),
    this.globalSystemOverlayStyle,
  });

  LMFeedConfig copyWith({
    LMFeedScreenConfig? config,
    LMFeedComposeScreenConfig? composeConfig,
    LMPostDetailScreenConfig? postDetailConfig,
    LMFeedRoomScreenConfig? feedRoomScreenConfig,
  }) {
    return LMFeedConfig(
      feedScreenConfig: config ?? feedScreenConfig,
      composeConfig: composeConfig ?? this.composeConfig,
      postDetailConfig: postDetailConfig ?? this.postDetailConfig,
      feedRoomScreenConfig: feedRoomScreenConfig ?? this.feedRoomScreenConfig,
    );
  }
}
