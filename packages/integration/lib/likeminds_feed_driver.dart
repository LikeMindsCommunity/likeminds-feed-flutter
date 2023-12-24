library likeminds_feed_driver_fl;

import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing_bloc/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

export 'package:likeminds_feed_driver_fl/src/views/views.dart';

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
}
