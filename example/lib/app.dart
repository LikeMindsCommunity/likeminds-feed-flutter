import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/cred_screen.dart';
import 'package:likeminds_feed_sample/globals.dart';
import 'package:likeminds_feed_sample/main.dart';

class LMSampleApp extends StatelessWidget {
  const LMSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integration App for UI + SDK package',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: LMFeedBlocListener(
        analyticsListener: (BuildContext context, LMFeedAnalyticsState state) {
          if (state is LMFeedAnalyticsEventFired) {
            debugPrint("Bloc Listened for event, - ${state.eventName}");
            debugPrint("////////////////");
            debugPrint("With properties - ${state.eventProperties}");
          }
        },
        profileListener: (BuildContext context, LMFeedProfileState state) {},
        routingListener: (BuildContext context, LMFeedRoutingState state) {},
        child: const CredScreen(),
      ),
    );
  }
}
