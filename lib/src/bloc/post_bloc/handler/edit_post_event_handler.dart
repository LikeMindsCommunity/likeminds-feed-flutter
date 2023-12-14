part of '../post_bloc.dart';

Future<void> editPostEventHandler(
    EditPost event, Emitter<LMPostState> emit) async {
  try {
    emit(EditPostUploading());
    List<Attachment>? attachments = event.attachments
        ?.map((e) => AttachmentViewDataConvertor.toAttachment(e))
        .toList();
    String postText = event.postText;

    var response =
        await LMFeedBloc.get().lmFeedClient.editPost((EditPostRequestBuilder()
              ..attachments(attachments ?? [])
              ..postId(event.postId)
              ..postText(postText))
            .build());

    if (response.success) {
      emit(
        EditPostUploaded(
          postData: PostViewDataConvertor.fromPost(post: response.post!),
          userData: (response.user ?? <String, User>{}).map((key, value) =>
              MapEntry(key, UserViewDataConvertor.fromUser(value))),
          topics: (response.topics ?? <String, Topic>{}).map(
            (key, value) => MapEntry(
              key,
              TopicViewDataConvertor.fromTopic(value),
            ),
          ),
        ),
      );
    } else {
      emit(
        NewPostError(
          message: response.errorMessage!,
        ),
      );
    }
  } catch (err) {
    emit(
      const NewPostError(
        message: 'An error occurred while saving the post',
      ),
    );
  }
}
