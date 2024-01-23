part of '../post_bloc.dart';

void newPostEventHandler(
    LMFeedCreateNewPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    List<LMMediaModel>? postMedia = event.postMedia;
    List<Attachment> attachments = [];
    int index = 0;

    StreamController<double> progress = StreamController<double>.broadcast();
    progress.add(0);

    // Upload post media to s3 and add links as Attachments
    if (postMedia != null && postMedia.isNotEmpty) {
      emit(
        LMFeedNewPostUploadingState(
          progress: progress.stream,
          thumbnailMedia: postMedia.isEmpty
              ? null
              : postMedia[0].mediaType == LMMediaType.link
                  ? null
                  : postMedia[0],
        ),
      );
      for (final media in postMedia) {
        if (media.mediaType == LMMediaType.link) {
          attachments.add(
            Attachment(
              attachmentType: 4,
              attachmentMeta: AttachmentMeta(
                  url: media.ogTags!.url,
                  ogTags: OgTags(
                    description: media.ogTags!.description,
                    image: media.ogTags!.image,
                    title: media.ogTags!.title,
                    url: media.ogTags!.url,
                  )),
            ),
          );
        } else {
          File mediaFile = media.mediaFile!;
          final String? response = await LMFeedCore.media
              .uploadFile(mediaFile, event.user.userUniqueId);
          if (response != null) {
            attachments.add(
              Attachment(
                attachmentType: media.mapMediaTypeToInt(),
                attachmentMeta: AttachmentMeta(
                    url: response,
                    size: media.mediaType == LMMediaType.document
                        ? media.size
                        : null,
                    format: media.mediaType == LMMediaType.document
                        ? media.format
                        : null,
                    duration: media.mediaType == LMMediaType.video
                        ? media.duration
                        : null),
              ),
            );
            progress.add(index / postMedia.length);
          } else {
            throw ('Error uploading file');
          }
        }
      }
      // For counting the no of attachments
    } else {
      emit(
        LMFeedNewPostUploadingState(
          progress: progress.stream,
        ),
      );
    }
    List<Topic> postTopics = event.selectedTopics
        .map((e) => LMTopicViewDataConvertor.toTopic(e))
        .toList();
    final AddPostRequest request = (AddPostRequestBuilder()
          ..text(event.postText)
          ..attachments(attachments)
          ..topics(postTopics))
        .build();

    final AddPostResponse response =
        await LMFeedCore.instance.lmFeedClient.addPost(request);

    if (response.success) {
      emit(
        LMFeedNewPostUploadedState(
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
      emit(LMFeedNewPostErrorState(message: response.errorMessage!));
    }

    LMFeedComposeBloc.instance.add(LMFeedComposeCloseEvent());
  } on Exception catch (err, stacktrace) {
    LMFeedLogger.instance.handleException(err, stacktrace);

    emit(const LMFeedNewPostErrorState(message: 'An error occurred'));
    debugPrint(err.toString());
  }
}
