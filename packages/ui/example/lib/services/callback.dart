import 'package:likeminds_feed/likeminds_feed.dart';

class SampleCallback extends LMSDKCallback {
  @override
  void eventFiredCallback(String eventKey, Map<String, dynamic> propertiesMap) {
    // implement eventFiredCallback
  }

  @override
  void loginRequiredCallback() {
    // implement loginRequiredCallback
  }

  @override
  void logoutCallback() {
    // implement logoutCallback
  }
}
