// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'universal_feed_bloc.dart';

abstract class LMFeedState extends Equatable {
  const LMFeedState();
}

class LMFeedInitialState extends LMFeedState {
  @override
  List<Object?> get props => [];
}

class LMFeedUniversalFeedLoadedState extends LMFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;
  final int pageKey;

  const LMFeedUniversalFeedLoadedState({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
    required this.pageKey,
  });

  @override
  List<Object?> get props => [posts, users, widgets, topics, pageKey];
}

class LMFeedUniversalFeedLoadingState extends LMFeedState {
  @override
  List<Object?> get props => [];
}

class LMFeedPaginatedUniversalFeedLoadingState extends LMFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;

  const LMFeedPaginatedUniversalFeedLoadingState({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
  });
  @override
  List<Object?> get props => [posts, users, widgets, topics];
}

class LMFeedUniversalFeedErrorState extends LMFeedState {
  final String message;

  const LMFeedUniversalFeedErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
