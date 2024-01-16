import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_video_event_handler.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'handler/compose_topic_event_handler.dart';
import 'handler/add_image_event_handler.dart';

part 'compose_event.dart';
part 'compose_state.dart';

class LMFeedComposeBloc extends Bloc<LMFeedComposeEvent, LMFeedComposeState> {
  static LMFeedComposeBloc? _bloc;

  static LMFeedComposeBloc get instance => _bloc ??= LMFeedComposeBloc._();

  /// Lists to maintain throughout the screen for sending/receiving data
  List<LMMediaModel> postMedia = [];
  List<LMUserTagViewData> userTags = [];
  List<LMTopicViewData> selectedTopics = [];

  LMFeedComposeBloc._() : super(LMFeedComposeInitialState()) {
    on<LMFeedComposeFetchTopicsEvent>(
      (event, emitter) => composeFetchTopicHandler(
        event,
        emitter,
      ),
    );
    on<LMFeedComposeAddImageEvent>(
      (event, emitter) => addImageEventHandler(
        event,
        emitter,
        postMedia.length,
      ),
    );
    on<LMFeedComposeAddVideoEvent>(
      (event, emitter) => addVideoEventHandler(
        event,
        emitter,
        postMedia.length,
      ),
    );
    on<LMFeedComposeCloseEvent>(
        (event, emit) => emit(LMFeedComposeInitialState()));
  }
}
