part of 'universal_feed_bloc.dart';

abstract class LMFeedEvent extends Equatable {
  const LMFeedEvent();
}

class LMFeedGetUniversalFeedEvent extends LMFeedEvent {
  final int offset;
  final List<LMTopicViewData>? topics;
  const LMFeedGetUniversalFeedEvent({required this.offset, this.topics});
  @override
  List<Object?> get props => [offset, topics];
}
