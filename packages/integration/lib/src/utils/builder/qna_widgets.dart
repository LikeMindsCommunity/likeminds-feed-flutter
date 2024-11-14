part of './widget_utility.dart';

class LMFeedQnAPostFooter extends StatelessWidget {
  final LMFeedPostFooter footer;
  final LMPostViewData postViewData;
  final LMFeedWidgetSource? source;

  const LMFeedQnAPostFooter({
    super.key,
    required this.footer,
    required this.postViewData,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.firstLetterCapitalSingular);
    String upVoteText = LMFeedPostUtils.getLikeTitle(
        LMFeedPluralizeWordAction.firstLetterCapitalSingular);
    if (postViewData.likeCount > 0) {
      upVoteText = "$upVoteText • " + postViewData.likeCount.toString();
    }
    final LMFeedThemeData themeData = LMFeedCore.theme;
    LMFeedButton? likeButton = footer.likeButton?.copyWith(
      text: footer.likeButton?.text?.copyWith(
          text: upVoteText,
          style: LMFeedTextStyle.basic().copyWith(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: LikeMindsTheme.greyColor,
            ),
          )),
      onTap: () {
        footer.likeButton?.onTap.call();
      },
      onTextTap: () {
        footer.likeButton?.onTextTap?.call();
      },
      style: footer.likeButton?.style?.copyWith(
        backgroundColor: LikeMindsTheme.unSelectedColor.withOpacity(0.5),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteSvg,
          style: LMFeedIconStyle.basic().copyWith(
            size: 24,
          ),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteFilledSvg,
          style: LMFeedIconStyle.basic().copyWith(
            size: 24,
          ),
        ),
        border: Border.all(
          color: themeData.backgroundColor,
        ),
        borderRadius: 100,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        margin: EdgeInsets.only(left: 16),
      ),
    );

    final String answerText = postViewData.commentCount == 0
        ? "$commentTitleFirstCapSingular "
        : postViewData.commentCount.toString();
    LMFeedButton? commentButton = footer.commentButton?.copyWith(
      text: footer.commentButton?.text?.copyWith(
        text: answerText,
      ),
    );
    LMFeedButton? shareButton = footer.shareButton
        ?.copyWith(style: footer.shareButton?.style?.copyWith(showText: false));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: (postViewData.topComments != null) ? 10 : 7.5,
        ),
        if (postViewData.commentCount >= 1 &&
            postViewData.topComments != null &&
            postViewData.topComments!.isNotEmpty)
          LMFeedQnATopResponseWidget(
            comment: postViewData.topComments!.first,
            postViewData: postViewData,
          ),
        const Divider(
          thickness: 1,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              likeButton ?? const SizedBox(),
              const Spacer(),
              commentButton ?? const SizedBox(),
              const SizedBox(width: 20),
              if (footer.saveButton != null) footer.saveButton!,
              const SizedBox(width: 10),
              shareButton ?? const SizedBox(),
            ],
          ),
        ),
        if (postViewData.commentCount == 0 &&
            source != null &&
            source != LMFeedWidgetSource.postDetailScreen)
          Column(
            children: [
              const Divider(
                thickness: 1,
                height: 1,
              ),
              LMFeedQnAAddResponse(
                onTap: () {
                  // navigate to post detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LMFeedPostDetailScreen(
                        postId: postViewData.id,
                        openKeyboard: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }
}
