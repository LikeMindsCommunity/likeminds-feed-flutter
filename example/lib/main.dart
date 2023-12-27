import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_example/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LMFeedClient lmFeedClient = (LMFeedClientBuilder()..apiKey("")).build();
  await UserLocalPreference.instance.initialize();
  LMFeedIntegration.instance.initialize(
    lmFeedClient: lmFeedClient,
  );
  runApp(const LMSampleApp());
}
