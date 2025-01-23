import 'package:example_video_feed/app.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

Future<void> main() async {
  // insure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the LikeMinds Feed SDK
  await LMFeedCore.instance.initialize();
  // run the app
  runApp(const LMVideoFeedSampleApp());
}
