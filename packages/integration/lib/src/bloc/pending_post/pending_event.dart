part of 'pending_bloc.dart';

// This class represents the events related to pending posts in the LMFeed module.
abstract class LMFeedPendingEvents extends Equatable {
  @override
  List<Object> get props => [];
}

// This event is used to fetch pending posts from the server.
class LMFeedGetPendingPostsEvent extends LMFeedPendingEvents {
  final int pageSize; // The number of posts to fetch per page.
  final int page; // The page number of the posts to fetch.
  final String uuid; // The unique identifier of the user.

  LMFeedGetPendingPostsEvent({
    required this.page,
    required this.pageSize,
    required this.uuid,
  });

  @override
  List<Object> get props => [pageSize, page, uuid];
}
