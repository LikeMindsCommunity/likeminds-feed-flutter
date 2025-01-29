import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final size = MediaQuery.sizeOf(context);
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
                    // user view
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width - 68,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LMFeedPostHeader(
                                  createdAtBuilder: (context, text) {
                                    return text.copyWith(
                                        style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: _theme.container,
                                        shadows: [
                                          Shadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ));
                                  },
                                  user: LMFeedLocalPreference.instance
                                      .fetchUserData()!,
                                  isFeed: true,
                                  postViewData: samplePost,
                                  postHeaderStyle:
                                      LMFeedPostHeaderStyle.basic().copyWith(
                                    titleTextStyle: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
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
                                    subTextStyle: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
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
                                ),
                                LMFeedPostContent(
                                  text: samplePost.text,
                                  style: LMFeedPostContentStyle(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    headingSeparator:
                                        const SizedBox(height: 0.0),
                                    visibleLines: 2,
                                    headingStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _theme.container,
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: _theme.container,
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    expandTextStyle: TextStyle(
                                      fontSize: 14,
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
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                LMFeedButton(
                                  onTap: () {},
                                  style: LMFeedButtonStyle(
                                    gap: 0,
                                    icon: LMFeedIcon(
                                      type: LMFeedIconType.svg,
                                      assetPath: lmLikeInActiveSvg,
                                      style: LMFeedIconStyle(
                                        size: 32,
                                        fit: BoxFit.contain,
                                        color: _theme.container,
                                      ),
                                    ),
                                    activeIcon: LMFeedIcon(
                                      type: LMFeedIconType.svg,
                                      assetPath: lmLikeActiveSvg,
                                      style: LMFeedIconStyle(
                                        size: 32,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    borderRadius: 100,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                          0.1,
                                        ),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                LMFeedText(
                                  text: '31K',
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
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
                                SizedBox(
                                  height: 16,
                                ),
                                LMFeedButton(
                                  onTap: () {},
                                  style: LMFeedButtonStyle(
                                    gap: 0,
                                    icon: LMFeedIcon(
                                      type: LMFeedIconType.svg,
                                      assetPath: lmCommentSvg,
                                      style: LMFeedIconStyle(
                                        size: 32,
                                        color: _theme.container,
                                      ),
                                    ),
                                    borderRadius: 100,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                          0.1,
                                        ),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                LMFeedText(
                                  text: '3.1K',
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
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
                                SizedBox(
                                  height: 16,
                                ),
                                LMFeedButton(
                                  onTap: () {},
                                  style: LMFeedButtonStyle(
                                    gap: 0,
                                    icon: LMFeedIcon(
                                      type: LMFeedIconType.icon,
                                      icon: Icons.more_horiz,
                                      style: LMFeedIconStyle(
                                        size: 32,
                                        color: _theme.container,
                                      ),
                                    ),
                                    borderRadius: 100,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                          0.1,
                                        ),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
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
