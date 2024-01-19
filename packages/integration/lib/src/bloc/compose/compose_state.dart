part of 'compose_bloc.dart';

@immutable
sealed class LMFeedComposeState extends Equatable {}

final class LMFeedComposeInitialState extends LMFeedComposeState {
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
  final Error error;

  LMFeedComposeMediaErrorState(this.error);

  @override
  List<Object> get props => [];
}

class LMFeedComposeAddedImageState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

class LMFeedComposeAddedLinkPreviewState extends LMFeedComposeState {
  final String url;

  LMFeedComposeAddedLinkPreviewState({required this.url});

  @override
  List<Object> get props => [url];
}

class LMFeedComposeAddedVideoState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

class LMFeedComposeAddedDocumentState extends LMFeedComposeState {
  @override
  List<Object> get props => [];
}

// class LMFeedComposeRemovingAttachmentState extends LMFeedComposeState {
//   @override
//   List<Object> get props => [DateTime.now().millisecondsSinceEpoch];
// }

class LMFeedComposeRemovedAttachmentState extends LMFeedComposeState {
  @override
  List<Object> get props => [identityHashCode(this)];
}
