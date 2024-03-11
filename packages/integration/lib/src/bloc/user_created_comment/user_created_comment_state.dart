part of 'user_created_comment_bloc.dart';

abstract class LMFeedUserCreatedCommentState extends Equatable {
  @override
  List<Object> get props => [];
}

final class UserCreatedCommentInitialState
    extends LMFeedUserCreatedCommentState {}

final class UserCreatedCommentLoadingState
    extends LMFeedUserCreatedCommentState {}

final class UserCreatedCommentPaginationLoadingState
    extends LMFeedUserCreatedCommentState {}

final class UserCreatedCommentLoadedState
    extends LMFeedUserCreatedCommentState {
  final List<LMCommentViewData> comments;
  final Map<String, LMPostViewData> posts;

  UserCreatedCommentLoadedState({required this.comments, required this.posts});
  @override
  List<Object> get props => [comments, posts];
}

final class UserCreatedCommentErrorState extends LMFeedUserCreatedCommentState {
  final String errorMessage;
  UserCreatedCommentErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
