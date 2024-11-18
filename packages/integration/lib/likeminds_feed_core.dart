library likeminds_feed_flutter_core;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/builder/feed_builder_delegate.dart';
import 'package:likeminds_feed_flutter_core/src/services/media_service.dart';

import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';

import 'package:likeminds_feed_flutter_core/src/views/views.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';

export 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';
export 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';
export 'package:likeminds_feed_flutter_core/src/utils/web/web_scroll_behavior.dart';
export 'package:likeminds_feed_flutter_core/src/views/views.dart';
export 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
export 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
export 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart'
    hide kRegexLinksAndTags;
export 'package:likeminds_feed/likeminds_feed.dart';
export 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/index.dart';
export 'package:likeminds_feed_flutter_core/src/builder/feed_builder_delegate.dart';
export 'package:likeminds_feed_flutter_core/src/services/media_service.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/default/default_widgets.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/feed/top_response.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/feed/add_comment.dart';
export 'package:likeminds_feed_flutter_core/src/widgets/feed/qna_footer.dart';

/// {@template lm_feed_core}
/// This class is the core of the feed.
/// It is used to initialize the feed and configure the feed screens.
///
/// This class represents the core functionality of the LikeMinds feed.
///
/// It provides methods and properties to interact with the feed data.
///
/// {@endtemplate}
class LMFeedCore {
  late final LMFeedClient lmFeedClient;
  LMSDKCallbackImplementation? lmFeedSdkCallback;
  LMFeedCoreCallback? lmFeedCoreCallback;
  late LMFeedBuilderDelegate _feedBuilderDelegate;
  LMFeedWidgetUtility _widgetUtility = LMFeedWidgetUtility.instance;

  /// This is the domain of the client. This is used to show
  /// generate link for sharing post
  String? clientDomain;

  late LMFeedConfig feedConfig;

  static LMFeedCore? _instance;

  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  static LMFeedClient get client => instance.lmFeedClient;

  static LMFeedConfig get config => instance.feedConfig;

  static LMFeedWebConfiguration get webConfiguration =>
      instance.feedConfig.webConfiguration;

  static set config(LMFeedConfig value) {
    instance.feedConfig = value;
  }

  static String? get domain => instance.clientDomain;

  static LMFeedThemeData get theme => LMFeedTheme.instance.theme;

  static set theme(LMFeedThemeData value) {
    LMFeedTheme.instance.initialise(theme: value);
  }

  static LMFeedWidgetUtility get widgetUtility => instance._widgetUtility;

  static set widgetUtility(LMFeedWidgetUtility value) {
    instance._widgetUtility = value;
  }

  static LMFeedBuilderDelegate get feedBuilderDelegate =>
      instance._feedBuilderDelegate;

  static void showSnackBar(BuildContext context, String snackBarMessage,
      LMFeedWidgetSource widgetSource,
      {LMFeedSnackBarStyle? style}) {
    SnackBar snackBarWidget = LMFeedCore.widgetUtility
        .snackBarBuilder(context, snackBarMessage, widgetSource, style: style);
    ScaffoldMessenger.of(context).showSnackBar(snackBarWidget);
  }

  LMFeedCore._();

