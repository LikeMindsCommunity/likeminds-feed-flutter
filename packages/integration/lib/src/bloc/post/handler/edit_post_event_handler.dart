part of '../post_bloc.dart';

void editPostEventHandler(LMEditPost event, Emitter<LMPostState> emit) async {
  try {
    emit(LMEditPostUploading());
    List<Attachment>? attachments = event.attachments
        ?.map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
        .toList();
    String postText = event.postText;

    var response = await LMFeedIntegration.instance.lmFeedClient
        .editPost((EditPostRequestBuilder()
              ..attachments(attachments ?? [])
              ..postId(event.postId)
              ..postText(postText))
            .build());

    if (response.success) {
      emit(
        LMEditPostUploaded(
          postData: LMPostViewDataConvertor.fromPost(post: response.post!),
          userData: (response.user ?? <String, User>{}).map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value))),
          topics: (response.topics ?? <String, Topic>{}).map(
            (key, value) => MapEntry(
              key,
              LMTopicViewDataConvertor.fromTopic(value),
            ),
          ),
        ),
      );
    } else {
      emit(
        LMNewPostError(
          message: response.errorMessage!,
        ),
      );
    }
  } catch (err) {
    emit(
      const LMNewPostError(
        message: 'An error occurred while saving the post',
      ),
    );
  }
}
