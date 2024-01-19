part of 'compose_bloc.dart';

@immutable
sealed class LMFeedComposeEvent extends Equatable {
  const LMFeedComposeEvent();

  @override
  List<Object?> get props => [];
}

class LMFeedComposeFetchTopicsEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddImageEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddVideoEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddDocumentEvent extends LMFeedComposeEvent {}

class LMFeedComposeAddLinkPreviewEvent extends LMFeedComposeEvent {
  final String url;

  const LMFeedComposeAddLinkPreviewEvent({required this.url});

  @override
  List<Object?> get props => [url];
}

class LMFeedComposeRemoveAttachmentEvent extends LMFeedComposeEvent {
  final int index;

  const LMFeedComposeRemoveAttachmentEvent({required this.index});

  @override
  List<Object?> get props => [index, identityHashCode(this)];
}

class LMFeedComposeCloseEvent extends LMFeedComposeEvent {}
