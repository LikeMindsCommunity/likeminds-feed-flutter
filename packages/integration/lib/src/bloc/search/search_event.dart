part of 'search_bloc.dart';

abstract class LMFeedSearchEvent extends Equatable {
  const LMFeedSearchEvent();

  @override
  List<Object> get props => [];
}

// Add your custom search events here
class LMFeedGetSearchEvent extends LMFeedSearchEvent {
  final String query;
  final String type;
  final int page;
  final int pageSize;

  const LMFeedGetSearchEvent({
    required this.query,
    required this.type,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [query, type, page, pageSize];
}

class LMFeedClearSearchEvent extends LMFeedSearchEvent {}
