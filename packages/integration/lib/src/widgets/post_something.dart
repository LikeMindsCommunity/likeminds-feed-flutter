import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class PostSomething extends StatelessWidget {
  final bool enabled;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? primaryColor;

  const PostSomething({
    Key? key,
    required this.enabled,
    this.borderColor,
    this.backgroundColor,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = LMUserLocalPreference.instance.fetchUserData();
    Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: enabled
          ? () {
              LMAnalyticsBloc.instance.add(const LMFireAnalyticsEvent(
                eventName: LMAnalyticsKeys.postCreationStarted,
                eventProperties: {},
              ));
              //TODO: Navigate to NewPostScreen
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => const NewPostScreen()));
            }
          : () => toast("You do not have permission to create a post"),
      child: Container(
        width: screenSize.width,
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: backgroundColor,
            border: Border.all(
              width: 1,
              color: borderColor ?? LMThemeData.onSurface,
            ),
          ),
          child: Row(
            children: <Widget>[
              LMProfilePicture(
                fallbackText: user.name,
                backgroundColor: LMThemeData.theme.primaryColor,
                imageUrl: user.imageUrl,
                boxShape: BoxShape.circle,
                onTap: () {
                  if (user.sdkClientInfo != null) {
                    LMFeedCore.client
                        .routeToProfile(user.sdkClientInfo!.userUniqueId);
                  }
                },
                size: 36,
              ),
              LMThemeData.kHorizontalPaddingMedium,
              const LMFeedText(text: "Post something...")
            ],
          ),
        ),
      ),
    );
  }
}
