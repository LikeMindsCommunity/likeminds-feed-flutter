import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedVideoFeedUniversalScreen extends StatefulWidget {
  const LMFeedVideoFeedUniversalScreen({super.key});

  @override
  State<LMFeedVideoFeedUniversalScreen> createState() =>
      LMFeedVideoFeedUniversalScreenState();
}

class LMFeedVideoFeedUniversalScreenState
    extends State<LMFeedVideoFeedUniversalScreen> {
  final _theme = LMFeedCore.theme;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: 300,
              itemBuilder: (context, index) {
                // generate random color for each page
                // use index and date time to generate completely random color
                final randomNumber = Random.secure().nextInt(0xFFFFFFFF);
                final color = Color((index * randomNumber) & 0xFFFFFFFF);
                return Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      height: double.infinity,
                      color: color,
                      child: Center(
                        child: Material(
                          color: Color.fromARGB(255, 187, 220, 204),
                          borderRadius: BorderRadius.circular(8),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 48),
                            child: Text(
                              'Page $index',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 14, 82, 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: LMFeedPostHeader(
                        user: LMFeedLocalPreference.instance.fetchUserData()!,
                        isFeed: true,
                        postViewData: (LMPostViewDataBuilder()
                              ..id("")
                              ..text("")
                              ..topics([])
                              ..communityId(0)
                              ..isPinned(false)
                              ..uuid("")
                              ..user(LMFeedLocalPreference.instance
                                  .fetchUserData()!)
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
                            .build(),
                      ),
                    ),
                  ],
                );
              },
            ),
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
        onTap: () {
          _pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        style: LMFeedTextStyle(
          margin: EdgeInsets.only(
            left: 16,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _theme.container,
          ),
        ),
      ),
      leading: SizedBox(),
      style: LMFeedAppBarStyle(
        height: 56,
        backgroundColor: Colors.transparent,
      ),
      trailing: [
        LMFeedButton(
          onTap: () {},
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
        )
      ],
    );
  }
}
