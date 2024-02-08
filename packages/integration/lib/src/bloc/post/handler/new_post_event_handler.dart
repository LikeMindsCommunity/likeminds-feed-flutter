part of '../post_bloc.dart';

void newPostEventHandler(
    LMFeedCreateNewPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    List<LMMediaModel>? postMedia = event.postMedia;
    List<Attachment> attachments = [];
    int index = 0;
    bool? isRepost;

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
        if (media.mediaType == LMMediaType.repost) {
          attachments.add(
            Attachment(
              attachmentType: 8,
              attachmentMeta: AttachmentMeta(
                entityId: media.postId,
              ),
            ),
          );
          isRepost = true;
          break;
        } else if (media.mediaType == LMMediaType.link) {
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
        } else if (media.mediaType == LMMediaType.widget) {
          attachments.add(
            Attachment(
              attachmentType: 5,
              attachmentMeta: AttachmentMeta(
                meta: media.widgetsMeta,
              ),
            ),
          );
        } else {
          File mediaFile = media.mediaFile!;
          final String? response = await LMFeedMediaService.instance
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
    final requestBuilder = AddPostRequestBuilder()
      ..text(event.postText)
      ..attachments(attachments)
      ..topics(postTopics);

    if (isRepost != null) {
      requestBuilder.isRepost(isRepost);
    }
    final AddPostResponse response =
        await LMFeedCore.instance.lmFeedClient.addPost(requestBuilder.build());

    if (response.success) {
      emit(
        LMFeedNewPostUploadedState(
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
            widgets: (response.widgets ?? <String, WidgetModel>{}).map(
              (key, value) => MapEntry(
                key,
                LMWidgetViewDataConvertor.fromWidgetModel(value),
              ),
            )),
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
