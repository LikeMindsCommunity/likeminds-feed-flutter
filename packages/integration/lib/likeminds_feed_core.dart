library likeminds_feed_flutter_core;

import 'package:flutter/material.dart';
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
  bool initiateUserCalled = false;
  LMFeedWidgetUtility _widgetUtility = LMFeedWidgetUtility.instance;
  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  /// This is stream is used to listen to
  /// deep links while the app is in active state
  StreamSubscription? deepLinkStreamListener;

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

  static void showSnackBar(LMFeedSnackBar snackBar) {
    snackBar = snackBar.copyWith(style: theme.snackBarTheme);
    instance._scaffoldMessengerKey?.currentState?.showSnackBar(snackBar);
  }

  static GlobalKey<ScaffoldMessengerState>? get scaffoldMessengerKey =>
      instance._scaffoldMessengerKey;

  static set deepLinkStream(StreamSubscription deepLinkStream) =>
      instance.deepLinkStreamListener = deepLinkStream;

  LMFeedCore._();

  Future<void> initialize({
    required LMFeedClient lmFeedClient,
    String? domain,
    LMFeedConfig? config,
    LMFeedWidgetUtility? widgets,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
    LMFeedThemeData? theme,
  }) async {
    this.lmFeedClient = lmFeedClient;
    clientDomain = domain;
    feedConfig = config ?? LMFeedConfig();
    if (widgets != null) _widgetUtility = widgets;
    _scaffoldMessengerKey = scaffoldMessengerKey;
    LMFeedTheme.instance.initialise(theme: theme ?? LMFeedThemeData.light());
    MediaKit.ensureInitialized();
  }

  Future<void> closeBlocs() async {
    await LMFeedPostBloc.instance.close();
    await LMFeedRoutingBloc.instance.close();
    await LMFeedProfileBloc.instance.close();
    await LMFeedAnalyticsBloc.instance.close();
  }

  Future<ValidateUserResponse> validateUser(ValidateUserRequest request) async {
    ValidateUserResponse response = await lmFeedClient.validateUser(request);

    await LMFeedLocalPreference.instance.clearUserData();
    if (response.success) {
      initiateUserCalled = true;
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
}

class LMFeedConfig {
  final LMFeedScreenConfig feedScreenConfig;
  final LMFeedComposeScreenConfig composeConfig;
  final LMPostDetailScreenConfig postDetailConfig;

  LMFeedConfig({
    this.feedScreenConfig = const LMFeedScreenConfig(),
    this.composeConfig = const LMFeedComposeScreenConfig(),
    this.postDetailConfig = const LMPostDetailScreenConfig(),
  });

  LMFeedConfig copyWith({
    LMFeedScreenConfig? config,
    LMFeedComposeScreenConfig? composeConfig,
    LMPostDetailScreenConfig? postDetailConfig,
  }) {
    return LMFeedConfig(
      feedScreenConfig: config ?? feedScreenConfig,
      composeConfig: composeConfig ?? this.composeConfig,
      postDetailConfig: postDetailConfig ?? this.postDetailConfig,
    );
  }
}
