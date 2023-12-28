part of 'post_bloc.dart';

abstract class LMPostState extends Equatable {
  const LMPostState();

  @override
  List<Object> get props => [];
}

class LMNewPostInitiate extends LMPostState {}

class LMNewPostUploading extends LMPostState {
  final Stream<double> progress;
  final LMMediaModel? thumbnailMedia;

  const LMNewPostUploading({required this.progress, this.thumbnailMedia});
}

class LMEditPostUploading extends LMPostState {}

class LMNewPostUploaded extends LMPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const LMNewPostUploaded({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class LMEditPostUploaded extends LMPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const LMEditPostUploaded({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class LMNewPostError extends LMPostState {
  final String message;

  const LMNewPostError({required this.message});
}

class LMPostDeletionError extends LMPostState {
  final String message;

  const LMPostDeletionError({required this.message});

  @override
  List<Object> get props => [message];
}

class LMPostDeleted extends LMPostState {
  final String postId;

  const LMPostDeleted({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMPostUpdateState extends LMPostState {
  final LMPostViewData post;

  const LMPostUpdateState({required this.post});

  @override
  List<Object> get props => [post];
}

class LMPostPinnedState extends LMPostState {
  final String postId;
  final bool isPinned;

  const LMPostPinnedState({required this.postId, required this.isPinned});

  @override
  List<Object> get props => [postId, isPinned];
}

class LMPostPinError extends LMPostState {
  final String message;
  final bool isPinned;
  final String postId;

  const LMPostPinError({
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
