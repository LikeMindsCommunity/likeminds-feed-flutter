import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_document_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_link_preview_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/add_video_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/close_compose_event_handler.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/handler/remove_attahment_event_handler.dart';

import 'package:equatable/equatable.dart';

import 'handler/compose_topic_event_handler.dart';
import 'handler/add_image_event_handler.dart';
part 'handler/add_poll_event_handler.dart';

part 'compose_event.dart';
part 'compose_state.dart';

/// {@template lm_feed_compose_bloc}
/// [LMFeedComposeBloc] handles all the post creation and
/// edition related actions
/// like attaching media to a post, adding topics,
/// add link preview to a link present in post etc.
/// [LMFeedComposeEvent] defines the events which are handled by this bloc.
/// [LMFeedComposeState] defines the states which are emitted by this bloc
/// {@endtemplate}
class LMFeedComposeBloc extends Bloc<LMFeedComposeEvent, LMFeedComposeState> {
  static LMFeedComposeBloc? _bloc;

  /// {@macro lm_feed_compose_bloc}
  static LMFeedComposeBloc get instance => _bloc ??= LMFeedComposeBloc._();

  /// Lists to maintain throughout the screen for sending/receiving data
  int imageCount = 0;
  int videoCount = 0;
  int documentCount = 0;
  // is poll added to the post
  bool isPollAdded = false;
  // List of media attached to the post
  List<LMAttachmentViewData> postMedia = [];
  // List of user tags added to the post
  List<LMUserTagViewData> userTags = [];
  // List of topics added to the post
  List<LMTopicViewData> selectedTopics = [];

  LMFeedComposeBloc._() : super(LMFeedComposeInitialState()) {
    on<LMFeedComposeFetchTopicsEvent>(
      (event, emitter) => composeFetchTopicHandler(
        event,
        emitter,
      ),
    );

    on<LMFeedComposeAddPollEvent>(addPollEventHandler);
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
