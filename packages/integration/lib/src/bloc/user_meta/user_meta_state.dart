part of 'user_meta_bloc.dart';

class LMFeedUserMetaState extends Equatable {
  const LMFeedUserMetaState();

  @override
  List<Object> get props => [];
}

class LMFeedUserMetaInitialState extends LMFeedUserMetaState {}

class LMFeedUserMetaLoadingState extends LMFeedUserMetaState {
  final String uuid;
  const LMFeedUserMetaLoadingState({
    required this.uuid,
  });
  @override
  List<Object> get props => [uuid];
}

class LMFeedUserMetaLoadedState extends LMFeedUserMetaState {
  final LMUserViewData user;
  final int? postsCount;
  final int? commentsCount;
  const LMFeedUserMetaLoadedState({
    required this.user,
    required this.postsCount,
    required this.commentsCount,
  });
  @override
  List<Object> get props => [user];
}

class LMFeedUserMetaUpdatedState extends LMFeedUserMetaState {
  const LMFeedUserMetaUpdatedState();
  @override
  List<Object> get props => [];
}

class LMFeedUserMetaUpdateLoadingState extends LMFeedUserMetaState {}

class LMFeedUserMetaErrorState extends LMFeedUserMetaState {
  final String message;
  const LMFeedUserMetaErrorState({
    required this.message,
  });
  @override
  List<Object> get props => [message];
}

class LMFeedUserMetaUpdateErrorState extends LMFeedUserMetaErrorState {
  LMFeedUserMetaUpdateErrorState({required super.message});

  @override
  List<Object> get props => [message];
}
