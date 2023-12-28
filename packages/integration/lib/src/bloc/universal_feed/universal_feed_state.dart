// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'universal_feed_bloc.dart';

abstract class LMUniversalFeedState extends Equatable {
  const LMUniversalFeedState();
}

class LMUniversalFeedInitial extends LMUniversalFeedState {
  @override
  List<Object?> get props => [];
}

class LMUniversalFeedLoaded extends LMUniversalFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;

  const LMUniversalFeedLoaded({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
  });

  @override
  List<Object?> get props => [posts, users, widgets, topics];
}

class LMUniversalFeedLoading extends LMUniversalFeedState {
  @override
  List<Object?> get props => [];
}

class LMPaginatedUniversalFeedLoading extends LMUniversalFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;

  const LMPaginatedUniversalFeedLoading({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
  });
  @override
  List<Object?> get props => [posts, users, widgets, topics];
}

class LMUniversalFeedError extends LMUniversalFeedState {
  final String message;

  const LMUniversalFeedError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
