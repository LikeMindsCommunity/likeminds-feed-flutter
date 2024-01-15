import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_example/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LMFeedClient lmFeedClient = (LMFeedClientBuilder()
  //       ..apiKey("6b51af13-ce28-444b-a571-53a3fb125444"))
  //     .build();
  LMFeedCore.instance.initialize(
      // lmFeedClient: lmFeedClient,
      apiKey: "6b51af13-ce28-444b-a571-53a3fb125444");
  runApp(const LMSampleApp());
}
