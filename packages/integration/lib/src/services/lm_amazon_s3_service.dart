import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMAWSWebClient {
  const LMAWSWebClient();

  static Future<LMResponse<String>> uploadFile({
    required String s3UploadUrl,
    required String s3SecretKey,
    required String s3Region,
    required String s3AccessKey,
    required String s3BucketName,
    required String folderName,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final length = fileBytes.length;
    Map<String, String> headers = {
      "Access-Control-Allow-Origin": "*",
      // Required for CORS support to work
      "Access-Control-Allow-Credentials": "true",
      // Required for cookies, authorization headers with HTTPS
      "Access-Control-Allow-Headers":
          "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      "Access-Control-Allow-Methods": "POST, OPTIONS"
    };

    final uri = Uri.parse(s3UploadUrl);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile(
        'file', http.ByteStream.fromBytes(fileBytes), length,
        filename: fileName);
    final policy = Policy.fromS3PresignedPost('$folderName/$fileName',
        s3BucketName, s3AccessKey, 15, length, s3Region);
    final key =
        SigV4.calculateSigningKey(s3SecretKey, policy.datetime, s3Region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());
    req.headers.addAll(headers);
    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    try {
      final res = await req.send();
      debugPrint('S3UploadRequest : ${res.request}');
      var response = await http.Response.fromStream(res);
      print('s3 statusCode :${response.statusCode}');
      print('$fileName uploaded to s3Bucket');
      String url = "$s3UploadUrl$folderName/$fileName";

      return LMResponse(success: true, data: url);
    } catch (e) {
      print(e.toString());
      return LMResponse(success: false, errorMessage: e.toString());
    }
  }
}

class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  int maxFileSize;

  Policy(this.key, this.bucket, this.datetime, this.expiration, this.credential,
      this.maxFileSize, this.region);

  factory Policy.fromS3PresignedPost(
    String key,
    String bucket,
    String accessKeyId,
    int expiryMinutes,
    int maxFileSize,
    String region,
  ) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(Duration(minutes: expiryMinutes))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p =
        Policy(key, bucket, datetime, expiration, cred, maxFileSize, region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {
    return '''
{ "expiration": "$expiration",
  "conditions": [
    {"bucket": "$bucket"},
    ["starts-with", "\$key", "$key"],
    {"acl": "public-read"},
    ["content-length-range", 1, $maxFileSize],
    {"x-amz-credential": "$credential"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "$datetime" }
  ]
}
''';
  }
}
