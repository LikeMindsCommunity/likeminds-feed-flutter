part of 'compose_bloc.dart';

@immutable
sealed class LMComposeState {}

final class LMComposeInitial extends LMComposeState {}

class LMComposeFetchedTopics extends LMComposeState {
  final List<LMTopicViewData> topics;

  LMComposeFetchedTopics({required this.topics});
}

class LMComposeAddedImage extends LMComposeState {}

class LMComposeAddedVideo extends LMComposeState {}

class LMComposeAddedDocument extends LMComposeState {}

class LMComposeRemovedImage extends LMComposeState {}

class LMComposeRemovedVideo extends LMComposeState {}

class LMComposeRemovedDocument extends LMComposeState {}
