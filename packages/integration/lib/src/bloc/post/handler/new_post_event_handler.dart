part of '../post_bloc.dart';

void newPostEventHandler(
    LMFeedCreateNewPostEvent event, Emitter<LMFeedPostState> emit) async {
  try {
    List<LMAttachmentViewData>? postMedia = event.postMedia;
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
              : postMedia[0].attachmentType == LMMediaType.link
                  ? null
                  : postMedia[0],
        ),
      );
      for (final media in postMedia) {
        if (media.attachmentType == LMMediaType.poll) {
          attachments.add(
            Attachment(
              attachmentType: 6,
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                      media.attachmentMeta),
            ),
          );
          continue;
        }
        if (media.attachmentType == LMMediaType.repost) {
          attachments.add(
            Attachment(
              attachmentType: 8,
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                      media.attachmentMeta),
            ),
          );
          isRepost = true;
          break;
        } else if (media.attachmentType == LMMediaType.link) {
          attachments.add(
            Attachment(
              attachmentType: 4,
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                      media.attachmentMeta),
            ),
          );
        } else if (media.attachmentType == LMMediaType.widget) {
          attachments.add(
            Attachment(
              attachmentType: 5,
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                      media.attachmentMeta),
            ),
          );
        } else {
          late File mediaFile;
          if (media.attachmentMeta.bytes != null) {
            mediaFile = File.fromRawPath(media.attachmentMeta.bytes!);
          } else if (media.attachmentMeta.path != null) {
            mediaFile = File(media.attachmentMeta.path!);
          } else {
            LMFeedNewPostErrorState(
              errorMessage: 'Attachment file not found',
              event: event,
            );
          }

          if (media.attachmentType == LMMediaType.video) {
            int originalSize = media.attachmentMeta.size!;

            if (!kIsWeb) {
              var tempFile = await VideoCompress.compressVideo(
                mediaFile.path,
                deleteOrigin: false,
                includeAudio: true,
              );

              mediaFile = tempFile!.file!;
            }
          }
          final LMResponse<String> response =
              await LMFeedMediaService.uploadFile(
            kIsWeb ? media.attachmentMeta.bytes! : mediaFile.readAsBytesSync(),
            event.user.sdkClientInfo.uuid,
            fileName: media.attachmentMeta.meta?['file_name'],
          );
          if (response.success) {
            media.attachmentMeta.url = response.data;
            attachments.add(
              Attachment(
                attachmentType: media.mapMediaTypeToInt(),
                attachmentMeta:
                    LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                  media.attachmentMeta,
                ),
              ),
            );
            progress.add(index / postMedia.length);
          } else {
            throw ('Error uploading file');
          }
        }
      }
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
    String? postText = event.postText;
    String? headingText = event.heading;

    final requestBuilder = AddPostRequestBuilder()
      ..attachments(attachments)
      ..topicIds(postTopics.map((e) => e.id).toList())
      ..tempId('${-DateTime.now().millisecondsSinceEpoch}');

    if (headingText != null) {
      requestBuilder.heading(headingText);
    }

    if (event.feedroomId != null) {
      requestBuilder.feedroomId(event.feedroomId!);
    }

    if (postText != null) {
      requestBuilder.text(postText);
    }

    if (isRepost != null) {
      requestBuilder.isRepost(isRepost);
    }
    final AddPostResponse response =
        await LMFeedCore.instance.lmFeedClient.addPost(requestBuilder.build());

    if (response.success) {
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

      Map<String, LMPostViewData> repostedPosts =
          response.repostedPosts?.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                    post: value,
                    users: users,
                    topics: topics,
                    widgets: widgets,
                  ))) ??
              {};

      emit(
        LMFeedNewPostUploadedState(
          postData: LMPostViewDataConvertor.fromPost(
            post: response.post!,
            widgets: widgets,
            repostedPosts: repostedPosts,
            users: users,
            topics: topics,
          ),
          userData: users,
          topics: topics,
          widgets: widgets,
        ),
      );

      sendPostCreationCompletedEvent(
          event.postMedia ?? [], event.userTagged ?? [], event.selectedTopics);
    } else {
      emit(LMFeedNewPostErrorState(
        errorMessage: response.errorMessage!,
        event: event,
      ));
    }

    LMFeedComposeBloc.instance.add(LMFeedComposeCloseEvent());
  } on Exception catch (err, stacktrace) {
    LMFeedPersistence.instance.handleException(err, stacktrace);

    emit(LMFeedNewPostErrorState(
      errorMessage: 'An error occurred',
      event: event,
    ));
    debugPrint(err.toString());
  }
}

void sendPostCreationCompletedEvent(
  List<LMAttachmentViewData> postMedia,
  List<LMUserTagViewData> usersTagged,
  List<LMTopicViewData> topics,
) {
  Map<String, String> propertiesMap = {};

  if (postMedia.isNotEmpty) {
    if (postMedia.first.attachmentType == LMMediaType.link) {
      propertiesMap['link_attached'] = 'yes';
      propertiesMap['link'] = postMedia.first.attachmentMeta.ogTags?.url ?? '';
    } else {
      propertiesMap['link_attached'] = 'no';
      int imageCount = 0;
      int videoCount = 0;
      int documentCount = 0;
      for (LMAttachmentViewData media in postMedia) {
        if (media.attachmentType == LMMediaType.image) {
          imageCount++;
        } else if (media.attachmentType == LMMediaType.video) {
          videoCount++;
        } else if (media.attachmentType == LMMediaType.document) {
          documentCount++;
        }
      }
      if (imageCount > 0) {
        propertiesMap['image_attached'] = 'yes';
        propertiesMap['image_count'] = imageCount.toString();
      } else {
        propertiesMap['image_attached'] = 'no';
      }
      if (videoCount > 0) {
        propertiesMap['video_attached'] = 'yes';
        propertiesMap['video_count'] = videoCount.toString();
      } else {
        propertiesMap['video_attached'] = 'no';
      }

      if (documentCount > 0) {
        propertiesMap['document_attached'] = 'yes';
        propertiesMap['document_count'] = documentCount.toString();
      } else {
        propertiesMap['document_attached'] = 'no';
      }
    }
  }

  if (usersTagged.isNotEmpty) {
    int taggedUserCount = 0;
    List<String> taggedUserId = [];

    taggedUserCount = usersTagged.length;
    taggedUserId =
        usersTagged.map((e) => e.sdkClientInfo?.uuid ?? e.uuid!).toList();

    propertiesMap['user_tagged'] = taggedUserCount == 0 ? 'no' : 'yes';
    if (taggedUserCount > 0) {
      propertiesMap['tagged_users_count'] = taggedUserCount.toString();
      propertiesMap['tagged_users_id'] = taggedUserId.join(',');
    }
  }

  if (topics.isNotEmpty) {
    propertiesMap['topics_added'] = 'yes';
    propertiesMap['topics'] = topics.map((e) => e.id).toList().join(',');
  } else {
    propertiesMap['topics_added'] = 'no';
  }

  LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.postCreationCompleted,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: propertiesMap,
  ));
}
