part of '../post_bloc.dart';

void newPostEventHandler(
    LMFeedCreateNewPostEvent event, Emitter<LMFeedPostState> emit) async {
  final DateTime currentTime = DateTime.now();
  final String tempId = '-${currentTime.millisecondsSinceEpoch}';
  try {
    List<Attachment> attachments = [];
    StreamController<double> progress = StreamController<double>.broadcast();

    // check if post is repost
    bool isRepost = isRepostPost(event.postMedia ?? []);

    // check if there is any media to upload
    bool isMediaPresent = isPostContainsMedia(event.postMedia ?? []);
    // save temp post if media is present in db
    // to retry post upload if media upload fails
    if (isMediaPresent) {
      // create temp post
      final post = createTempPostFromEvent(
        event,
        event.postMedia ?? [],
        isRepost,
        currentTime,
      );

      // create save temp post request
      final SaveTemporaryPostRequest saveTemporaryPostRequest =
          (SaveTemporaryPostRequestBuilder()..tempPost(post)).build();

      // save temp post in db
      await LMFeedCore.instance.lmFeedClient
          .saveTemporaryPost(saveTemporaryPostRequest);
    }

    // Handle media upload if media exists
    if (event.postMedia != null &&
        event.postMedia!.isNotEmpty &&
        event.postMedia!.first.attachmentMeta.url == null) {
      final uploadAttachmentResponse = await uploadMediaEventHandler(
        LMFeedUploadMediaEvent(
          postMedia: event.postMedia!,
          user: event.user,
          progressController: progress,
          tempId: tempId,
        ),
        emit,
      );
      if (!uploadAttachmentResponse.success ||
          uploadAttachmentResponse.data == null) {
        return;
      }

      attachments = uploadAttachmentResponse.data!;
    }
    // emit the uploading state
    emit(LMFeedNewPostUploadingState(progress: progress.stream));

    // Continue with post creation
    String? postText = event.postText;
    String? headingText = event.heading;

    final requestBuilder = AddPostRequestBuilder()
      ..attachments(attachments)
      ..topicIds(event.selectedTopicIds)
      ..tempId(tempId);

    if (headingText != null) {
      requestBuilder.heading(headingText);
    }

    if (event.feedroomId != null) {
      requestBuilder.feedroomId(event.feedroomId!);
    }

    if (postText != null) {
      requestBuilder.text(postText);
    }

    if (isRepost) {
      requestBuilder.isRepost(true);
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

      sendPostCreationCompletedEvent(event.postMedia ?? [],
          event.userTagged ?? [], event.selectedTopicIds);
    } else {
      emit(LMFeedNewPostErrorState(
        errorMessage: response.errorMessage!,
        tempId: tempId,
      ));
    }

    LMFeedComposeBloc.instance.add(LMFeedComposeCloseEvent());
  } on Exception catch (err, stacktrace) {
    LMFeedPersistence.instance.handleException(err, stacktrace);
    emit(LMFeedNewPostErrorState(
      errorMessage: 'An error occurred',
      tempId: tempId,
    ));
    debugPrint(err.toString());
  }
}

void sendPostCreationCompletedEvent(
  List<LMAttachmentViewData> postMedia,
  List<LMUserTagViewData> usersTagged,
  List<String> topics,
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
    propertiesMap['topics'] = topics.join(',');
  } else {
    propertiesMap['topics_added'] = 'no';
  }

  LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.postCreationCompleted,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: propertiesMap,
  ));
}

bool isPostContainsMedia(List<LMAttachmentViewData> postMedia) {
  for (LMAttachmentViewData media in postMedia) {
    if (media.attachmentType == LMMediaType.image ||
        media.attachmentType == LMMediaType.video ||
        media.attachmentType == LMMediaType.document ||
        media.attachmentType == LMMediaType.reel) {
      return true;
    }
  }
  return false;
}

Post createTempPostFromEvent(
  LMFeedCreateNewPostEvent event,
  List<LMAttachmentViewData> postMedia,
  bool? isRepost,
  DateTime currentTime,
) {
  String? postText = event.postText;
  String? headingText = event.heading;
  final attachments = postMedia
      .map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
      .toList();
  return Post(
    id: '-${currentTime.millisecondsSinceEpoch}',
    communityId: -1,
    feedroomId: event.feedroomId,
    isPinned: false,
    uuid: event.user.uuid,
    likeCount: 0,
    isSaved: false,
    menuItems: [],
    createdAt: currentTime,
    updatedAt: currentTime,
    isLiked: false,
    commentCount: 0,
    isEdited: false,
    isRepost: isRepost ?? false,
    isRepostedByUser: false,
    repostCount: 0,
    isPendingPost: false,
    postStatus: "",
    text: postText ?? '',
    heading: headingText,
    attachments: attachments,
    topicIds: event.selectedTopicIds,
    tempId: '-${currentTime.millisecondsSinceEpoch}',
  );
}

bool isRepostPost(List<LMAttachmentViewData> postMedia) {
  for (LMAttachmentViewData media in postMedia) {
    if (media.attachmentType == LMMediaType.repost) {
      return true;
    }
  }
  return false;
}
