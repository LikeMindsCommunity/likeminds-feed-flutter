part of 'compose_bloc.dart';

/// {@template lm_feed_compose_event}
/// [LMFeedComposeEvent] defines the events which are
/// handled by [LMFeedComposeBloc]
/// {@endtemplate}
class LMFeedComposeEvent extends Equatable {
  const LMFeedComposeEvent();

  @override
  List<Object?> get props => [];
}

/// {@template lm_feed_compose_fetch_topic_event}
/// [LMFeedComposeFetchTopicsEvent] fetches the topics for the post
/// {@endtemplate}
class LMFeedComposeFetchTopicsEvent extends LMFeedComposeEvent {}

///{@template lm_feed_compose_add_poll_event}
/// [LMFeedComposeAddPollEvent] adds a poll to the post
/// {@endtemplate}
class LMFeedComposeAddPollEvent extends LMFeedComposeEvent {
  final LMAttachmentMetaViewData attachmentMetaViewData;
  const LMFeedComposeAddPollEvent({required this.attachmentMetaViewData});

  @override
  List<Object?> get props => [attachmentMetaViewData];
}

/// {@template lm_feed_compose_add_image_event}
/// [LMFeedComposeAddImageEvent] opens the image picker and handles the flow
/// to add the selected images to the post
/// {@endtemplate}
class LMFeedComposeAddImageEvent extends LMFeedComposeEvent {}

/// {@template lm_feed_compose_add_video_event}
/// [LMFeedComposeAddVideoEvent] opens the video picker and handles the flow
/// to add the selected video to the post
/// {@endtemplate}
class LMFeedComposeAddVideoEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddDocumentEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddLinkPreviewEvent extends LMFeedComposeEvent {
  final String url;

  const LMFeedComposeAddLinkPreviewEvent({required this.url});

  @override
  List<Object?> get props => [url, identityHashCode(this)];
}

class LMFeedComposeRemoveAttachmentEvent extends LMFeedComposeEvent {
  final int index;

  const LMFeedComposeRemoveAttachmentEvent({required this.index});

  @override
  List<Object?> get props => [index, identityHashCode(this)];
}

class LMFeedComposeCloseEvent extends LMFeedComposeEvent {}
