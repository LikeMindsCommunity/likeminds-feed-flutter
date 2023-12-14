part of '../media_bloc.dart';

uploadFileHandler(UploadFile event, Emitter<MediaState> emitter) async {
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
