import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedQnAPostFooter extends LMFeedPostFooter {
  final LMPostViewData postViewData;
  final LMFeedWidgetSource? source;

  LMFeedQnAPostFooter({
    super.key,
    required this.postViewData,
    required this.source,
    super.likeButton,
    super.commentButton,
    super.shareButton,
    super.saveButton,
    super.repostButton,
    super.likeButtonBuilder,
    super.commentButtonBuilder,
    super.shareButtonBuilder,
    super.saveButtonBuilder,
    super.repostButtonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final _widgetUtility = LMFeedCore.widgetUtility;
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
          _widgetUtility.topResponseBuilder(
            context,
            LMFeedTopResponseWidget(
              comment: postViewData.topComments!.first,
              postViewData: postViewData,
              style: LMFeedTopResponseWidgetStyle.basic(),
            ),
            postViewData.topComments!.first,
            postViewData,
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
              if (super.saveButton != null) super.saveButton!,
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
              _widgetUtility.addACommentBuilder(
                  context, _defAddResponse(context), postViewData),
            ],
          ),
      ],
    );
  }

  LMFeedAddResponse _defAddResponse(BuildContext context) {
    return LMFeedAddResponse(
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
      style: LMFeedAddResponseStyle.basic(),
    );
  }
}