  Future<LMResponse<void>> initialize({
    String? domain,
    LMFeedConfig? config,
    LMFeedWidgetUtility? widgets,
    LMFeedThemeData? theme,
    Function(LMFeedAnalyticsEventFired)? analyticsListener,
    Function(LMFeedProfileState)? profileListener,
    LMFeedCoreCallback? lmFeedCallback,
    LMFeedBuilderDelegate? builderDelegate,
    SystemUiOverlayStyle? systemUiOverlayStyle,
  }) async {
    try {
      if (kIsWeb) {
        SystemChrome.setSystemUIOverlayStyle(
            systemUiOverlayStyle ?? SystemUiOverlayStyle.dark);
      }
      LMFeedMediaService.instance;

      LMFeedClientBuilder clientBuilder = LMFeedClientBuilder();
      this.lmFeedCoreCallback = lmFeedCallback;
      this.lmFeedSdkCallback =
          LMSDKCallbackImplementation(lmFeedCallback: lmFeedCallback);
      clientBuilder.sdkCallback(this.lmFeedSdkCallback);

      this.lmFeedClient = clientBuilder.build();

      LMResponse initResponse = await this.lmFeedClient.init();

      if (!initResponse.success) {
        return initResponse;
      }

      clientDomain = domain;
      feedConfig = config ?? LMFeedConfig();
      if (widgets != null) _widgetUtility = widgets;
      LMFeedTheme.instance.initialise(theme: theme ?? LMFeedThemeData.light());
      MediaKit.ensureInitialized();
      if (analyticsListener != null)
        LMFeedAnalyticsBloc.instance.stream
            .listen((LMFeedAnalyticsState event) {
          if (event is LMFeedAnalyticsEventFired) {
            analyticsListener.call(event);
          }
        });
      if (profileListener != null)
        LMFeedProfileBloc.instance.stream.listen((event) {
          profileListener.call(event);
        });

      _feedBuilderDelegate = builderDelegate ?? LMFeedBuilderDelegate();

      return LMResponse(success: true);
    } catch (e) {
      return LMResponse(success: false, errorMessage: e.toString());
    }
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
          .fetchCache(LMFeedStringConstants.accessToken)
          ?.value;

      newRefreshToken = LMFeedLocalPreference.instance
          .fetchCache(LMFeedStringConstants.refreshToken)
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
      response.community?.communitySettings?.forEach((element) {
        if (element.settingType == LMFeedStringConstants.postApprovalNeeded) {
          LMFeedPostUtils.doPostNeedsApproval = element.enabled;
        }
      });
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
    String? uuid,
    String? userName,
    String? imageUrl,
    bool isGuest = false,
  }) async {
    String? newAccessToken;
    String? newRefreshToken;

    newAccessToken = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.accessToken)
        ?.value;

    newRefreshToken = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.refreshToken)
        ?.value;

    if (newAccessToken == null || newRefreshToken == null) {
      // check if not a guest user and uuid or username is not provided
      if (!isGuest && (uuid == null || userName == null)) {
        return LMResponse(
            success: false,
            errorMessage: "UUID and Username are required for non-guest user");
      }
      InitiateUserRequestBuilder initiateUserRequestBuilder =
          (InitiateUserRequestBuilder()..apiKey(apiKey));

      // if uuid is not null, then set uuid
      if (uuid != null) {
        initiateUserRequestBuilder.uuid(uuid);
      }
      // if userName is not null, then set userName
      if (userName != null) {
        initiateUserRequestBuilder.userName(userName);
      }
      // if imageUrl is not null, then set imageUrl
      if (imageUrl != null) {
        initiateUserRequestBuilder.imageUrl(imageUrl);
      }
      // if isGuest is not null and true, then set isGuest to true
      if (isGuest) {
        initiateUserRequestBuilder.isGuest(isGuest);
      }

      LMResponse<InitiateUserResponse> initiateUserResponse =
          await initiateUser(
        initiateUserRequest: initiateUserRequestBuilder.build(),
      );
      if (initiateUserResponse.success) {
        LMNotificationHandler.instance.registerDevice(
          initiateUserResponse.data!.user!.sdkClientInfo.uuid,
        );
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
        initiateUserResponse.community?.communitySettings?.forEach((element) {
          if (element.settingType == LMFeedStringConstants.postApprovalNeeded) {
            LMFeedPostUtils.doPostNeedsApproval = element.enabled;
          }
        });
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

enum LMFeedThemeType {
  social,
  qna,
}

/// {@template lm_feed_config}
/// This class is used to configure the feed screens.
/// {@endtemplate}
class LMFeedConfig {
  final LMFeedScreenConfig feedScreenConfig;
  final LMFeedComposeScreenConfig composeConfig;
  final LMPostDetailScreenConfig postDetailConfig;
  final LMFeedRoomScreenConfig feedRoomScreenConfig;
  final SystemUiOverlayStyle? globalSystemOverlayStyle;
  final LMFeedWebConfiguration webConfiguration;
  final LMFeedThemeType feedThemeType;

  /// {@macro lm_feed_config}
  LMFeedConfig({
    this.feedScreenConfig = const LMFeedScreenConfig(),
    this.composeConfig = const LMFeedComposeScreenConfig(),
    this.postDetailConfig = const LMPostDetailScreenConfig(),
    this.feedRoomScreenConfig = const LMFeedRoomScreenConfig(),
    this.webConfiguration = const LMFeedWebConfiguration(),
    this.globalSystemOverlayStyle,
    this.feedThemeType = LMFeedThemeType.social,
  });

  /// {@template lm_feed_config_copywith}
  /// [copyWith] to create a new instance of [LMFeedConfig]
  /// with the provided values
  /// {@endtemplate}
  LMFeedConfig copyWith({
    LMFeedScreenConfig? config,
    LMFeedComposeScreenConfig? composeConfig,
    LMPostDetailScreenConfig? postDetailConfig,
    LMFeedRoomScreenConfig? feedRoomScreenConfig,
    SystemUiOverlayStyle? globalSystemOverlayStyle,
    LMFeedWebConfiguration? webConfiguration,
    LMFeedThemeType? feedThemeType,
  }) {
    return LMFeedConfig(
      feedScreenConfig: config ?? feedScreenConfig,
      composeConfig: composeConfig ?? this.composeConfig,
      postDetailConfig: postDetailConfig ?? this.postDetailConfig,
      feedRoomScreenConfig: feedRoomScreenConfig ?? this.feedRoomScreenConfig,
      globalSystemOverlayStyle:
          globalSystemOverlayStyle ?? this.globalSystemOverlayStyle,
      webConfiguration: webConfiguration ?? this.webConfiguration,
      feedThemeType: feedThemeType ?? this.feedThemeType,
    );
  }
}
