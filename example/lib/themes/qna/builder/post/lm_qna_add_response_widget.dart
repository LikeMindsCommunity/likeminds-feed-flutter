import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';

class QnAAddResponseExample extends StatelessWidget {
  final void Function()? onTap;
  final String postCreatorUUID;

  const QnAAddResponseExample({super.key, this.onTap, required this.postCreatorUUID});

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedCore.theme;
    String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;
    return postCreatorUUID == currentUser.uuid
        ? const SizedBox()
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LMFeedProfilePicture(
                    fallbackText: currentUser.name,
                    imageUrl: currentUser.imageUrl,
                    onTap: () {},
                    style: LMFeedProfilePictureStyle(
                      size: 35,
                      fallbackTextStyle: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LMFeedText(
                        text: "+ Add your $commentTitleSmallCapSingular",
                        style: const LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: 0.2,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
