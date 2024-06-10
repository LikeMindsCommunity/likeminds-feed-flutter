import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:permission_handler/permission_handler.dart';

LMFeedPlatform feedPlatform = LMFeedPlatform.instance;

class LMFeedMediaHandler {
  static Future<LMResponse<bool>> handlePermissions(int mediaType) async {
    if (feedPlatform.isAndroid()) {
      PermissionStatus permissionStatus;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (mediaType == 1) {
          permissionStatus = await Permission.photos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return LMResponse(success: true);
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.photos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              return LMResponse(
                  success: false,
                  errorMessage: 'Permissions denied, change app settings');
            } else if (permissionStatus == PermissionStatus.granted) {
              return LMResponse(success: true);
            } else {
              return LMResponse(success: false);
            }
          }
        } else if (mediaType == 2) {
          permissionStatus = await Permission.videos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return LMResponse(success: true);
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.videos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              return LMResponse(
                  success: false,
                  errorMessage: 'Permissions denied, change app settings');
            } else if (permissionStatus == PermissionStatus.granted) {
              return LMResponse(success: true);
            } else {
              return LMResponse(success: false);
            }
          }
        } else if (mediaType == 3) {
          // permissionStatus = await Permission.manageExternalStorage.status;
          // if (permissionStatus == PermissionStatus.granted) {
          //   return true;
          // } else if (permissionStatus == PermissionStatus.denied) {
          //   permissionStatus = await Permission.storage.request();
          //   if (permissionStatus == PermissionStatus.permanentlyDenied) {
          //     toast(
          //       'Permissions denied, change app settings',
          //       duration: Toast.LENGTH_LONG,
          //     );
          //     return false;
          //   } else if (permissionStatus == PermissionStatus.granted) {
          //     return true;
          //   } else {
          //     return false;
          //   }
          // }
          // on android 33, storage permission always returns PermissionStatus.denied, since it is deprecated in android 30 and fully removed in android 33
          return LMResponse(success: true);
        }
      } else {
        // permissionStatus = await Permission.storage.status;
        // if (permissionStatus == PermissionStatus.granted) {
        //   return true;
        // } else {
        //   permissionStatus = await Permission.storage.request();
        //   if (permissionStatus == PermissionStatus.granted) {
        //     return true;
        //   } else if (permissionStatus == PermissionStatus.denied) {
        //     return false;
        //   } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
        //     toast(
        //       'Permissions denied, change app settings',
        //       duration: Toast.LENGTH_LONG,
        //     );
        //     return false;
        //   }
        // }
        // on android 33, storage permission always returns PermissionStatus.denied, since it is deprecated in android 30 and fully removed in android 33
        return LMResponse(success: true);
      }
    }
    return LMResponse(success: true);
  }

  static Future<LMResponse<List<LMAttachmentViewData>>> pickVideos(
      int currentMediaLength) async {
    try {
      LMFeedComposeScreenConfig composeScreenConfig =
          LMFeedCore.config.composeConfig;
      // final XFile? pickedFile =
      List<LMAttachmentViewData> videoFiles = [];
      final FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
      );

      if (pickedFiles == null || pickedFiles.files.isEmpty) {
        return LMResponse(success: true);
      }

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
      final double sizeLimit;
      if (config != null && config.value?["max_video_size"] != null) {
        sizeLimit = config.value!["max_video_size"]! / 1024;
      } else {
        sizeLimit = 100;
      }

      if (currentMediaLength >= composeScreenConfig.mediaLimit) {
        return LMResponse(
            success: false,
            errorMessage:
                'A total of ${composeScreenConfig.mediaLimit} attachments can be added to a post');
      } else {
        for (PlatformFile pFile in pickedFiles.files) {
          File file = File.fromRawPath(pFile.bytes!);
          double fileSize = getFileSizeInDouble(pFile.size);
          if (fileSize > sizeLimit) {
            return LMResponse(
                success: false,
                errorMessage:
                    'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB');
          } else {
            LMAttachmentViewData videoFile;
            if (kIsWeb) {
              videoFile = LMAttachmentViewData.fromMediaBytes(
                attachmentType: LMMediaType.video,
                bytes: pFile.bytes!,
                size: fileSize.toInt(),
                duration: 10,
              );
            } else {
              videoFile = LMAttachmentViewData.fromMediaPath(
                attachmentType: LMMediaType.video,
                path: pFile.path!,
                bytes: pFile.bytes!,
                size: fileSize.toInt(),
                duration: 10,
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

  static Future<LMResponse<List<LMAttachmentViewData>>> pickDocuments(
      int currentMediaLength) async {
    try {
      LMFeedComposeScreenConfig composeScreenConfig =
          LMFeedCore.config.composeConfig;

      final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        dialogTitle: 'Select files',
        allowedExtensions: [
          'pdf',
        ],
      );
      if (pickedFiles != null) {
        if (currentMediaLength + pickedFiles.files.length >
            composeScreenConfig.documentLimit) {
          return LMResponse(
              success: false,
              errorMessage:
                  'A total of ${composeScreenConfig.documentLimit} documents can be added to a post');
        }
        List<LMAttachmentViewData> attachedFiles = [];
        for (var pickedFile in pickedFiles.files) {
          if (getFileSizeInDouble(pickedFile.size) > 100) {
            return LMResponse(
                success: false,
                errorMessage: 'File size should be smaller than 100MB');
          } else {
            LMAttachmentViewData documentFile;

            if (kIsWeb) {
              documentFile = LMAttachmentViewData.fromMediaBytes(
                attachmentType: LMMediaType.document,
                bytes: pickedFile.bytes!,
                format: pickedFile.extension,
                size: pickedFile.size,
              );
            } else {
              documentFile = LMAttachmentViewData.fromMediaPath(
                attachmentType: LMMediaType.document,
                path: pickedFile.path!,
                format: pickedFile.extension,
                size: pickedFile.size,
                bytes: pickedFile.bytes!,
              );
            }

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

  static Future<LMResponse<List<LMAttachmentViewData>>> pickImages(
      int mediaCount) async {
    LMFeedComposeScreenConfig composeScreenConfig =
        LMFeedCore.config.composeConfig;
    // onUploading();
    final FilePickerResult? list = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
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
    final double sizeLimit;
    if (config != null && config.value?["max_image_size"] != null) {
      sizeLimit = config.value!["max_image_size"]! / 1024;
    } else {
      sizeLimit = 5;
    }

    if (list != null && list.files.isNotEmpty) {
      if (mediaCount + list.files.length > composeScreenConfig.mediaLimit) {
        return LMResponse(
            success: false,
            errorMessage:
                'A total of ${composeScreenConfig.mediaLimit} attachments can be added to a post');
      }
      for (PlatformFile image in list.files) {
        int fileBytes = image.size;
        double fileSize = getFileSizeInDouble(fileBytes);
        if (fileSize > sizeLimit) {
          return LMResponse(
              success: false,
              errorMessage:
                  'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB');
        }
      }

      List<LMAttachmentViewData> attachedImages;

      if (kIsWeb) {
        attachedImages = list.files.map((e) {
          return LMAttachmentViewData.fromMediaBytes(
            attachmentType: LMMediaType.image,
            bytes: e.bytes!,
            format: 'image',
          );
        }).toList();
      } else {
        attachedImages = list.files.map((e) {
          return LMAttachmentViewData.fromMediaPath(
            attachmentType: LMMediaType.image,
            path: e.path!,
            bytes: e.bytes!,
            format: 'image',
          );
        }).toList();
      }

      return LMResponse(success: true, data: attachedImages);
    } else {
      return LMResponse(success: true);
    }
  }

  static Future<LMResponse<LMAttachmentViewData>> pickSingleImage() async {
    final FilePickerResult? list = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
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
        if (fileSize > sizeLimit) {
          return LMResponse(
            success: false,
            errorMessage:
                'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
          );
        }
      }
      LMAttachmentViewData mediaFile;

      if (kIsWeb) {
        mediaFile = LMAttachmentViewData.fromMediaBytes(
          attachmentType: LMMediaType.image,
          bytes: list.files.first.bytes!,
        );
      } else {
        mediaFile = LMAttachmentViewData.fromMediaPath(
          attachmentType: LMMediaType.image,
          path: list.files.first.path!,
          bytes: list.files.first.bytes!,
        );
      }

      return LMResponse(success: true, data: mediaFile);
    } else {
      return LMResponse(success: true);
    }
  }
}
