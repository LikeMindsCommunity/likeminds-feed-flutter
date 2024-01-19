import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_document_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_link_preview_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_video_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/close_compose_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/remove_attahment_event_handler.dart';
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
  int imageCount = 0;
  int videoCount = 0;
  int documentCount = 0;
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
      ),
    );
    on<LMFeedComposeAddVideoEvent>(
      (event, emitter) => addVideoEventHandler(
        event,
        emitter,
      ),
    );
    on<LMFeedComposeAddDocumentEvent>(
      (event, emitter) => addDocumentEventHandler(
        event,
        emitter,
      ),
    );
    on<LMFeedComposeAddLinkPreviewEvent>(
      (event, emitter) => addLinkPreviewEventHandler(
        event,
        emitter,
      ),
    );
    on<LMFeedComposeRemoveAttachmentEvent>(
      (
        event,
        emitter,
      ) =>
          removeAttachmentEventHandler(
        event,
        emitter,
      ),
    );
    on<LMFeedComposeCloseEvent>(
      (event, emitter) => closeComposeEventHandler(
        event,
        emitter,
      ),
    );
  }
}
