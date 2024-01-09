part of 'post_bloc.dart';

abstract class LMFeedPostState extends Equatable {
  const LMFeedPostState();

  @override
  List<Object> get props => [];
}

class LMFeedNewPostInitiateState extends LMFeedPostState {}

class LMFeedNewPostUploadingState extends LMFeedPostState {
  final Stream<double> progress;
  final LMMediaModel? thumbnailMedia;

  const LMFeedNewPostUploadingState(
      {required this.progress, this.thumbnailMedia});
}

class LMFeedEditPostUploadingState extends LMFeedPostState {}

class LMFeedNewPostUploadedState extends LMFeedPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const LMFeedNewPostUploadedState({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class LMFeedEditPostUploadedState extends LMFeedPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const LMFeedEditPostUploadedState({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class LMFeedNewPostErrorState extends LMFeedPostState {
  final String message;

  const LMFeedNewPostErrorState({required this.message});
}

class LMFeedPostDeletionErrorState extends LMFeedPostState {
  final String message;

  const LMFeedPostDeletionErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class LMFeedPostDeletedState extends LMFeedPostState {
  final String postId;

  const LMFeedPostDeletedState({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMFeedPostUpdateState extends LMFeedPostState {
  final LMPostViewData post;

  const LMFeedPostUpdateState({required this.post});

  @override
  List<Object> get props => [post];
}

class LMFeedPostPinnedState extends LMFeedPostState {
  final String postId;
  final bool isPinned;

  const LMFeedPostPinnedState({required this.postId, required this.isPinned});

  @override
  List<Object> get props => [postId, isPinned];
}

class LMFeedPostPinErrorState extends LMFeedPostState {
  final String message;
  final bool isPinned;
  final String postId;

  const LMFeedPostPinErrorState({
    required this.message,
    required this.isPinned,
    required this.postId,
  });

  @override
  List<Object> get props => [
        message,
        isPinned,
        postId,
      ];
}
