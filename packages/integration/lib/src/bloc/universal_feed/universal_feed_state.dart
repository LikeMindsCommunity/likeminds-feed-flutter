// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'universal_feed_bloc.dart';

abstract class UniversalFeedState extends Equatable {
  const UniversalFeedState();
}

class UniversalFeedInitial extends UniversalFeedState {
  @override
  List<Object?> get props => [];
}

class UniversalFeedLoaded extends UniversalFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;

  const UniversalFeedLoaded({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
  });

  @override
  List<Object?> get props => [posts, users, widgets, topics];
}

class UniversalFeedLoading extends UniversalFeedState {
  @override
  List<Object?> get props => [];
}

class PaginatedUniversalFeedLoading extends UniversalFeedState {
  final List<LMPostViewData> posts;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;

  const PaginatedUniversalFeedLoading({
    required this.topics,
    required this.posts,
    required this.users,
    required this.widgets,
  });
  @override
  List<Object?> get props => [posts, users, widgets, topics];
}

class UniversalFeedError extends UniversalFeedState {
  final String message;

  const UniversalFeedError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}