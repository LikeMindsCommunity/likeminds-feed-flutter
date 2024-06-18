import 'package:envied/envied.dart';

part 'credentials.g.dart';

///These are BETA sample community credentials
@Envied(path: '.env.fb')
abstract class FirebaseCreds {
  @EnviedField(varName: 'WEB_API_KEY', obfuscate: true)
  static final String webApiKey = _FirebaseCreds.webApiKey;
  @EnviedField(varName: 'WEB_APP_ID', obfuscate: true)
  static final String webAppId = _FirebaseCreds.webAppId;
  @EnviedField(varName: 'ANDROID_API_KEY', obfuscate: true)
  static final String androidApiKey = _FirebaseCreds.androidApiKey;
  @EnviedField(varName: 'ANDROID_APP_ID', obfuscate: true)
  static final String androidAppId = _FirebaseCreds.androidAppId;
  @EnviedField(varName: 'IOS_API_KEY', obfuscate: true)
  static final String iosApiKey = _FirebaseCreds.iosApiKey;
  @EnviedField(varName: 'IOS_APP_ID', obfuscate: true)
  static final String iosAppId = _FirebaseCreds.iosAppId;
  @EnviedField(varName: 'MESSAGING_SENDER_ID', obfuscate: true)
  static final String messagingSenderId = _FirebaseCreds.messagingSenderId;
  @EnviedField(varName: 'PROJECT_ID', obfuscate: true)
  static final String projectId = _FirebaseCreds.projectId;
  @EnviedField(varName: 'STORAGE_BUCKET', obfuscate: true)
  static final String storageBucket = _FirebaseCreds.storageBucket;
  @EnviedField(varName: 'IOS_CLIENT_ID', obfuscate: true)
  static final String iosClientId = _FirebaseCreds.iosClientId;
  @EnviedField(varName: 'IOS_BUNDLE_ID', obfuscate: true)
  static final String iosBundleId = _FirebaseCreds.iosBundleId;
  @EnviedField(varName: 'AUTH_DOMAIN', obfuscate: true)
  static final String authDomain = _FirebaseCreds.authDomain;
  @EnviedField(varName: 'MEASUREMENT_ID', obfuscate: true)
  static final String measurementId = _FirebaseCreds.measurementId;
}
