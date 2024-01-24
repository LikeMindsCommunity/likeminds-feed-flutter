import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
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
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return GestureDetector(
      onTap: enabled
          ? () {
              LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                eventName: LMFeedAnalyticsKeys.postCreationStarted,
                eventProperties: {},
              ));
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LMFeedComposeScreen()));
            }
          : () => toast("You do not have permission to create a post"),
      child: SizedBox(
        width: screenSize.width,
        height: 60,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: feedTheme.container,
            border: Border.all(
              width: 1,
              color: feedTheme.disabledColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              LMFeedProfilePicture(
                fallbackText: user.name,
                style: LMFeedProfilePictureStyle(
                  boxShape: BoxShape.circle,
                  backgroundColor: feedTheme.primaryColor,
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
              LikeMindsTheme.kHorizontalPaddingMedium,
              const LMFeedText(text: "Post something...")
            ],
          ),
        ),
      ),
    );
  }
}
