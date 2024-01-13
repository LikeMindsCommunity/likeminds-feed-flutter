import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/ui_constants.dart';

import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedPostSomething extends StatelessWidget {
  final bool enabled;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? primaryColor;

  const LMFeedPostSomething({
    Key? key,
    required this.enabled,
    this.borderColor,
    this.backgroundColor,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = LMFeedUserLocalPreference.instance.fetchUserData();
    Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: enabled
          ? () {
              LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                eventName: LMFeedAnalyticsKeys.postCreationStarted,
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
              LMFeedProfilePicture(
                fallbackText: user.name,
                style: LMFeedProfilePictureStyle(
                  boxShape: BoxShape.circle,
                  backgroundColor: LMThemeData.theme.primaryColor,
                  size: 36,
                ),
                imageUrl: user.imageUrl,
                onTap: () {
                  if (user.sdkClientInfo != null) {
                    LMFeedCore.client
                        .routeToProfile(user.sdkClientInfo!.userUniqueId);
                  }
                },
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
