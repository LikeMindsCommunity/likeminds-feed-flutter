import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

LMFeedPlatform feedPlatform = LMFeedPlatform.instance;

/// A class that handles media picking and processing for the LMFeed.
class LMFeedMediaHandler {
  /// Picks single/multiple video files and returns their metadata.
  /// This method is used for both picking normal video or reel video
  /// The [allowMultiple] parameter is used to determine if multiple videos can be picked.
  /// The [isReelVideo] parameter is used to determine if the video is a reel video.
  ///
  /// [currentMediaLength] is the current number of media files already picked.
  /// Returns a [Future] that completes with a [LMResponse] containing a list of [LMAttachmentViewData].
  static Future<LMResponse<List<LMAttachmentViewData>>> pickVideos({
    required int currentMediaLength,
    bool allowMultiple = true,
    bool isReelVideo = false,
  }) async {
    try {
      LMFeedComposeScreenConfig composeScreenConfig =
          LMFeedCore.config.composeScreenConfig;
      List<LMAttachmentViewData> videoFiles = [];
      final FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.video,
      );

      if (pickedFiles == null || pickedFiles.files.isEmpty) {
        return LMResponse(success: true);
      }

      // Fetch community configurations for media limits
      CommunityConfigurations? config = LMFeedLocalPreference.instance
          .fetchCommunityConfiguration("media_limits");
      if (config == null || config.value?["max_video_size"] == null) {
        final configResponse =
            await LMFeedCore.instance.lmFeedClient.getCommunityConfigurations();
        if (configResponse.success &&
            configResponse.communityConfigurations != null &&
            configResponse.communityConfigurations!.isNotEmpty) {
          config = configResponse.communityConfigurations!.first;
          LMFeedLocalPreference.instance.storeCommunityConfiguration(config);
        }
      }

      // Set size limit for video files
      final double sizeLimit;
      if (config != null && config.value?["max_video_size"] != null) {
        sizeLimit = config.value!["max_video_size"]! / 1024;
      } else {
        sizeLimit = 100;
      }

      // Check if the current media length exceeds the limit
      if (currentMediaLength >= composeScreenConfig.setting.mediaLimit) {
        return LMResponse(
            success: false,
            errorMessage:
                'A total of ${composeScreenConfig.setting.mediaLimit} attachments can be added to a post');
      } else {
        for (PlatformFile pFile in pickedFiles.files) {
          double fileSize = getFileSizeInDouble(pFile.size);

          final videoInfo =
              await LMFeedVideoUtils.getVideoMetaData(path: pFile.path);

          // Check if the file size exceeds the limit
          if (fileSize > sizeLimit) {
            return LMResponse(
                success: false,
                errorMessage:
                    'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB');
          } else {
            LMAttachmentViewData videoFile;
            if (kIsWeb) {
              videoFile = LMAttachmentViewData.fromMediaBytes(
                attachmentType:
                    isReelVideo ? LMMediaType.reel : LMMediaType.video,
                bytes: pFile.bytes!,
                size: pFile.size,
                duration: videoInfo?.duration?.toInt(),
                meta: {
                  'file_name': pFile.name,
                },
                height: videoInfo?.height,
                width: videoInfo?.width,
              );
            } else {
              videoFile = LMAttachmentViewData.fromMediaPath(
                attachmentType:
                    isReelVideo ? LMMediaType.reel : LMMediaType.video,
                path: pFile.path!,
                size: pFile.size,
                duration: videoInfo?.duration?.toInt(),
                meta: {
                  'file_name': pFile.name,
                },
                height: videoInfo?.height,
                width: videoInfo?.width,
              );
            }
            videoFiles.add(videoFile);
          }
        }
        return LMResponse(success: true, data: videoFiles);
      }
    } on Exception catch (err, stacktrace) {
      LMFeedPersistence.instance.handleException(err, stacktrace);
      return LMResponse(success: false, errorMessage: 'An error occurred');
    }
  }

  /// Picks multiple document files and returns their metadata.
  ///
  /// [currentMediaLength] is the current number of media files already picked.
  /// Returns a [Future] that completes with a [LMResponse] containing a list of [LMAttachmentViewData].
  static Future<LMResponse<List<LMAttachmentViewData>>> pickDocuments(
      int currentMediaLength) async {
    try {
      LMFeedComposeScreenConfig composeScreenConfig =
          LMFeedCore.config.composeScreenConfig;

      final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        dialogTitle: 'Select files',
        allowedExtensions: [
          'pdf',
        ],
      );
      if (pickedFiles != null) {
        // Check if the current media length exceeds the limit
        if (currentMediaLength + pickedFiles.files.length >
            composeScreenConfig.setting.documentLimit) {
          return LMResponse(
              success: false,
              errorMessage:
                  'A total of ${composeScreenConfig.setting.documentLimit} documents can be added to a post');
        }
        List<LMAttachmentViewData> attachedFiles = [];
        for (var pickedFile in pickedFiles.files) {
          // Check if the file size exceeds the limit
          if (getFileSizeInDouble(pickedFile.size) > 100) {
            return LMResponse(
                success: false,
                errorMessage: 'File size should be smaller than 100MB');
          } else {
            LMAttachmentViewData documentFile;

            documentFile = LMAttachmentViewData.fromMediaBytes(
              attachmentType: LMMediaType.document,
              bytes: kIsWeb ? pickedFile.bytes! : null,
              path: kIsWeb ? null : pickedFile.path!,
              format: pickedFile.extension,
              size: pickedFile.size,
              meta: {
                'file_name': pickedFile.name,
              },
            );

            attachedFiles.add(documentFile);
          }
        }

        return LMResponse(success: true, data: attachedFiles);
      } else {
        return LMResponse(success: true);
      }
    } on Exception catch (err, stacktrace) {
      LMFeedPersistence.instance.handleException(err, stacktrace);

      return LMResponse(success: false, errorMessage: 'An error occurred');
    }
  }

  /// Picks multiple image files and returns their metadata.
  ///
  /// [mediaCount] is the current number of media files already picked.
  /// Returns a [Future] that completes with a [LMResponse] containing a list of [LMAttachmentViewData].
  static Future<LMResponse<List<LMAttachmentViewData>>> pickImages(
      int mediaCount) async {
    LMFeedComposeScreenConfig composeScreenConfig =
        LMFeedCore.config.composeScreenConfig;
    final FilePickerResult? list = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      compressionQuality: 0,
    );

    // Fetch community configurations for media limits
    CommunityConfigurations? config = LMFeedLocalPreference.instance
        .fetchCommunityConfiguration("media_limits");
    if (config == null || config.value?["max_image_size"] == null) {
      final configResponse =
          await LMFeedCore.client.getCommunityConfigurations();
      if (configResponse.success &&
          configResponse.communityConfigurations != null &&
          configResponse.communityConfigurations!.isNotEmpty) {
        config = configResponse.communityConfigurations!.first;
        LMFeedLocalPreference.instance.storeCommunityConfiguration(config);
      }
    }

    // Set size limit for image files
    final double sizeLimit;
    if (config != null && config.value?["max_image_size"] != null) {
      sizeLimit = config.value!["max_image_size"]! / 1024;
    } else {
      sizeLimit = 5;
    }

    if (list != null && list.files.isNotEmpty) {
      // Check if the current media length exceeds the limit
      if (mediaCount + list.files.length >
          composeScreenConfig.setting.mediaLimit) {
        return LMResponse(
            success: false,
            errorMessage:
                'A total of ${composeScreenConfig.setting.mediaLimit} attachments can be added to a post');
      }
      List<LMAttachmentViewData> attachedImages = [];

      for (PlatformFile image in list.files) {
        int fileBytes = image.size;
        final dimensions = await LMFeedPlatform.instance.getImageDimensions(
          path: image.path,
          bytes: image.bytes,
        );
        debugPrint('Dimensions: $dimensions');
        double fileSize = getFileSizeInDouble(fileBytes);
        // Check if the file size exceeds the limit
        if (fileSize > sizeLimit) {
          return LMResponse(
              success: false,
              errorMessage:
                  'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB');
        }

        if (kIsWeb) {
          final imageAttachment = LMAttachmentViewData.fromMediaBytes(
            attachmentType: LMMediaType.image,
            bytes: image.bytes!,
            format: 'image',
            meta: {
              'file_name': image.name,
            },
            height: dimensions?.height,
            width: dimensions?.width,
            size: fileBytes,
          );
          attachedImages.add(imageAttachment);
        } else {
          final imageAttachment = LMAttachmentViewData.fromMediaPath(
            attachmentType: LMMediaType.image,
            path: image.path!,
            format: 'image',
            meta: {
              'file_name': image.name,
            },
            height: dimensions?.height,
            width: dimensions?.width,
            size: fileBytes,
          );
          attachedImages.add(imageAttachment);
        }
      }

      return LMResponse(success: true, data: attachedImages);
    } else {
      return LMResponse(success: true);
    }
  }

  /// Picks a single image file and returns its metadata.
  ///
  /// Returns a [Future] that completes with a [LMResponse] containing a [LMAttachmentViewData].
  static Future<LMResponse<LMAttachmentViewData>> pickSingleImage() async {
    final FilePickerResult? list = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    // Fetch community configurations for media limits
    CommunityConfigurations? config = LMFeedLocalPreference.instance
        .fetchCommunityConfiguration("media_limits");
    if (config == null || config.value?["max_image_size"] == null) {
      final configResponse =
          await LMFeedCore.client.getCommunityConfigurations();
      if (configResponse.success &&
          configResponse.communityConfigurations != null &&
          configResponse.communityConfigurations!.isNotEmpty) {
        config = configResponse.communityConfigurations!.first;
        LMFeedLocalPreference.instance.storeCommunityConfiguration(config);
      }
    }

    // Set size limit for image files
    final double sizeLimit;
    if (config != null && config.value?["max_image_size"] != null) {
      sizeLimit = config.value!["max_image_size"]! / 1024;
    } else {
      sizeLimit = 5;
    }

    if (list != null && list.files.isNotEmpty) {
      for (PlatformFile image in list.files) {
        int fileBytes = image.size;
        double fileSize = getFileSizeInDouble(fileBytes);
        // Check if the file size exceeds the limit
        if (fileSize > sizeLimit) {
          return LMResponse(
            success: false,
            errorMessage:
                'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
          );
        }
      }
      LMAttachmentViewData mediaFile;

      mediaFile = LMAttachmentViewData.fromMediaBytes(
          attachmentType: LMMediaType.image,
          bytes: kIsWeb ? list.files.first.bytes! : null,
          path: kIsWeb ? null : list.files.first.path!,
          meta: {
            'file_name': list.files.first.name,
          });

      return LMResponse(success: true, data: mediaFile);
    } else {
      return LMResponse(success: true);
    }
  }
}
