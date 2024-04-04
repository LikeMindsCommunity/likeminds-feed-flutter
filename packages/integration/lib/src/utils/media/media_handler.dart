import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:permission_handler/permission_handler.dart';

class LMFeedMediaHandler {
  static Future<bool> handlePermissions(int mediaType) async {
    if (Platform.isAndroid) {
      PermissionStatus permissionStatus;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (mediaType == 1) {
          permissionStatus = await Permission.photos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return true;
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.photos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              LMFeedCore.showSnackBar(
                LMFeedSnackBar(
                  content: LMFeedText(
                    text: 'Permissions denied, change app settings',
                  ),
                ),
              );
              return false;
            } else if (permissionStatus == PermissionStatus.granted) {
              return true;
            } else {
              return false;
            }
          }
        } else if (mediaType == 2) {
          permissionStatus = await Permission.videos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return true;
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.videos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              LMFeedCore.showSnackBar(
                LMFeedSnackBar(
                  content: LMFeedText(
                    text: 'Permissions denied, change app settings',
                  ),
                ),
              );
              return false;
            } else if (permissionStatus == PermissionStatus.granted) {
              return true;
            } else {
              return false;
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
          return true;
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
        return true;
      }
    }
    return true;
  }

  static Future<List<LMMediaModel>?> pickVideos(int currentMediaLength) async {
    try {
      // final XFile? pickedFile =
      List<LMMediaModel> videoFiles = [];
      final FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
      );

      if (pickedFiles == null || pickedFiles.files.isEmpty) {
        return null;
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

      if (pickedFiles.files.isNotEmpty) {
        if (currentMediaLength >= 10) {
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text: 'A total of 10 attachments can be added to a post',
              ),
            ),
          );
          return null;
        } else {
          for (PlatformFile pFile in pickedFiles.files) {
            File file = File(pFile.path!);
            int fileBytes = await file.length();
            double fileSize = getFileSizeInDouble(fileBytes);
            if (fileSize > sizeLimit) {
              LMFeedCore.showSnackBar(
                LMFeedSnackBar(
                  content: LMFeedText(
                    text:
                        'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
                  ),
                ),
              );
            } else {
              LMMediaModel videoFile = LMMediaModel(
                mediaType: LMMediaType.video,
                mediaFile: file,
                size: fileSize.toInt(),
                duration: 0,
              );
              videoFiles.add(videoFile);
            }
          }
          return videoFiles;
        }
      } else {
        return null;
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);
      LMFeedCore.showSnackBar(
        LMFeedSnackBar(
          content: LMFeedText(
            text: 'An error occurred',
          ),
        ),
      );
      debugPrint(err.toString());
      return null;
    }
  }

  static Future<List<LMMediaModel>?> pickDocuments(
      int currentMediaLength) async {
    try {
      final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        dialogTitle: 'Select files',
        allowedExtensions: [
          'pdf',
        ],
      );
      if (pickedFiles != null) {
        if (currentMediaLength + pickedFiles.files.length > 3) {
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text: 'A total of 3 documents can be added to a post',
              ),
            ),
          );
          return null;
        }
        List<LMMediaModel> attachedFiles = [];
        for (var pickedFile in pickedFiles.files) {
          if (getFileSizeInDouble(pickedFile.size) > 100) {
            LMFeedCore.showSnackBar(
              LMFeedSnackBar(
                content: LMFeedText(
                  text: 'File size should be smaller than 100MB',
                ),
              ),
            );
          } else {
            LMMediaModel documentFile = LMMediaModel(
              mediaType: LMMediaType.document,
              mediaFile: File(pickedFile.path!),
              format: pickedFile.extension,
              size: pickedFile.size,
            );
            attachedFiles.add(documentFile);
          }
        }

        return attachedFiles;
      } else {
        return null;
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);
      LMFeedCore.showSnackBar(
        LMFeedSnackBar(
          content: LMFeedText(
            text: 'An error occurred',
          ),
        ),
      );
      return null;
    }
  }

  static Future<List<LMMediaModel>?> pickImages(int mediaCount) async {
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
      if (mediaCount + list.files.length > 10) {
        LMFeedCore.showSnackBar(
          LMFeedSnackBar(
            content: LMFeedText(
              text: 'A total of 10 attachments can be added to a post',
            ),
          ),
        );
        return [];
      }
      for (PlatformFile image in list.files) {
        int fileBytes = image.size;
        double fileSize = getFileSizeInDouble(fileBytes);
        if (fileSize > sizeLimit) {
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text:
                    'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
              ),
            ),
          );
          return [];
        }
      }
      List<File> pickedFiles = list.files.map((e) => File(e.path!)).toList();
      List<LMMediaModel> mediaFiles = pickedFiles
          .map(
            (e) => LMMediaModel(
              mediaFile: File(e.path),
              mediaType: LMMediaType.image,
            ),
          )
          .toList();

      return mediaFiles;
    } else {
      return [];
    }
  }

  static Future<LMMediaModel?> pickSingleImage() async {
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
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text:
                    'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
              ),
            ),
          );
          return null;
        }
      }
      List<File> pickedFiles = list.files.map((e) => File(e.path!)).toList();
      LMMediaModel mediaFile = LMMediaModel(
        mediaFile: File(pickedFiles.first.path),
        mediaType: LMMediaType.image,
      );

      return mediaFile;
    } else {
      return null;
    }
  }
}
