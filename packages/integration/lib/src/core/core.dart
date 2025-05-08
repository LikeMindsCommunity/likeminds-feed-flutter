import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_config.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/widget_source.dart';
import 'package:likeminds_feed_flutter_core/src/services/media_service.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:media_kit/media_kit.dart';

// export all the core files
export 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
export 'package:likeminds_feed_flutter_core/src/core/configurations/feed_config.dart';
export 'package:likeminds_feed_flutter_core/src/core/configurations/widget_source.dart';

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
  /// Instance of the [LMFeedClient] class.
  /// This is used to interact with the feed data.
  late final LMFeedClient lmFeedClient;

  /// Instance of the [LMFeedConfig] class.
  /// This is used to configure the customization of the feed.
  late LMFeedConfig _config;

  /// Instance of the [LMSDKCallbackImplementation] class.
  /// This is used to access the data layer callback functions.
  LMSDKCallbackImplementation? lmFeedSdkCallback;

  /// Instance of the [LMFeedCoreCallback] class.
  /// This is used to access the core callback functions.
  LMFeedCoreCallback? lmFeedCoreCallback;

  // late LMFeedBuilderDelegate _feedBuilderDelegate;

  /// This is the domain of the client. This is used to show
  /// generate link for sharing post
  String? _clientDomain;

  // holds the instance of the [LMFeedCore] class
  static LMFeedCore? _instance;

  // private constructor for the [LMFeedCore] class
  // to make it singleton
  LMFeedCore._();

  /// get the singleton instance of the [LMFeedCore] class
  static LMFeedCore get instance => _instance ??= LMFeedCore._();

  /// get [LMFeedClient] instance from the [LMFeedCore] class
  static LMFeedClient get client => instance.lmFeedClient;

  /// get [LMFeedConfig] instance from the [LMFeedCore] class
  static LMFeedConfig get config => instance._config;

  /// get domain from the [LMFeedCore] class
  static String? get domain => instance._clientDomain;

  /// get [LMFeedThemeData] instance from the [LMFeedCore] class
  static LMFeedThemeData get theme => LMFeedTheme.instance.theme;

  /// set [LMFeedConfig] instance from the [LMFeedCore] class
  static set config(LMFeedConfig value) {
    instance._config = value;
  }

  /// set domain from the [LMFeedCore] class
  static set domain(String? value) {
    instance._clientDomain = value;
  }

  /// set [LMFeedThemeData] instance from the [LMFeedCore] class
  static set theme(LMFeedThemeData value) {
    LMFeedTheme.instance.initialise(theme: value);
  }

  /// This function is used to show the snackbar.
  /// It will show the snackbar with the provided [snackBarMessage] and [widgetSource].
  static void showSnackBar(BuildContext context, String snackBarMessage,
      LMFeedWidgetSource widgetSource,
      {LMFeedSnackBarStyle? style}) {
    SnackBar snackBarWidget = LMFeedCore.config.widgetBuilderDelegate
        .snackBarBuilder(context, snackBarMessage, widgetSource, style: style);
    ScaffoldMessenger.of(context).showSnackBar(snackBarWidget);
  }

  /// This function is used to initialize the feed, It is the starting point of the feed.
  /// Essentially, It is used to setup the feed with the configurations, theme, analytics listener, profile listener, system ui overlay style, etc.
  /// It must be executed before displaying the feed screen or accessing any other [LMFeedCore] widgets, screens and functions.
  Future<LMResponse<void>> initialize({
    String? domain,
    LMFeedConfig? config,
    LMFeedThemeData? theme,
    Function(LMFeedAnalyticsEventFired)? analyticsListener,
    Function(LMFeedProfileState)? profileListener,
    LMFeedCoreCallback? lmFeedCallback,
    SystemUiOverlayStyle? systemUiOverlayStyle,
  }) async {
    try {
      // set the system ui overlay style
      if (kIsWeb) {
        SystemChrome.setSystemUIOverlayStyle(
            systemUiOverlayStyle ?? SystemUiOverlayStyle.dark);
      }
      // initialize the feed media service
      LMFeedMediaService.instance;
      // create a new instance of the [LMFeedClientBuilder] class and set the sdk callback
      LMFeedClientBuilder clientBuilder = LMFeedClientBuilder();
      this.lmFeedCoreCallback = lmFeedCallback;
      this.lmFeedSdkCallback =
          LMSDKCallbackImplementation(lmFeedCallback: lmFeedCallback);
      clientBuilder.sdkCallback(this.lmFeedSdkCallback);

      this.lmFeedClient = clientBuilder.build();

      // initialize the feed client
      LMResponse initResponse = await this.lmFeedClient.init();

      // if the initialization is not successful, return the response
      if (!initResponse.success) {
        return initResponse;
      }
      // set domain, config and theme
      _clientDomain = domain;
      _config = config ?? LMFeedConfig();
      LMFeedTheme.instance.initialise(theme: theme ?? LMFeedThemeData.light());

      // initialize media kit
      MediaKit.ensureInitialized();

      // set analytics listener and profile listener
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
      return LMResponse(success: true);
    } catch (e) {
      return LMResponse(success: false, errorMessage: e.toString());
    }
  }

  /// This function is used to closes all the blocs used in the feed.
  Future<void> closeBlocs() async {
    await LMFeedPostBloc.instance.close();
    await LMFeedRoutingBloc.instance.close();
    await LMFeedProfileBloc.instance.close();
    await LMFeedAnalyticsBloc.instance.close();
  }

  /// This function is used to logout the user session.
  /// It will clear the user data from the local preference.
  /// It will also clear the member state and community configurations from the local preference.
  /// It must be called before logging in with a new user.
  Future<LMResponse> logout() async {
    // create a logout request builder
    final LogoutRequestBuilder requestBuilder = LogoutRequestBuilder();
    // get the refresh token from the local preference
    final String? refreshToken = LMFeedLocalPreference.instance
        .fetchCache(LMFeedStringConstants.refreshToken)
        ?.value;
    // get the device id from the notification handler
    final String? deviceId = LMNotificationHandler.instance.deviceId;
    // set the refresh token and device id in the request builder
    if (refreshToken != null) {
      requestBuilder.refreshToken(refreshToken);
    }
    if (deviceId != null) {
      requestBuilder.deviceId(deviceId);
    }
    // call the logout function from the client
    LogoutResponse response = await lmFeedClient.logout(requestBuilder.build());
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
    // setting up the logger
    InitiateLoggerRequestBuilder initiateLoggerRequestBuilder =
        (InitiateLoggerRequestBuilder()
          ..coreVersion(LMFeedStringConstants.coreVersion)
          ..errorHandler((e, _) {})
          ..logLevel(Severity.ERROR)
          ..shareLogsWithLM(true));

    await LMFeedPersistence.instance
        .init(request: initiateLoggerRequestBuilder.build());
    await LMFeedPersistence.instance.flushLogs();
    //end of logger setup

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

    // setting up the logger

    InitiateLoggerRequestBuilder initiateLoggerRequestBuilder =
        (InitiateLoggerRequestBuilder()
          ..coreVersion(LMFeedStringConstants.coreVersion)
          ..errorHandler((e, _) {})
          ..logLevel(Severity.ERROR)
          ..shareLogsWithLM(true));

    await LMFeedPersistence.instance
        .init(request: initiateLoggerRequestBuilder.build());

    await LMFeedPersistence.instance.flushLogs();

    //end of logger setup

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
