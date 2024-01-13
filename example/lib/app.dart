// import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_example/constants/theme.dart';
import 'package:likeminds_feed_example/globals.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMSampleApp extends StatefulWidget {
  const LMSampleApp({super.key});

  @override
  State<LMSampleApp> createState() => _LMSampleAppState();
}

class _LMSampleAppState extends State<LMSampleApp> {
  Future<InitiateUserResponse>? initiateUser;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    super.initState();
    // var env = DotEnv(includePlatformEnvironment: true)..load();

    initiateUser =
        LMFeedCore.instance.initiateUser((InitiateUserRequestBuilder()
              ..userId("56b35125-770d-4a2b-8591-03ee169cb528 ")
              ..userName("Flutter Faad Team Bot"))
            .build())
          ..then((value) async {
            if (value.success) {
              memberState = LMFeedCore.instance.getMemberState();
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    return LMFeedTheme(
      theme: LMFeedThemeData.light(),
      child: MaterialApp(
        title: 'Integration App for UI + SDK package',
        debugShowCheckedModeBanner: true,
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: clientTheme,
        home: Scaffold(
          body: FutureBuilder(
              future: initiateUser,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.success) {
                  return FutureBuilder(
                      future: memberState,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.success) {
                          return const LMFeedScreen();
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        } else {
                          return const Center(
                            child: Text("An error occurred"),
                          );
                        }
                      });
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else {
                  return const Center(
                    child: Text("Nothing"),
                  );
                }
              }),
        ),
        // ),
      ),
    );
  }
}
