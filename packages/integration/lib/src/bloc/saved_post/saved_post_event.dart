part of 'saved_post_bloc.dart';

abstract class LMFeedSavedPostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LMFeedGetSavedPostEvent extends LMFeedSavedPostEvent {
  final int page;
  final int pageSize;
  LMFeedGetSavedPostEvent({required this.page, required this.pageSize});
  @override
  List<Object> get props => [page, pageSize];
}
