import 'dart:io';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/credentials/credentials.dart';
import 'package:path/path.dart' as path;

import 'package:simple_s3/simple_s3.dart';

/// Flutter flavour/environment manager v0.0.1
const _prod = !bool.fromEnvironment('DEBUG');

class LMFeedMediaService {
  late final String _bucketName;
  late final String _poolId;
  final _region = AWSRegions.apSouth1;
  final SimpleS3 _s3Client = SimpleS3();

  static LMFeedMediaService? _instance;

  static LMFeedMediaService get instance =>
      _instance ??= LMFeedMediaService._(_prod);

  LMFeedMediaService._(bool isProd) {
    _bucketName = isProd ? CredsProd.bucketName : CredsDev.bucketName;
    _poolId = isProd ? CredsProd.poolId : CredsDev.poolId;
  }

  Future<String?> uploadFile(File file, String uuid) async {
    try {
      String extension = path.extension(file.path);
      String fileName = path.basenameWithoutExtension(file.path);
      fileName = fileName.replaceAll(RegExp('[^A-Za-z0-9]'), '');
      String currTimeInMilli = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = '$fileName-$currTimeInMilli$extension';

      String dir = path.dirname(file.path);
      String newPath = path.join(dir, fileName);

      File renamedFile = file.copySync(newPath);

      String result = await _s3Client.uploadFile(
        renamedFile,
        _bucketName,
        _poolId,
        _region,
        s3FolderPath: "files/post/$uuid",
      );

      return result;
    } on SimpleS3Errors catch (e, stacktrace) {
      Exception exception = Exception(e.toString());

      LMFeedPersistence.instance.handleException(exception, stacktrace);
      debugPrint(e.name);
      debugPrint(e.index.toString());
      return null;
    }
  }
}
