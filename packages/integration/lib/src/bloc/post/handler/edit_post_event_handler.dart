part of '../post_bloc.dart';

void editPostEventHandler(
    LMFeedEditPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    emit(LMFeedEditPostUploadingState());
    List<Attachment>? attachments = event.attachments
        ?.map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
        .toList();
    String postText = event.postText;

    var response = await LMFeedCore.instance.lmFeedClient
        .editPost((EditPostRequestBuilder()
              ..attachments(attachments ?? [])
              ..postId(event.postId)
              ..postText(postText))
            .build());

    if (response.success) {
      emit(
        LMFeedEditPostUploadedState(
          postData: LMPostViewDataConvertor.fromPost(
              post: response.post!, widgets: response.widgets ?? {}),
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
      emit(
        LMFeedNewPostErrorState(
          message: response.errorMessage!,
        ),
      );
    }
  } on Exception catch (err, stacktrace) {
    LMFeedLogger.instance.handleException(err, stacktrace);

    emit(
      const LMFeedNewPostErrorState(
        message: 'An error occurred while saving the post',
      ),
    );
  }
}
