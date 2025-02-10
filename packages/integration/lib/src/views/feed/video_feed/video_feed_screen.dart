import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// export all the required files
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/widget/video_feed_list.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/widget/vertical_post.dart';

class LMFeedVideoFeedScreen extends StatefulWidget {
  const LMFeedVideoFeedScreen({super.key});

  @override
  State<LMFeedVideoFeedScreen> createState() => LMFeedVideoFeedScreenState();
}

class LMFeedVideoFeedScreenState extends State<LMFeedVideoFeedScreen> {
  final _theme = LMFeedCore.theme;
  final _screenBuilder = LMFeedCore.config.videoFeedScreenConfig.builder;

  @override
  Widget build(BuildContext context) {
    return _screenBuilder.scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            LMFeedVideoFeedListView(),
            _screenBuilder.appBarBuilder(context, _defAppBar()),
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
