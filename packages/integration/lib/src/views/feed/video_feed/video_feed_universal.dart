import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/video_feed_list.dart';

class LMFeedVideoFeedUniversalScreen extends StatefulWidget {
  const LMFeedVideoFeedUniversalScreen({super.key});

  @override
  State<LMFeedVideoFeedUniversalScreen> createState() =>
      LMFeedVideoFeedUniversalScreenState();
}

class LMFeedVideoFeedUniversalScreenState
    extends State<LMFeedVideoFeedUniversalScreen> {
  final _theme = LMFeedCore.theme;

  final samplePost = (LMPostViewDataBuilder()
        ..id("")
        ..text(
            "Hi this is a sample post, how are you doing? i guess you are doing great. this text is just to show how the post will look like in the feed.")
        ..topics([])
        ..communityId(0)
        ..isPinned(false)
        ..uuid("")
        ..user(LMFeedLocalPreference.instance.fetchUserData()!)
        ..likeCount(0)
        ..commentCount(0)
        ..isSaved(false)
        ..isLiked(false)
        ..menuItems([])
        ..createdAt(DateTime.now())
        ..updatedAt(DateTime.now())
        ..isEdited(false)
        ..replies([])
        ..isDeleted(false)
        ..isRepostedByUser(false)
        ..repostCount(0)
        ..widgets({})
        ..heading("")
        ..commentIds([])
        ..isPendingPost(false)
        ..isReposted(false)
        ..postStatus(LMPostReviewStatus.approved))
      .build();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(

        child: Stack(
          children: [
            LMFeedVideoFeedListView(),
            _defAppBar(),
          ],
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      title: LMFeedText(
        text: 'Reels',
        onTap: () {},
        style: LMFeedTextStyle(
          margin: EdgeInsets.only(
            left: 16,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      leading: SizedBox(),
      style: LMFeedAppBarStyle(
        height: 56,
        backgroundColor: Colors.transparent,
      ),
      trailing: [
        BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
          bloc: LMFeedComposeBloc.instance,
          listener: (context, state) {
            // if state is added video
            // navigate to create short video screen
            if (state is LMFeedComposeAddedReelState) {
              debugPrint(LMFeedComposeBloc.instance.postMedia.toString());
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LMFeedCreateShortVideoScreen();
              }));
            }
          },
          child: LMFeedButton(
            onTap: () {
              LMFeedComposeBloc.instance.add(
                LMFeedComposeAddReelEvent(),
              );
            },
            text: LMFeedText(
              text: 'New post',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _theme.container,
                ),
              ),
            ),
            style: LMFeedButtonStyle(
              backgroundColor: _theme.onContainer.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              borderRadius: 50,
              gap: 6,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmCreateReelSvg,
                style: LMFeedIconStyle(
                  color: _theme.container,
                  size: 20,
                ),
              ),
              margin: EdgeInsets.only(
                right: 9,
              ),
            ),
          ),
        )
      ],
    );
  }
}
