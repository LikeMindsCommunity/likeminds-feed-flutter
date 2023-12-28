part of 'post_bloc.dart';

abstract class LMPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateNewPost extends LMPostEvents {
  final List<LMMediaModel>? postMedia;
  final String postText;
  final User user;
  final List<LMTopicViewData> selectedTopics;

  CreateNewPost({
    this.postMedia,
    required this.user,
    required this.postText,
    required this.selectedTopics,
  });
}

class EditPost extends LMPostEvents {
  final List<LMAttachmentViewData>? attachments;
  final String postText;
  final String postId;
  final List<LMTopicViewData> selectedTopics;

  EditPost({
    required this.postText,
    this.attachments,
    required this.postId,
    required this.selectedTopics,
  });
}

class DeletePost extends LMPostEvents {
  final String postId;
  final String reason;
  final int? feedRoomId;

  DeletePost({
    required this.postId,
    required this.reason,
    this.feedRoomId,
  });

  @override
  List<Object> get props => [postId, reason];
}

class UpdatePost extends LMPostEvents {
  final LMPostViewData post;

  UpdatePost({
    required this.post,
  });

  @override
  List<Object> get props => [post];
}

class TogglePinPost extends LMPostEvents {
  final String postId;
  final bool isPinned;

  TogglePinPost({
    required this.postId,
    required this.isPinned,
  });

  @override
  List<Object> get props => [postId, isPinned];
}
