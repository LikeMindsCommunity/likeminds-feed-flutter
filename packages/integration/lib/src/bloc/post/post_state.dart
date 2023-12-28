part of 'post_bloc.dart';

abstract class LMPostState extends Equatable {
  const LMPostState();

  @override
  List<Object> get props => [];
}

class NewPostInitiate extends LMPostState {}

class NewPostUploading extends LMPostState {
  final Stream<double> progress;
  final LMMediaModel? thumbnailMedia;

  const NewPostUploading({required this.progress, this.thumbnailMedia});
}

class EditPostUploading extends LMPostState {}

class NewPostUploaded extends LMPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const NewPostUploaded({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class EditPostUploaded extends LMPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;

  const EditPostUploaded({
    required this.postData,
    required this.userData,
    required this.topics,
  });
}

class NewPostError extends LMPostState {
  final String message;

  const NewPostError({required this.message});
}

class PostDeletionError extends LMPostState {
  final String message;

  const PostDeletionError({required this.message});

  @override
  List<Object> get props => [message];
}

class PostDeleted extends LMPostState {
  final String postId;

  const PostDeleted({required this.postId});

  @override
  List<Object> get props => [postId];
}

class PostUpdateState extends LMPostState {
  final LMPostViewData post;

  const PostUpdateState({required this.post});

  @override
  List<Object> get props => [post];
}

class PostPinnedState extends LMPostState {
  final String postId;
  final bool isPinned;

  const PostPinnedState({required this.postId, required this.isPinned});

  @override
  List<Object> get props => [postId, isPinned];
}

class PostPinError extends LMPostState {
  final String message;
  final bool isPinned;
  final String postId;

  const PostPinError({
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