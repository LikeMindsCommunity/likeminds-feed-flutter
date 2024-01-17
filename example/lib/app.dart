// import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMSampleApp extends StatefulWidget {
  final String? userId;
  final String userName;
  const LMSampleApp({super.key, this.userId, required this.userName});

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

    InitiateUserRequestBuilder request = InitiateUserRequestBuilder();

    if (widget.userId != null && widget.userId!.isNotEmpty) {
      request.userId(widget.userId!);
    }

    if (widget.userName.isNotEmpty) {
      request.userName(widget.userName);
    }

    initiateUser = LMFeedCore.instance.initiateUser(request.build())
      ..then(
        (value) async {
          if (value.success) {
            memberState = LMFeedCore.instance.getMemberState();
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initiateUser,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.success) {
              return FutureBuilder(
                  future: memberState,
                  builder: (context, snapshot) {
                    if (ConnectionState.done == snapshot.connectionState &&
                        snapshot.hasData &&
                        snapshot.data!.success) {
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
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else {
              return const Center(
                child: Text("Nothing"),
              );
            }
          }),
    );
  }
}
