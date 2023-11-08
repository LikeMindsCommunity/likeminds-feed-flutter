library likeminds_feed_bloc_fl;

import 'package:likeminds_feed_bloc_fl/src/bloc/lm_post_bloc/lm_post_bloc.dart';
import 'package:likeminds_feed_bloc_fl/src/services/media_service.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

export 'src/bloc/lm_post_bloc/lm_post_bloc.dart';
export 'src/services/media_service.dart';
export 'src/constants/analytics/keys.dart';

class LMFeedBloc{
  late final LMPostBloc lmPostBloc;
  late final LMFeedClient lmFeedClient;
  late final MediaService mediaService;

  static LMFeedBloc? _instance;

  static LMFeedBloc get() => _instance ??= LMFeedBloc._();

  LMFeedBloc._();

  void initialize({required LMFeedClient lmFeedClient, required MediaService mediaService}) {
    this.lmFeedClient =  lmFeedClient;
    lmPostBloc = LMPostBloc();
    this.mediaService = mediaService;
  }
}