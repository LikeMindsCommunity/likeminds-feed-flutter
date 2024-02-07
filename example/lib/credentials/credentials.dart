import 'package:envied/envied.dart';

part 'credentials.g.dart';

///These are BETA sample community credentials
@Envied(path: '.env.fb')
abstract class FBCreds {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _FBCreds.apiKey;
  @EnviedField(varName: 'APP_ID_AN', obfuscate: true)
  static final String appIdAN = _FBCreds.appIdAN;
  @EnviedField(varName: 'APP_ID_IOS', obfuscate: true)
  static final String appIdIOS = _FBCreds.appIdIOS;
  @EnviedField(varName: 'MESSAGING_SENDER_ID', obfuscate: true)
  static final String messagingSenderId = _FBCreds.messagingSenderId;
  @EnviedField(varName: 'PROJECT_ID', obfuscate: true)
  static final String projectId = _FBCreds.projectId;
  @EnviedField(varName: 'STORAGE_BUCKET', obfuscate: true)
  static final String storageBucket = _FBCreds.storageBucket;
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static final String iosClientId = _FBCreds.iosClientId;
  @EnviedField(varName: 'IOS_BUNDLE_ID', obfuscate: true)
  static final String iosBundleId = _FBCreds.iosBundleId;
}
