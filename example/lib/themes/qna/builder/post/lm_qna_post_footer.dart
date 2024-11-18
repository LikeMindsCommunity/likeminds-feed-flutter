import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/post/lm_qna_add_response_widget.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/post/lm_qna_top_response.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';

class LMQnAPostFooterExample extends StatelessWidget {
  final LMFeedPostFooter footer;
  final LMPostViewData postViewData;
  final LMFeedThemeData feedThemeData;
  final LMFeedWidgetSource? source;

  const LMQnAPostFooterExample({
    super.key,
    required this.feedThemeData,
    required this.footer,
    required this.postViewData,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedButton? likeButton = footer.likeButton?.copyWith(
        text: footer.likeButton?.text?.copyWith(
          text: postViewData.likeCount.toString(),
        ),
        onTap: () {
          footer.likeButton?.onTap.call();
        },
        onTextTap: () {
          LMQnAFeedUtils.showLikesBottomSheet(
            context,
            postViewData.id,
          );
        });
    LMFeedButton? commentButton = footer.commentButton?.copyWith(
      text: footer.commentButton?.text?.copyWith(
        text: postViewData.commentCount.toString(),
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
          LMQnATopResponseWidgetExample(
            topResponses: postViewData.topComments!,
            postViewData: postViewData,
            feedThemeData: feedThemeData,
          ),
        if (source != null && source != LMFeedWidgetSource.postDetailScreen)
          QnAAddResponseExample(
            postCreatorUUID: postViewData.uuid,
            onTap: () {
              commentButton?.onTap.call();
            },
          ),
        const Divider(
          color: dividerDark,
          thickness: 1,
          height: 1,
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 20,
          child: Row(children: [
            likeButton ?? const SizedBox(),
            const SizedBox(width: 20),
            commentButton ?? const SizedBox(),
            const Spacer(),
            if (footer.saveButton != null) footer.saveButton!,
            const SizedBox(width: 10),
            shareButton ?? const SizedBox(),
          ]),
        ),
      ],
    );
  }
}
