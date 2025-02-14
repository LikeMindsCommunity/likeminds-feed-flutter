part of '../post_bloc.dart';

Future<LMResponse<List<Attachment>>> uploadMediaEventHandler(
    LMFeedUploadMediaEvent event, Emitter<LMFeedPostState> emit) async {
  List<Attachment> attachments = [];
  int index = 0;

  event.progressController.add(0);

  if (event.postMedia.isNotEmpty) {
    emit(
      LMFeedNewPostUploadingState(
        progress: event.progressController.stream,
        thumbnailMedia: event.postMedia.isEmpty
            ? null
            : event.postMedia[0].attachmentType == LMMediaType.link
                ? null
                : event.postMedia[0],
      ),
    );

    for (final media in event.postMedia) {
      if (media.attachmentType == LMMediaType.poll) {
        attachments.add(
          Attachment(
            attachmentType: 6,
            attachmentMeta: LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                media.attachmentMeta),
          ),
        );
        continue;
      }

      if (media.attachmentType == LMMediaType.repost) {
        attachments.add(
          Attachment(
            attachmentType: 8,
            attachmentMeta: LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                media.attachmentMeta),
          ),
        );
        break;
      } else if (media.attachmentType == LMMediaType.link) {
        attachments.add(
          Attachment(
            attachmentType: 4,
            attachmentMeta: LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                media.attachmentMeta),
          ),
        );
      } else if (media.attachmentType == LMMediaType.widget) {
        attachments.add(
          Attachment(
            attachmentType: 5,
            attachmentMeta: LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
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
          throw Exception('Attachment file not found');
        }

        if (media.attachmentType == LMMediaType.video ||
            media.attachmentType == LMMediaType.reel) {
          final uploadThumbnailResponse =
              await _uploadThumbnail(mediaFile, media, event.user);
          if (!uploadThumbnailResponse.success) {
            emit(
              LMFeedMediaUploadErrorState(
                errorMessage: uploadThumbnailResponse.errorMessage ?? " ",
                tempId: event.tempId,
              ),
            );
            return LMResponse.error(
                errorMessage: uploadThumbnailResponse.errorMessage ?? "");
          }
          // if platform is not web, compress the video
          // before uploading, assign the compressed file to mediaFile
          if (!kIsWeb) {
            var tempFile = await VideoCompress.compressVideo(
              mediaFile.path,
              deleteOrigin: false,
              includeAudio: true,
            );
            if (tempFile != null && tempFile.file != null) {
              mediaFile = tempFile.file!;
              if (tempFile.filesize != null) {
                media.attachmentMeta.size = tempFile.filesize;
              }
            }
          }
        }

        final LMResponse<String> response = await LMFeedMediaService.uploadFile(
          kIsWeb ? media.attachmentMeta.bytes! : mediaFile.readAsBytesSync(),
          event.user.sdkClientInfo.uuid,
          fileName: media.attachmentMeta.meta?['file_name'],
        );

        if (response.success) {
          media.attachmentMeta.url = response.data;
          attachments.add(
            Attachment(
              attachmentType: media.attachmentType.value,
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                media.attachmentMeta,
              ),
            ),
          );
          event.progressController.add(index / event.postMedia.length);
        } else {
          emit(
            LMFeedMediaUploadErrorState(
              errorMessage: "Media upload failed",
              tempId: event.tempId,
            ),
          );
          return LMResponse.error(errorMessage: "Media upload failed");
        }
      }
      index++;
    }
  }

  // Emit the new state with uploaded attachments
  emit(LMFeedMediaUploadedState(
    attachments: attachments,
    mediaViewData: attachments
        .map((a) => LMAttachmentViewDataConvertor.fromAttachment(
              attachment: a,
              users: {},
            ))
        .toList(),
  ));

  // Delete temporary post if media upload is successful
  final DeleteTemporaryPostRequest deleteTemporaryPostRequest =
      (DeleteTemporaryPostRequestBuilder()..temporaryPostId(event.tempId))
          .build();
  await LMFeedCore.client.deleteTemporaryPost(deleteTemporaryPostRequest);

  return LMResponse.success(data: attachments);
}

Future<LMResponse<void>> _uploadThumbnail(
    File mediaFile, LMAttachmentViewData media, LMUserViewData user) async {
  String? thumbnailURL;
  String? thumbnailPath = await LMFeedVideoUtils.getThumbnailFile(
    path: mediaFile.path,
  );

  if (thumbnailPath != null) {
    File thumbnailFile = File(thumbnailPath);
    final LMResponse<String> response = await LMFeedMediaService.uploadFile(
        thumbnailFile.readAsBytesSync(), user.sdkClientInfo.uuid);
    if (response.success) {
      thumbnailURL = response.data;
      media.attachmentMeta.thumbnailUrl = thumbnailURL;
      return LMResponse.success(data: null);
    }
    return LMResponse.error(
        errorMessage: response.errorMessage ?? "Thumbnail upload failed");
  }
  return LMResponse.error(errorMessage: "No thumbnail found");
}
