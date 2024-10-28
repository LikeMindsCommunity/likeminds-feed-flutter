part of '../post_bloc.dart';

void retryPostUploadEventHandler(
  LMFeedRetryPostUploadEvent event,
  Emitter<LMFeedPostState> emit,
) async {
  // get temp post data from the db
  final tempPostResponse = LMFeedCore.instance.lmFeedClient.getTemporaryPost();
  if (!tempPostResponse.success) {
    emit(LMFeedNewPostInitiateState());
    return;
  }
  final Post? tempPost = tempPostResponse.data;

  if (tempPost == null) {
    emit(LMFeedNewPostInitiateState());
    return;
  }
  final LMUserViewData user = LMFeedLocalPreference.instance.fetchUserData()!;
  final postMedia = tempPost.attachments
      ?.map((attachment) => LMAttachmentViewDataConvertor.fromAttachment(
          attachment: attachment, users: {}))
      .toList();
  // create new post upload event
  final LMFeedCreateNewPostEvent createNewPostEvent = LMFeedCreateNewPostEvent(
    user: user,
    postText: tempPost.text,
    selectedTopicIds: tempPost.topicIds ?? [],
    postMedia: postMedia,
    heading: tempPost.heading,
    feedroomId: tempPost.feedroomId,
    userTagged: [],
  );

  // add the new post event to the bloc
  LMFeedPostBloc.instance.add(createNewPostEvent);
}
