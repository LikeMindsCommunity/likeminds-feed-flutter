import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/index.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/notification_icon.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/profile_header_widget.dart';

class LMQnAUserProfileScreen extends StatefulWidget {
  const LMQnAUserProfileScreen({
    super.key,
    required this.uuid,
  });
  final String uuid;

  @override
  State<LMQnAUserProfileScreen> createState() => _LMQnAUserProfileScreenState();
}

class _LMQnAUserProfileScreenState extends State<LMQnAUserProfileScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);

  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: feedThemeData.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // profile image and gradient section
          LMQnAProfileHeaderWidget(
            uuid: widget.uuid,
          ),
          // menu section
          Container(
            color: feedThemeData.container,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                LMFeedTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LMQnAProfileScreen(
                                  uuid: widget.uuid,
                                )));
                  },
                  style: LMFeedTileStyle.basic().copyWith(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10)),
                  leading: const Icon(Icons.person_outline),
                  title: LMFeedText(
                    text: 'My Profile',
                    style: LMFeedTextStyle.basic().copyWith(
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(20, 25, 31, 1),
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                LMFeedTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LMFeedNotificationScreen(),
                      ),
                    );
                  },
                  leading: const NotificationIcon(),
                  style: LMFeedTileStyle.basic().copyWith(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10)),
                  title: LMFeedText(
                    text: 'Notifications',
                    style: LMFeedTextStyle.basic().copyWith(
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(20, 25, 31, 1),
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                LMFeedTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LMFeedSavedPostScreen()));
                  },
                  leading: const Icon(Icons.bookmark_outline),
                  style: LMFeedTileStyle.basic().copyWith(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10)),
                  title: LMFeedText(
                    text: 'Saved $postTitleFirstCap',
                    style: LMFeedTextStyle.basic().copyWith(
                      textStyle: const TextStyle(
                        color: Color.fromRGBO(20, 25, 31, 1),
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
