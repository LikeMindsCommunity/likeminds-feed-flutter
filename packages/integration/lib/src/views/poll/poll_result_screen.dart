import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class PollResultScreen extends StatefulWidget {
  const PollResultScreen({super.key});

  @override
  State<PollResultScreen> createState() => _PollResultScreenState();
}

class _PollResultScreenState extends State<PollResultScreen> {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();

  @override
  Widget build(BuildContext context) {
    return _widgetsBuilder.scaffold(
        backgroundColor: theme.container,
        appBar: LMFeedAppBar(
          style: LMFeedAppBarStyle(
            height: 40,
            padding: EdgeInsets.only(
              right: 16,
            ),
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          leading: BackButton(),
          title: LMFeedText(
            text: 'Poll Results',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  dividerColor: theme.primaryColor,
                  indicatorColor: theme.primaryColor,
                  indicatorWeight: 4,
                  labelColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  unselectedLabelColor: theme.inActiveColor,
                  tabs: [
                    Tab(
                      text: 'Spotlight',
                    ),
                    Tab(
                      text: 'Raising Hands',
                    ),
                    Tab(
                      text: 'Thumbs Up',
                    ),
                  ],
                ),
                // Divider(
                //   color: theme.primaryColor,
                //   height: 2,
                // ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return LMFeedTile(
                              leading: LMFeedProfilePicture(
                                  fallbackText: user?.name ?? '',
                                  imageUrl: user?.imageUrl,
                                  style: LMFeedProfilePictureStyle(
                                    size: 40,
                                  )),
                              title: LMFeedText(
                                text: user?.name ?? '',
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                  ),
                                ),
                              ),
                              style: LMFeedTileStyle(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            );
                          }),
                      Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LMFeedIcon(
                            style: LMFeedIconStyle(size: 100),
                            type: LMFeedIconType.png,
                            assetPath: lmNoResponsePng,
                          ),
                          SizedBox(height: 8),
                          LMFeedText(
                            text: 'No Responses',
                            style: LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      )),
                      Center(child: LogoFade()),
                    ],
                  ),
                )
              ],
            )));
  }
}

class LogoFade extends StatefulWidget {
  const LogoFade({super.key});

  @override
  State<LogoFade> createState() => LogoFadeState();
}

class LogoFadeState extends State<LogoFade> {
  double opacityLevel = 1.0;

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  Widget child = const FlutterLogo(size: 100);
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedSwitcher(
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },

          // opacity: opacityLevel,
          duration: const Duration(milliseconds: 500),
          child: child,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (count == 0) {
                count = 1;
                child = SizedBox();
              } else {
                count = 0;
                child = LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmPollSvg,
                );
              }
            });
          },
          child: const Text('Fade Logo'),
        ),
      ],
    );
  }
}
