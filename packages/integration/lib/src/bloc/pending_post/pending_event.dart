part of 'pending_bloc.dart';

abstract class LMFeedPendingEvents extends Equatable {}

class LMFeedGetPendingPostsEvent extends LMFeedPendingEvents {
  final int pageSize;
  final int page;
  final String uuid;

  LMFeedGetPendingPostsEvent({
    required this.page,
    required this.pageSize,
    required this.uuid,
  });

  @override
  List<Object> get props => [pageSize, page, uuid];
}
