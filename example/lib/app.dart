// import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMSampleApp extends StatefulWidget {
  final String? accessToken;
  final String? refreshToken;
  const LMSampleApp({super.key, this.accessToken, required this.refreshToken});

  @override
  State<LMSampleApp> createState() => _LMSampleAppState();
}

class _LMSampleAppState extends State<LMSampleApp> {
  Future<LMResponse>? initialiseFeed;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    super.initState();
    callValidateUser();
  }

  void callValidateUser() {
    ValidateUserRequestBuilder request = ValidateUserRequestBuilder();

    if (widget.accessToken != null && widget.accessToken!.isNotEmpty) {
      request.accessToken(widget.accessToken!);
    }

    if (widget.refreshToken != null && widget.refreshToken!.isNotEmpty) {
      request.refreshToken(widget.refreshToken!);
    }

    initialiseFeed = LMFeedCore.instance.initialiseFeed(request.build());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initialiseFeed,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.success) {
            return const LMFeedScreen();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const LMFeedLoader();
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LikeMindsTheme.kVerticalPaddingLarge,
                Center(
                  child: LMFeedText(
                    text: snapshot.data?.errorMessage ??
                        "An error occurred, please try again later",
                    style: const LMFeedTextStyle(textAlign: TextAlign.center),
                  ),
                ),
                LikeMindsTheme.kVerticalPaddingLarge,
                GestureDetector(
                  onTap: () {
                    callValidateUser();
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
