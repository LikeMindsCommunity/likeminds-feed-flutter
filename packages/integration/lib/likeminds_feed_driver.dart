library likeminds_feed_driver_fl;

import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing_bloc/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

class LMFeedBloc {
  late final LMPostBloc lmPostBloc;
  late final LMFeedClient lmFeedClient;
  late final MediaService mediaService;
  late final LMRoutingBloc lmRoutingBloc;
  late final LMProfileBloc lmProfileBloc;
  late final LMAnalyticsBloc lmAnalyticsBloc;

  static LMFeedBloc? _instance;

  static LMFeedBloc get() => _instance ??= LMFeedBloc._();

  LMFeedBloc._();

  void initialize(
      {required LMFeedClient lmFeedClient,
      required MediaService mediaService}) {
    this.lmFeedClient = lmFeedClient;
    lmPostBloc = LMPostBloc();
    this.mediaService = mediaService;
    lmRoutingBloc = LMRoutingBloc();
    lmProfileBloc = LMProfileBloc();
    lmAnalyticsBloc = LMAnalyticsBloc();
  }
}
