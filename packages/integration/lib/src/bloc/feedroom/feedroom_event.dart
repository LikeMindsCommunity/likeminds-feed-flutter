part of 'feedroom_bloc.dart';

abstract class LMFeedRoomEvent extends Equatable {
  const LMFeedRoomEvent();

  @override
  List<Object> get props => [];
}

class LMFeedGetFeedRoomEvent extends LMFeedRoomEvent {
  final int feedRoomId;
  final int offset;
  final bool isPaginationLoading;
  final List<LMTopicViewData>? topics;

  const LMFeedGetFeedRoomEvent({
    required this.feedRoomId,
    required this.offset,
    this.isPaginationLoading = false,
    this.topics,
  });
  @override
  List<Object> get props => [feedRoomId];
}

class LMFeedGetFeedRoomListEvent extends LMFeedRoomEvent {
  final int offset;
  const LMFeedGetFeedRoomListEvent({required this.offset});
  @override
  List<Object> get props => [offset];
}
