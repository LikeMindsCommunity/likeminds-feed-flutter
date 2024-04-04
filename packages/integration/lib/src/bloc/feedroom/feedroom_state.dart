part of 'feedroom_bloc.dart';

abstract class LMFeedRoomState extends Equatable {
  const LMFeedRoomState();

  @override
  List<Object> get props => [];
}

class LMFeedRoomInitialState extends LMFeedRoomState {}

class LMFeedRoomLoadingState extends LMFeedRoomState {}

class LMFeedRoomPaginationLoadingState extends LMFeedRoomState {
  final LMFeedRoomViewData feedRoom;

  const LMFeedRoomPaginationLoadingState({
    required this.feedRoom,
  });

  @override
  List<Object> get props => [feedRoom];
}

class LMFeedRoomEmptyState extends LMFeedRoomState {
  final LMFeedRoomViewData feedRoom;
  const LMFeedRoomEmptyState({
    required this.feedRoom,
  });
  @override
  List<Object> get props => [
        feedRoom,
      ];
}

class LMFeedRoomLoadedState extends LMFeedRoomState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;
  final LMFeedRoomViewData feedRoom;
  final int pageKey;

  const LMFeedRoomLoadedState({
    required this.feedRoom,
    required this.posts,
    required this.users,
    required this.widgets,
    required this.topics,
    required this.pageKey,
  });
  @override
  List<Object> get props => [feedRoom, posts, users, widgets, topics];
}

class LMFeedRoomErrorState extends LMFeedRoomState {
  final String message;
  const LMFeedRoomErrorState({required this.message});
  @override
  List<Object> get props => [message];
}

class LMFeedRoomListInitialState extends LMFeedRoomState {}

class LMFeedRoomListLoadingState extends LMFeedRoomState {}

class LMFeedRoomListEmptyState extends LMFeedRoomState {}

class LMFeedRoomListLoadedState extends LMFeedRoomState {
  final List<LMFeedRoomViewData> feedList;
  final int size;
  final int offset;
  const LMFeedRoomListLoadedState({
    required this.feedList,
    required this.size,
    required this.offset,
  });
  @override
  List<Object> get props => [feedList];
}

class LMFeedRoomListErrorState extends LMFeedRoomState {
  final String message;
  const LMFeedRoomListErrorState({required this.message});
  @override
  List<Object> get props => [message];
}
