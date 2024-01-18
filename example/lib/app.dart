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
    callInitiateUser();
  }

  void callInitiateUser() {
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LikeMindsTheme.kVerticalPaddingLarge,
                const Center(
                  child: LMFeedText(
                    text: "An error occurred, please try again later",
                    style: LMFeedTextStyle(textAlign: TextAlign.center),
                  ),
                ),
                LikeMindsTheme.kVerticalPaddingLarge,
                GestureDetector(
                  onTap: () {
                    callInitiateUser();
                    setState(() {});
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: const Column(
                      children: <Widget>[
                        Icon(
                          Icons.refresh,
                          size: 45,
                          color: Colors.black,
                        ),
                        LikeMindsTheme.kVerticalPaddingSmall,
                        LMFeedText(text: 'Retry')
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
