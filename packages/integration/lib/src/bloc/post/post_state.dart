part of 'post_bloc.dart';

/// Base class for all the states related to [LMFeedPostBloc]
/// [LMFeedPostState] is extended by all the states
abstract class LMFeedPostState extends Equatable {
  const LMFeedPostState();

  @override
  List<Object> get props => [];
}

class LMFeedNewPostInitiateState extends LMFeedPostState {}

/// Success States
/// When an action is successfully completed
/// [LMFeedPostSuccessState] is emitted to indicate that
/// the action is successful
class LMFeedPostSuccessState extends LMFeedPostState {
  const LMFeedPostSuccessState();
}

/// When a post is successfully fetched from the server
/// [LMFeedGetPostSuccessState] is emitted to update the UI
/// [post] contains the post details and is of type [LMPostViewData]
class LMFeedGetPostSuccessState extends LMFeedPostSuccessState {
  final LMPostViewData post;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMPostViewData>? repostedPosts;

  const LMFeedGetPostSuccessState({
    required this.post,
    required this.userData,
    required this.topics,
    required this.widgets,
    this.repostedPosts,
  });

  @override
  List<Object> get props => [post, userData, topics, widgets];
}

/// When a new post is successfully uploaded
/// [LMFeedNewPostUploadedState] is used to update the post details in the UI
/// [postData] contains the new post data and
/// is of type [LMPostViewData]
/// [userData] contains the new user data and
/// is of type [Map<String, LMUserViewData>]
/// [topics] contains the new topics and
/// is of type [Map<String, LMTopicViewData>]
/// [widgets] contains the new widgets and
/// is of type [Map<String, LMWidgetViewData>]
class LMFeedNewPostUploadedState extends LMFeedPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;
  final Map<String, LMWidgetViewData> widgets;

  const LMFeedNewPostUploadedState({
    required this.postData,
    required this.userData,
    required this.topics,
    required this.widgets,
  });
}

/// When an existing post is successfully edited
/// [LMFeedEditPostUploadedState] is used to update the post details in the UI
/// [postData] contains the updated post data and
/// is of type [LMPostViewData]
/// [userData] contains the updated user data and
/// is of type [Map<String, LMUserViewData>]
/// [topics] contains the updated topics and
/// is of type [Map<String, LMTopicViewData>]
/// [widgets] contains the updated widgets and
/// is of type [Map<String, LMWidgetViewData>]
class LMFeedEditPostUploadedState extends LMFeedPostState {
  final LMPostViewData postData;
  final Map<String, LMUserViewData> userData;
  final Map<String, LMTopicViewData> topics;
  final Map<String, LMWidgetViewData> widgets;

  const LMFeedEditPostUploadedState({
    required this.postData,
    required this.userData,
    required this.topics,
    required this.widgets,
  });
}

/// [LMFeedPostDeletedState] is emitted to indicate that
/// the post is successfully deleted
/// [postId] contains the id of the deleted post
/// and is of type [String]
class LMFeedPostDeletedState extends LMFeedPostState {
  final String postId;

  const LMFeedPostDeletedState({required this.postId});

  @override
  List<Object> get props => [postId];
}

/// When an existing post is successfully updated
/// [LMFeedPostUpdateState] is used to update the post details in the UI
/// [post] contains the updated post data and
/// is of type [LMPostViewData]
class LMFeedPostUpdateState extends LMFeedPostState {
  final LMPostViewData? post;
  final LMFeedPostActionType actionType;
  final String postId;

  const LMFeedPostUpdateState(
      {this.post, required this.postId, required this.actionType});

  @override
  List<Object> get props => [identityHashCode(this)];
}

/// Error States
/// When an error occurs while performing an action
/// [LMFeedPostErrorState] is emitted to indicate that
/// an error has occurred
/// [errorMessage] contains the error message
/// and is of type [String]
class LMFeedPostErrorState extends LMFeedPostState {
  final String errorMessage;

  const LMFeedPostErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

/// Error while uploading a new post
/// [LMFeedNewPostErrorState] is emitted to indicate that
/// an error has occurred while uploading a new post
/// [errorMessage] contains the error message
/// and is of type [String]
class LMFeedNewPostErrorState extends LMFeedPostErrorState {
  const LMFeedNewPostErrorState({required super.errorMessage});
}

/// Error while editing an existing post
/// [LMFeedEditPostErrorState] is emitted to indicate that
/// an error has occurred while editing an existing post
/// [errorMessage] contains the error message
/// and is of type [String]
class LMFeedEditPostErrorState extends LMFeedPostErrorState {
  const LMFeedEditPostErrorState({required super.errorMessage});
}

/// Error while fetching post details
/// [LMFeedGetPostErrorState] is emitted to indicate that
/// an error has occurred while fetching post details
/// [message] contains the error message
/// and is of type [String]
class LMFeedGetPostErrorState extends LMFeedPostState {
  final String message;

  const LMFeedGetPostErrorState({required this.message});

  @override
  List<Object> get props => [identityHashCode(this)];
}

// Error while deleting a post
/// [LMFeedPostDeletionErrorState] is emitted to indicate that
/// an error has occurred while deleting a post
/// [message] contains the error message
/// and is of type [String]
class LMFeedPostDeletionErrorState extends LMFeedPostState {
  final String message;

  const LMFeedPostDeletionErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

// Loading States
/// When an action is in progress [LMFeedUploadingState] is emitted
class LMFeedUploadingState extends LMFeedPostState {
  const LMFeedUploadingState();
}

// When new post is uploading
/// [LMFeedNewPostUploadingState] is emitted to indicate that
/// a new post is being uploaded
/// [progress] contains the progress of the upload
/// and is of type [Stream<double>]
/// [thumbnailMedia] contains the thumbnail media
/// and is of type [LMMediaModel]
class LMFeedNewPostUploadingState extends LMFeedUploadingState {
  final Stream<double> progress;
  final LMMediaModel? thumbnailMedia;

  const LMFeedNewPostUploadingState(
      {required this.progress, this.thumbnailMedia});
}

// When edit post is in progress
/// [LMFeedEditPostUploadingState] is emitted to indicate that
/// an existing post is being edited
/// [thumbnailMedia] contains the thumbnail media
/// and is of type [LMMediaModel]
class LMFeedEditPostUploadingState extends LMFeedUploadingState {
  final Attachment? thumbnailAttachment;

  const LMFeedEditPostUploadingState({this.thumbnailAttachment});
}

/// When a post details is being fetched from the server
/// [LMFeedGetPostLoadingState] is emitted to indicate that
/// post details is being fetched
class LMFeedGetPostLoadingState extends LMFeedUploadingState {}
