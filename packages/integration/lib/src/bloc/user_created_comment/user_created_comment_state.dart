part of 'user_created_comment_bloc.dart';

abstract class LMFeedUserCreatedCommentState extends Equatable {
  @override
  List<Object> get props => [];
}

final class LMFeedUserCreatedCommentInitialState
    extends LMFeedUserCreatedCommentState {}

final class LMFeedUserCreatedCommentLoadingState
    extends LMFeedUserCreatedCommentState {}

final class LMFeedUserCreatedCommentLoadedState
    extends LMFeedUserCreatedCommentState {
  final List<LMCommentViewData> comments;
  final Map<String, LMPostViewData> posts;
  final int page;

  LMFeedUserCreatedCommentLoadedState({
    required this.comments,
    required this.posts,
    required this.page,
  });
  @override
  List<Object> get props => [comments, posts];
}

final class LMFeedUserCreatedCommentErrorState
    extends LMFeedUserCreatedCommentState {
  final String errorMessage;
  LMFeedUserCreatedCommentErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
