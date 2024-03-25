import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostSomething extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? primaryColor;

  const LMFeedPostSomething({
    Key? key,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LMUserViewData user = LMFeedLocalPreference.instance.fetchUserData()!;
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: screenSize.width,
        child: Container(
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          height: 60,
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
                  LMFeedCore.client.routeToProfile(user.sdkClientInfo.uuid);
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
