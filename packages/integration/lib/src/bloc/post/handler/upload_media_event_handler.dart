part of '../post_bloc.dart';

Future<List<Attachment>> uploadMediaEventHandler(
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

        if (media.attachmentType == LMMediaType.video) {
          await _handleVideoUpload(mediaFile, media, event.user);
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
              attachmentType: media.mapMediaTypeToInt(),
              attachmentMeta:
                  LMAttachmentMetaViewDataConvertor.toAttachmentMeta(
                media.attachmentMeta,
              ),
            ),
          );
          event.progressController.add(index / event.postMedia.length);
        } else {
          throw Exception('Error uploading file');
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
  return attachments;
}

Future<void> _handleVideoUpload(
    File mediaFile, LMAttachmentViewData media, LMUserViewData user) async {
  String? thumbnailURL;
  String? thumbnailPath = await LMFeedVideoThumbnail.thumbnailFile(
    video: mediaFile.path,
    quality: 8,
  );

  if (thumbnailPath != null) {
    File thumbnailFile = File(thumbnailPath);
    final LMResponse<String> response = await LMFeedMediaService.uploadFile(
        thumbnailFile.readAsBytesSync(), user.sdkClientInfo.uuid);
    if (response.success) {
      thumbnailURL = response.data;
      media.attachmentMeta.thumbnailUrl = thumbnailURL;
    }
  }

  if (!kIsWeb) {
    var tempFile = await VideoCompress.compressVideo(
      mediaFile.path,
      deleteOrigin: false,
      includeAudio: true,
    );

    mediaFile = tempFile!.file!;
  }
}
