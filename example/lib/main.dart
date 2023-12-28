import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_example/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LMFeedClient lmFeedClient = (LMFeedClientBuilder()..apiKey("")).build();
  await LMUserLocalPreference.instance.initialize();
  LMFeedCore.instance.initialize(
    lmFeedClient: lmFeedClient,
  );
  runApp(const LMSampleApp());
}
