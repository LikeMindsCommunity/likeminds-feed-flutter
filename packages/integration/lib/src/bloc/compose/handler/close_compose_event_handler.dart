import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

closeComposeEventHandler(
    LMFeedComposeCloseEvent event, Emitter<LMFeedComposeState> emitter) {
  LMFeedComposeBloc.instance.postMedia.clear();
  LMFeedComposeBloc.instance.documentCount = 0;
  LMFeedComposeBloc.instance.imageCount = 0;
  LMFeedComposeBloc.instance.videoCount = 0;
  LMFeedComposeBloc.instance.userTags = [];
  LMFeedComposeBloc.instance.selectedTopics = [];
  LMFeedComposeBloc.instance.isPollAdded = false;
  emitter(
    LMFeedComposeInitialState(),
  );
}
