part of '../post_bloc.dart';

/// {@template edit_post_event_handler}
/// This function handles the [LMFeedEditPostEvent]
/// and emits the appropriate state based on the response
/// from the server
/// If the response is successful, [LMFeedEditPostUploadedState] is emitted
/// If the response is not successful, [LMFeedNewPostErrorState] is emitted
/// {@endtemplate}
Future<void> editPostEventHandler(
    LMFeedEditPostEvent event, Emitter<LMFeedPostState> emit) async {
  if (event.postId != null) {
    await editPost(event, emit);
  } else if (event.pendingPostId != null) {
    await editPendingPost(event, emit);
  } else {
    emit(LMFeedPostErrorState(
        errorMessage: "Either post id or pending post id must be call"));
    return;
  }
}

Future<void> editPost(
    LMFeedEditPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    emit(LMFeedEditPostUploadingState());

    List<LMAttachmentViewData> attachmentViewData =
        LMFeedComposeBloc.instance.postMedia;
    // Mapping [LMAttachmentViewData] to [Attachment]
    List<Attachment>? attachments = attachmentViewData
        .map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
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
      ..attachments(attachments)
      // postId of the post to be edited
      ..postId(event.postId!)
      // topics associated to the post
      ..topicIds(event.selectedTopics.map((e) => e.id).toList());

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
      Map<String, LMWidgetViewData> widgets =
          (response.widgets ?? <String, WidgetModel>{}).map((key, value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

      Map<String, LMTopicViewData> topics =
          (response.topics ?? <String, Topic>{}).map((key, value) => MapEntry(
              key,
              LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

      Map<String, LMUserViewData> users =
          (response.user ?? <String, User>{}).map((key, value) => MapEntry(
              key,
              LMUserViewDataConvertor.fromUser(
                value,
                topics: topics,
                userTopics: response.userTopics,
                widgets: widgets,
              )));

      Map<String, LMPostViewData> respostedPost =
          response.repostedPosts?.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                    post: value,
                    users: users,
                    topics: topics,
                    widgets: widgets,
                  ))) ??
              {};

      LMPostViewData post = LMPostViewDataConvertor.fromPost(
        post: response.post!,
        widgets: widgets,
        repostedPosts: respostedPost,
        users: users,
        topics: topics,
        userTopics: response.userTopics,
      );

      emit(
        LMFeedEditPostUploadedState(
          postData: post,
          userData: users,
          topics: topics,
          widgets: widgets,
        ),
      );

      String postType = LMFeedPostUtils.getPostType(attachmentViewData);

      LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
          eventName: LMFeedAnalyticsKeys.postEdited,
          widgetSource: LMFeedWidgetSource.editPostScreen,
          eventProperties: {
            'create_by_id': post.user.sdkClientInfo.uuid,
            'post_id': post.id,
            'post_type': postType,
            'topics': post.topics.map((e) => e.name).toList(),
          }));
    } else {
      // If the response is not successful
      // Emit [LMFeedNewPostErrorState] with the error message
      emit(
        LMFeedNewPostErrorState(
          errorMessage: response.errorMessage!,
          tempId: event.tempId,
        ),
      );
    }
  } on Exception catch (err, stacktrace) {
    // If an exception occurs, log the exception and stacktrace
    LMFeedPersistence.instance.handleException(err, stacktrace);
    // Emit [LMFeedNewPostErrorState] with the error message
    emit(
      LMFeedNewPostErrorState(
        errorMessage: 'An error occurred while saving the post',
        tempId: event.tempId,
      ),
    );
  }
}

Future<void> editPendingPost(
    LMFeedEditPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    emit(LMFeedEditPostUploadingState());

    List<LMAttachmentViewData> attachmentViewData =
        LMFeedComposeBloc.instance.postMedia;
    // Mapping [LMAttachmentViewData] to [Attachment]
    List<Attachment>? attachments = attachmentViewData
        .map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
        .toList();
    // Text associated with the post
    // can be null [either heading or attachments should be present though]
    String? postText = event.postText;
    // Heading of the post
    // can be null [either postText or attachments should be present though]
    String? headingText = event.heading;

    // Building edit post request
    EditPendingPostRequestBuilder editPostRequestBuilder =
        EditPendingPostRequestBuilder()
          // attachments associated to the post
          ..attachments(attachments)
          // postId of the post to be edited
          ..postId(event.pendingPostId!)
          // topics associated to the post
          ..topicIds(event.selectedTopics.map((e) => e.id).toList());

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
    LMResponse response = await LMFeedCore.instance.lmFeedClient
        .editPendingPost(editPostRequestBuilder.build());

    // If the response is successful
    if (response.success) {
      EditPendingPostResponse editPendingPostResponse =
          response.data as EditPendingPostResponse;
      // Convert the post response to [ViewData] models and
      // Emit [LMFeedEditPostUploadedState] with the post data
      Map<String, LMWidgetViewData> widgets =
          (editPendingPostResponse.widgets ?? <String, WidgetModel>{}).map((key,
                  value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

      Map<String, LMTopicViewData> topics =
          (editPendingPostResponse.topics ?? <String, Topic>{}).map(
              (key, value) => MapEntry(key,
                  LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

      Map<String, LMUserViewData> users =
          (editPendingPostResponse.user ?? <String, User>{})
              .map((key, value) => MapEntry(
                  key,
                  LMUserViewDataConvertor.fromUser(
                    value,
                    topics: topics,
                    userTopics: editPendingPostResponse.userTopics,
                    widgets: widgets,
                  )));

      Map<String, LMPostViewData> respostedPost =
          editPendingPostResponse.repostedPosts.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                    post: value,
                    users: users,
                    topics: topics,
                    widgets: widgets,
                  ))) ??
              {};

      LMPostViewData post = LMPostViewDataConvertor.fromPost(
        post: editPendingPostResponse.post,
        widgets: widgets,
        repostedPosts: respostedPost,
        users: users,
        topics: topics,
        userTopics: editPendingPostResponse.userTopics,
      );

      emit(
        LMFeedEditPostUploadedState(
          postData: post,
          userData: users,
          topics: topics,
          widgets: widgets,
        ),
      );

      String postType = LMFeedPostUtils.getPostType(attachmentViewData);

      LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
          eventName: LMFeedAnalyticsKeys.postEdited,
          widgetSource: LMFeedWidgetSource.editPostScreen,
          eventProperties: {
            'create_by_id': post.user.sdkClientInfo.uuid,
            'post_id': post.id,
            'post_type': postType,
            'topics': post.topics.map((e) => e.name).toList(),
          }));
    } else {
      // If the response is not successful
      // Emit [LMFeedNewPostErrorState] with the error message
      emit(
        LMFeedNewPostErrorState(
          errorMessage: response.errorMessage!,
          tempId: event.tempId,
        ),
      );
    }
  } on Exception catch (err, stacktrace) {
    // If an exception occurs, log the exception and stacktrace
    LMFeedPersistence.instance.handleException(err, stacktrace);
    // Emit [LMFeedNewPostErrorState] with the error message
    emit(
      LMFeedNewPostErrorState(
        errorMessage: 'An error occurred while saving the post',
        tempId: event.tempId,
      ),
    );
  }
}
