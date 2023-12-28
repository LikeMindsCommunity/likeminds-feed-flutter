import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:simple_s3/simple_s3.dart';

class LMMediaService {
  late final String _bucketName;
  late final String _poolId;
  final _region = AWSRegions.apSouth1;
  final SimpleS3 _s3Client = SimpleS3();

  LMMediaService({required String bucketName, required String poolId}) {
    _bucketName = bucketName;
    _poolId = poolId;
  }

  Future<String?> uploadFile(File file, String userUniqueId) async {
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
        s3FolderPath: "files/post/$userUniqueId",
      );

      return result;
    } on SimpleS3Errors catch (e) {
      debugPrint(e.name);
      debugPrint(e.index.toString());
      return null;
    }
  }
}
