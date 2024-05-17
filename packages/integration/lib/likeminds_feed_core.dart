library likeminds_feed_flutter_core;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
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
  LMSDKCallbackImplementation? sdkCallback;
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
    String? domain,
    LMFeedConfig? config,
    LMFeedWidgetUtility? widgets,
    LMFeedThemeData? theme,
    Function(LMFeedAnalyticsEventFired)? analyticsListener,
    Function(LMFeedProfileState)? profileListener,
    LMFeedCoreCallback? lmFeedCallback,
  }) async {
    LMFeedClientBuilder clientBuilder = LMFeedClientBuilder();
    this.sdkCallback =
        LMSDKCallbackImplementation(lmFeedCallback: lmFeedCallback);
    clientBuilder.sdkCallback(this.sdkCallback);

    this.lmFeedClient = clientBuilder.build();

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

  /// This function is used to logout the user session.
  /// It will clear the user data from the local preference.
  /// It will also clear the member state and community configurations from the local preference.
  Future<LMResponse> logout() async {
    LogoutResponse response =
        await lmFeedClient.logout(LogoutRequestBuilder().build());
    return LMResponse(
        success: response.success, errorMessage: response.errorMessage);
  }

  /// This function is the starting point of the feed.
  /// It must be executed before displaying the feed screen or accessing any other [LMFeedCore] widgets or screens.
  /// The [accessToken] and [refreshToken] parameters are required to show the feed screen.
  /// If the [accessToken] and [refreshToken] parameters are not provided, the function will fetch them from the local preference.
  Future<LMResponse> showFeedWithoutApiKey({
    String? accessToken,
    String? refreshToken,
  }) async {
    String? newAccessToken;
    String? newRefreshToken;
    if (accessToken == null || refreshToken == null) {
      newAccessToken = LMFeedLocalPreference.instance
          .fetchCache(LMFeedStringConstants.instance.accessToken)
          ?.value;

      newRefreshToken = LMFeedLocalPreference.instance
          .fetchCache(LMFeedStringConstants.instance.refreshToken)
          ?.value;
    } else {
      newAccessToken = accessToken;
      newRefreshToken = refreshToken;
    }

    if (newAccessToken == null || newRefreshToken == null) {
      return LMResponse(
          success: false,
          errorMessage: "Access token and Refresh token are required");
    }

    ValidateUserRequest request = (ValidateUserRequestBuilder()
          ..accessToken(newAccessToken)
          ..refreshToken(newRefreshToken))
        .build();

    ValidateUserResponse? validateUserResponse =
        (await validateUser(request)).data;

    if (validateUserResponse == null) {
      return LMResponse(success: false, errorMessage: "User validation failed");
    }

    if (validateUserResponse.success) {
      LMNotificationHandler.instance.registerDevice(
        validateUserResponse.user!.sdkClientInfo.uuid,
      );

      // Call member state and community configurations and store them in local preference
      LMResponse initialiseFeedResponse = await initialiseFeed();

      if (!initialiseFeedResponse.success) {
        return LMResponse(
          success: false,
          errorMessage: initialiseFeedResponse.errorMessage,
        );
      }
    } else {
      return LMResponse(
          success: false, errorMessage: validateUserResponse.errorMessage);
    }

    return LMResponse(success: true, data: validateUserResponse);
  }

  /// This function is used to validate the user session. using the [accessToken] and [refreshToken] parameters.
  Future<LMResponse<ValidateUserResponse>> validateUser(
      ValidateUserRequest request) async {
    ValidateUserResponse response = await lmFeedClient.validateUser(request);

    if (response.success) {
      return LMResponse(success: true, data: response);
    } else {
      return LMResponse(
          success: false, data: response, errorMessage: response.errorMessage);
    }
  }

  /// This function is used to fetch the member state and community configurations.
  Future<LMResponse> initialiseFeed() async {
    MemberStateResponse memberStateResponse = await _getMemberState();
    GetCommunityConfigurationsResponse communityConfigurationsResponse =
        await _getCommunityConfigurations();

    if (!memberStateResponse.success) {
      return LMResponse(
          success: false, errorMessage: memberStateResponse.errorMessage);
    } else if (!communityConfigurationsResponse.success) {
      return LMResponse(
          success: false,
          errorMessage: communityConfigurationsResponse.errorMessage);
    }

    return LMResponse(success: true);
  }

  /// This function is the starting point of the feed.
  /// It must be executed before displaying the feed screen or accessing any other [LMFeedCore] widgets or screens.
  Future<LMResponse> showFeedWithApiKey({
    required String apiKey,
    required String uuid,
    required String userName,
    String? imageUrl,
    String? isGuest,
  }) async {
    String? newAccessToken;
    String? newRefreshToken;

    newAccessToken = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.instance.accessToken)
        ?.value;

    newRefreshToken = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.instance.refreshToken)
        ?.value;

    if (newAccessToken == null || newRefreshToken == null) {
      InitiateUserRequest initiateUserRequest = (InitiateUserRequestBuilder()
            ..apiKey(apiKey)
            ..userName(userName)
            ..uuid(uuid))
          .build();

      LMResponse<InitiateUserResponse> initiateUserResponse =
          await initiateUser(initiateUserRequest: initiateUserRequest);
      if (initiateUserResponse.success) {
        // Call member state and community configurations and store them in local preference
        LMResponse initialiseFeedResponse = await initialiseFeed();
        if (!initialiseFeedResponse.success) {
          return LMResponse(
              success: false,
              errorMessage: initialiseFeedResponse.errorMessage);
        }
      }

      return initiateUserResponse;
    } else {
      return await showFeedWithoutApiKey(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
    }
  }

  /// This function is used to initiate a new user session.
  Future<LMResponse<InitiateUserResponse>> initiateUser(
      {required InitiateUserRequest initiateUserRequest}) async {
    if (initiateUserRequest.apiKey == null ||
        initiateUserRequest.uuid == null ||
        initiateUserRequest.userName == null) {
      return LMResponse(
          success: false,
          errorMessage: "ApiKey, UUID and Username are required");
    } else {
      InitiateUserResponse initiateUserResponse =
          await lmFeedClient.initiateUser(initiateUserRequest);

      if (!initiateUserResponse.success) {
        return LMResponse(
            success: false, errorMessage: initiateUserResponse.errorMessage);
      } else {
        return LMResponse(success: true, data: initiateUserResponse);
      }
    }
  }

  Future<MemberStateResponse> _getMemberState() async {
    MemberStateResponse response = await lmFeedClient.getMemberState();

    if (response.success) {
      await LMFeedLocalPreference.instance.clearMemberState();
      await LMFeedLocalPreference.instance.storeMemberState(response);
    }

    return response;
  }

  Future<GetCommunityConfigurationsResponse>
      _getCommunityConfigurations() async {
    GetCommunityConfigurationsResponse response =
        await lmFeedClient.getCommunityConfigurations();

    if (response.success) {
      await LMFeedLocalPreference.instance.clearCommunityConfiguration();
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
