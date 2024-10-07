import 'dart:typed_data';

import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/services/lm_amazon_s3_service.dart';
import 'package:likeminds_feed_flutter_core/src/utils/credentials/credentials.dart';

/// Flutter flavour/environment manager v0.0.1
const _prod = !bool.fromEnvironment('LM_DEBUG');

class LMFeedMediaService {
  late final String _bucketName;
  late final String _poolId;
  late final String _region;
  late final String _accessKey;
  late final String _secretKey;

  static LMFeedMediaService? _instance;

  static LMFeedMediaService get instance =>
      _instance ??= LMFeedMediaService._();

  LMFeedMediaService._() {
    _bucketName = _prod ? CredsProd.bucketName : CredsDev.bucketName;
    _poolId = _prod ? CredsProd.poolId : CredsDev.poolId;
    _region = _prod ? CredsProd.region : CredsDev.region;
    _accessKey = _prod ? CredsProd.accessKey : CredsDev.accessKey;
    _secretKey = _prod ? CredsProd.secretKey : CredsDev.secretKey;
  }

  static Future<LMResponse<String>> uploadFile(Uint8List bytes, String postUuid,
      {String? fileName}) async {
    return instance._uploadFile(bytes, postUuid, fileName: fileName);
  }

  Future<LMResponse<String>> _uploadFile(Uint8List bytes, String uuid,
      {String? fileName}) async {
    try {
      String url = "https://${_bucketName}.s3.$_region.amazonaws.com/";
      String folderName = "posts/$uuid";
      String generateFileName =
          fileName ?? "$uuid-${DateTime.now().millisecondsSinceEpoch}";
      LMResponse<String> response = await LMAWSWebClient.uploadFile(
        s3UploadUrl: url,
        s3SecretKey: _secretKey,
        s3Region: _region,
        s3AccessKey: _accessKey,
        s3BucketName: _bucketName,
        folderName: folderName,
        fileName: generateFileName,
        fileBytes: bytes,
      );

      return response;
    } on Exception catch (err) {
      return LMResponse(success: false, errorMessage: err.toString());
    }
  }
}
