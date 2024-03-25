part of 'user_created_comment_bloc.dart';

abstract class LMFeedUserCreatedCommentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LMFeedGetUserCreatedCommentEvent extends LMFeedUserCreatedCommentEvent {
  final String uuid;
  final int page;
  final int pageSize;
  LMFeedGetUserCreatedCommentEvent({
    required this.uuid,
    required this.page,
    required this.pageSize,
  });
  @override
  List<Object> get props => [page, pageSize];
}
