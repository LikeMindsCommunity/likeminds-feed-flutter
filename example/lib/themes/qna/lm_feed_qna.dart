library likeminds_feed_flutter_qna;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/compose/fab_button.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/feed/lm_qna_feed.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/widgets_builder.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/onboarding_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/index.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/qna_custom_time_stamps.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';
export 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart'
    hide kAssetNoPostsIcon;

class LMFeedQnA extends StatefulWidget {
  final String? accessToken;
  final String? refreshToken;
  final Function(BuildContext)? backButtonCallback;

  const LMFeedQnA({
    super.key,
    this.accessToken,
    this.refreshToken,
    this.backButtonCallback,
  });

  @override
  State<LMFeedQnA> createState() => _LMFeedQnAState();

  static Future<void> setupFeed({
    String? domain,
  }) async {
    await LMFeedCore.instance.initialize(
      theme: qNaTheme,
      domain: domain,
      // lmFeedClient: lmFeedClient,
      config: LMFeedConfig(
        composeConfig: const LMFeedComposeScreenConfig(
          topicRequiredToCreatePost: true,
          showMediaCount: false,
          enableTagging: false,
          enableDocuments: false,
          enableHeading: true,
          headingRequiredToCreatePost: true,
          userDisplayType: LMFeedComposeUserDisplayType.tile,
          composeHint: "Mention details here to make the post rich",
        ),
        feedScreenConfig: LMFeedScreenConfig(
          
        ),
        postDetailConfig: const LMPostDetailScreenConfig(
            commentTextFieldHint: "Write your response"),
        widgetBuilderDelegate: LMFeedQnAWidgetsExample.instance,
      ),
    );
    LMFeedTimeAgo.instance.setDefaultTimeFormat(LMQnACustomTimeStamps());
  }
}

class _LMFeedQnAState extends State<LMFeedQnA> {
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  ValidateUserResponse? validateUserResponse;
  GetUserFeedMetaResponse? userFeedMetaResponse;
  Future<void>? initFeed;
  LMFeedWidgetBuilderDelegate _widget = LMFeedQnAWidgetsExample.instance;

  @override
  void initState() {
    super.initState();
    initFeed = initializeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initFeed,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            User? user = LMFeedPersistence.instance.getUserDB().data;
            if (user != null) {
              List selectedTopics =
                  userFeedMetaResponse!.userTopics?[user.uuid] ?? [];
              // If the user has not selected any topics, show onboarding screen
              if (selectedTopics.isEmpty) {
                return OnboardingScreen(
                  uuid: user.uuid,
                );
              }
              // else navigate to feed screen
              return LMQnAFeedScreen(
                newPageProgressIndicatorBuilder:
                    _widget.newPageProgressIndicatorBuilderFeed,
                noMoreItemsIndicatorBuilder:
                    _widget.noMoreItemsIndicatorBuilderFeed,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButtonBuilder: qnAFeedCreatePostFABBuilder,
              );
            }
          }
          return const SizedBox();
        },
      ),
    );
  }

  // This functions call the onboarding api and fetch the
  // user topics for fetching the feed
  Future<void> initializeFeed() async {
    // create ValidateUserRequest using accessToken and refreshToken passed in the widget
    // ValidateUserRequestBuilder requestBuilder = ValidateUserRequestBuilder();
    // if (widget.accessToken != null) {
    //   requestBuilder.accessToken(widget.accessToken!);
    // }
    // if (widget.refreshToken != null) {
    //   requestBuilder.refreshToken(widget.refreshToken!);
    // }

    // call initialise feed to onboard the user
    // LMResponse initialiseFeedResponse =
    //     await LMFeedCore.instance.initialiseFeed();

    // return the error message in case the api fails
    // if (!initialiseFeedResponse.success) {
    //   return LMResponse(
    //       success: false,
    //       errorMessage:
    //           initialiseFeedResponse.errorMessage ?? "An error occured");
    // }

    // validateUserResponse = initialiseFeedResponse.data as ValidateUserResponse?;

    // call GetUserMeta api to get user topics
    GetUserFeedMetaResponse getUserFeedMeta =
        await LMQnAFeedUtils.getUserMetaForCurrentUser();

    // return the error message in case the api fails
    if (!getUserFeedMeta.success) {}

    userFeedMetaResponse = getUserFeedMeta;
  }
}
