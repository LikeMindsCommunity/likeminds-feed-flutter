part of '../post_bloc.dart';

/// {@template edit_post_event_handler}
/// This function handles the [LMFeedEditPostEvent]
/// and emits the appropriate state based on the response
/// from the server
/// If the response is successful, [LMFeedEditPostUploadedState] is emitted
/// If the response is not successful, [LMFeedNewPostErrorState] is emitted
void editPostEventHandler(
    LMFeedEditPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    emit(LMFeedEditPostUploadingState());
    // Mapping [LMAttachmentViewData] to [Attachment]
    List<Attachment>? attachments = event.attachments
        ?.map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
        .toList();
    // Text associated with the post
    // can be null [either heading or attachments should be present though]
    String? postText = event.postText;
    // Heading of the post
    // can be null [either postText or attachments should be present though]
    String? headingText = event.heading;

    // Building edit post request
    EditPostRequestBuilder editPostRequestBuilder = EditPostRequestBuilder()
      // attachments associated to the post
      ..attachments(attachments ?? [])
      // postId of the post to be edited
      ..postId(event.postId)
      // topics associated to the post
      ..topics(event.selectedTopics
          .map((e) => LMTopicViewDataConvertor.toTopic(e))
          .toList());

    // If postText is not null, add postText in request
    if (postText != null) {
      editPostRequestBuilder.postText(postText);
    }
    // If headingText is not null, add headingText in request
    if (headingText != null) {
      editPostRequestBuilder.heading(headingText);
    }

    // Call the editPost method using [LMFeedClient]
    // and wait for the response
    var response = await LMFeedCore.instance.lmFeedClient
        .editPost(editPostRequestBuilder.build());

    // If the response is successful
    if (response.success) {
      // Convert the post response to [ViewData] models and
      // Emit [LMFeedEditPostUploadedState] with the post data
      emit(
        LMFeedEditPostUploadedState(
          postData: LMPostViewDataConvertor.fromPost(
            post: response.post!,
            widgets: response.widgets ?? {},
            repostedPosts: response.repostedPosts ?? {},
            users: response.user ?? {},
            topics: response.topics ?? {},
          ),
          userData: (response.user ?? <String, User>{}).map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value))),
          topics: (response.topics ?? <String, Topic>{}).map(
            (key, value) => MapEntry(
              key,
              LMTopicViewDataConvertor.fromTopic(value),
            ),
          ),
          widgets: (response.widgets ?? <String, WidgetModel>{}).map((key,
                  value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value))),
        ),
      );
    } else {
      // If the response is not successful
      // Emit [LMFeedNewPostErrorState] with the error message
      emit(
        LMFeedNewPostErrorState(
          errorMessage: response.errorMessage!,
        ),
      );
    }
  } on Exception catch (err, stacktrace) {
    // If an exception occurs, log the exception and stacktrace
    LMFeedLogger.instance.handleException(err, stacktrace);
    // Emit [LMFeedNewPostErrorState] with the error message
    emit(
      const LMFeedNewPostErrorState(
        errorMessage: 'An error occurred while saving the post',
      ),
    );
  }
}
