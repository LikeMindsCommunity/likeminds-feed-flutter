import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_example/globals.dart';
import 'package:overlay_support/overlay_support.dart';

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
    var env = DotEnv(includePlatformEnvironment: true)..load();

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
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        background: Colors.black,
        textColor: Colors.white,
        alignment: Alignment.bottomCenter,
      ),
      child: MaterialApp(
        title: 'Integration App for UI + SDK package',
        debugShowCheckedModeBanner: true,
        navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.deepPurple,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            outlineBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            activeIndicatorBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
        home: Scaffold(
          body: FutureBuilder(
              future: initiateUser,
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
                    child: Text("Nothing"),
                  );
                }
              }),
        ),
      ),
    );
  }
}
