part of 'compose_bloc.dart';

@immutable
sealed class LMFeedComposeState {}

final class LMFeedComposeInitialState extends LMFeedComposeState {}

class LMFeedComposeMediaLoadingState extends LMFeedComposeState {}

class LMFeedComposeTopicsLoadingState extends LMFeedComposeState {}

class LMFeedComposeFetchedTopicsState extends LMFeedComposeState {
  final List<LMTopicViewData> topics;

  LMFeedComposeFetchedTopicsState({required this.topics});
}

class LMFeedComposeAddedImageState extends LMFeedComposeState {}

class LMFeedComposeMediaErrorState extends LMFeedComposeState {
  final Error error;

  LMFeedComposeMediaErrorState(this.error);
}

class LMFeedComposeAddedVideoState extends LMFeedComposeState {}

class LMFeedComposeAddedDocumentState extends LMFeedComposeState {}

class LMFeedComposeRemovedImageState extends LMFeedComposeState {}

class LMFeedComposeRemovedVideoState extends LMFeedComposeState {}

class LMFeedComposeRemovedDocumentState extends LMFeedComposeState {}
