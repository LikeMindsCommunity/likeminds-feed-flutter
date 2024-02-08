part of 'compose_bloc.dart';

@immutable
class LMFeedComposeState extends Equatable {
  const LMFeedComposeState();

  @override
  List<Object> get props => [];
}

class LMFeedComposeInitialState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

class LMFeedComposeMediaLoadingState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

class LMFeedComposeTopicsLoadingState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

class LMFeedComposeFetchedTopicsState extends LMFeedComposeState {
  final List<LMTopicViewData> topics;

  LMFeedComposeFetchedTopicsState({required this.topics});

  @override
  List<Object> get props => [];
}

class LMFeedComposeMediaErrorState extends LMFeedComposeState {
  final Exception error;

  LMFeedComposeMediaErrorState(this.error);

  @override
  List<Object> get props => [];
}

class LMFeedComposeAddedImageState extends LMFeedComposeState {
  @override
  List<Object> get props => [identityHashCode(this)];
}

class LMFeedComposeAddedLinkPreviewState extends LMFeedComposeState {
  final String url;

  LMFeedComposeAddedLinkPreviewState({required this.url});

  @override
  List<Object> get props => [url, identityHashCode(this)];
}

class LMFeedComposeAddedVideoState extends LMFeedComposeState {
  @override
  List<Object> get props => [identityHashCode(this)];
}

class LMFeedComposeAddedDocumentState extends LMFeedComposeState {
  @override
  List<Object> get props => [identityHashCode(this)];
}

class LMFeedComposeRemovedAttachmentState extends LMFeedComposeState {
  @override
  List<Object> get props => [identityHashCode(this)];
}
