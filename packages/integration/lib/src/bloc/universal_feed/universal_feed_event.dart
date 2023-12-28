part of 'universal_feed_bloc.dart';

abstract class LMUniversalFeedEvent extends Equatable {
  const LMUniversalFeedEvent();
}

class LMGetUniversalFeed extends LMUniversalFeedEvent {
  final int offset;
  final List<LMTopicViewData>? topics;
  const LMGetUniversalFeed({required this.offset, this.topics});
  @override
  List<Object?> get props => [offset, topics];
}
