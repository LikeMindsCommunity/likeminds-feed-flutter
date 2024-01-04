import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_example/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LMFeedClient lmFeedClient = (LMFeedClientBuilder()
        ..apiKey("6b51af13-ce28-444b-a571-53a3fb125444"))
      .build();
  await LMUserLocalPreference.instance.initialize();
  LMFeedCore.instance.initialize(
    lmFeedClient: lmFeedClient,
  );
  runApp(const LMSampleApp());
}
