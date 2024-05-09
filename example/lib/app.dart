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

  @override
  void initState() {
    super.initState();
    initialiseFeed = LMFeedCore.instance
        .showFeedWithoutApiKey(widget.accessToken, widget.refreshToken);
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
                    initialiseFeed = LMFeedCore.instance.showFeedWithoutApiKey(
                        widget.accessToken, widget.refreshToken);
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
