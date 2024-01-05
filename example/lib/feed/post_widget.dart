import 'package:flutter/material.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

Widget clientPostWidgetBuilder(
    BuildContext context, LMPostMetaData postMetaData) {
  Size screenSize = MediaQuery.of(context).size;
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
    ),
    child: LMPostWidget(
      post: postMetaData.postViewData,
      user: postMetaData.users[postMetaData.postViewData.userId]!,
      onPostTap: (context, postViewData) {
        if (postMetaData.source == LMPostSource.feed) {
          LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
              eventName: LMAnalyticsKeys.commentListOpen,
              eventProperties: {
                'postId': postMetaData.postViewData.id,
              }));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LMPostDetailScreen(
                postId: postMetaData.postViewData.id,
                isFeed: false,
                postBuilder: (context, post) {
                  return clientPostWidgetBuilder(context, post);
                },
              ),
            ),
          );
        }
      },
      isFeed: true,
      onTagTap: (String userId) {},
      topics: postMetaData.topics,
      mediaBuilder: (context, post) {
        return LMPostMedia(
          attachments: postMetaData.postViewData.attachments!,
          width: screenSize.width,
        );
      },
      // footerBuilder: (context, post) {
      //   return Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
      //     child: LMPostFooter(
      //       children: [
      //         LMTextButton(
      //           text: LMTextView(
      //               text:
      //                   getPostLikesText(postMetaData.postViewData.likeCount)),
      //           margin: 0,
      //           onTap: () async {
      //             if (post.postViewData.isLiked) {
      //               postMetaData.postViewData.likeCount =
      //                   postMetaData.postViewData.likeCount - 1;
      //             } else {
      //               postMetaData.postViewData.likeCount =
      //                   postMetaData.postViewData.likeCount + 1;
      //             }
      //             postMetaData.postViewData.isLiked =
      //                 !postMetaData.postViewData.isLiked;
      //             LMPostBloc.instance
      //                 .add(LMUpdatePost(post: postMetaData.postViewData));
      //           },
      //           icon: const LMIcon(
      //             type: LMIconType.svg,
      //             assetPath: clientLikeUnfilled,
      //             size: 24,
      //             boxPadding: 6,
      //           ),
      //           activeIcon: const LMIcon(
      //             type: LMIconType.svg,
      //             assetPath: clientLikeFilled,
      //             color: Colors.red,
      //             size: 24,
      //             boxPadding: 6,
      //           ),
      //           isActive: postMetaData.postViewData.isLiked,
      //         ),
      //         const SizedBox(width: 6),
      //         LMTextButton(
      //           text: LMTextView(
      //               text: getPostCommentButtonText(
      //                   postMetaData.postViewData.commentCount)),
      //           margin: 0,
      //           onTap: () {
      //             if (postMetaData.source == LMPostSource.feed) {
      //               LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
      //                   eventName: LMAnalyticsKeys.commentListOpen,
      //                   eventProperties: {
      //                     'postId': postMetaData.postViewData.id,
      //                   }));
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => LMPostDetailScreen(
      //                     postId: post.postViewData.id,
      //                     isFeed: false,
      //                     postBuilder: (context, post) {
      //                       return clientPostWidgetBuilder(
      //                           context, postMetaData);
      //                     },
      //                   ),
      //                 ),
      //               );
      //             }
      //           },
      //           icon: const LMIcon(
      //             type: LMIconType.svg,
      //             assetPath: clientComment,
      //             size: 20,
      //             boxPadding: 6,
      //           ),
      //         ),
      //         const Spacer(),
      //         LMIconButton(
      //           onTap: (_) {
      //             // String? postType = postDetails!.attachments == null ||
      //             //         postDetails!.attachments!.isEmpty
      //             //     ? 'text'
      //             //     : getPostType(
      //             //         postDetails!.attachments?.first.attachmentType ?? 0);

      //             // LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
      //             //   eventName: LMAnalyticsKeys.postShared,
      //             //   eventProperties: {
      //             //     "post_id": postMetaData.postViewData.id,
      //             //     "post_type": postType,
      //             //     "user_id": user.userUniqueId,
      //             //   },
      //             // ));
      //             // SharePost().sharePost(postMetaData.postViewData.id);
      //           },
      //           icon: const LMIcon(
      //             type: LMIconType.svg,
      //             assetPath: clientShare,
      //             size: 20,
      //           ),
      //         ),
      //       ],
      //     ),
      //   );
      // },
    ),
  );
}

// Widget clientCommentWidgetBuilder(
//     BuildContext context,
//     LMPostViewData postViewData,
//     LMCommentViewData commentViewData,
//     LMUserViewData user) {
//   return LMCommentTile(
//     user: user,
//     comment: commentViewData,
//     onTagTap: (String userId) {},
//     commentActions: [
//       LMTextButton(
//         margin: 10,
//         text: LMTextView(
//           text: commentViewData.likesCount == 0
//               ? "Like"
//               : commentViewData.likesCount == 1
//                   ? "1 Like"
//                   : "${commentViewData.likesCount} Likes",
//           textStyle: const TextStyle(
//               color: LMThemeData.kSecondaryColor700, fontSize: 12),
//         ),
//         activeText: LMTextView(
//           text: commentViewData.likesCount == 0
//               ? "Like"
//               : commentViewData.likesCount == 1
//                   ? "1 Like"
//                   : "${commentViewData.likesCount} Likes",
//           textStyle: TextStyle(color: LMThemeData.kPrimaryColor, fontSize: 12),
//         ),
//         onTap: () async {
//           commentViewData.likesCount = commentViewData.isLiked
//               ? commentViewData.likesCount - 1
//               : commentViewData.likesCount + 1;
//           commentViewData.isLiked = !commentViewData.isLiked;

//           ToggleLikeCommentRequest toggleLikeCommentRequest =
//               (ToggleLikeCommentRequestBuilder()
//                     ..commentId(commentViewData.id)
//                     ..postId(postViewData.id))
//                   .build();

//           final ToggleLikeCommentResponse response = await LMFeedCore
//               .instance.lmFeedClient
//               .likeComment(toggleLikeCommentRequest);

//           if (!response.success) {
//             commentViewData.likesCount = commentViewData.isLiked
//                 ? commentViewData.likesCount - 1
//                 : commentViewData.likesCount + 1;
//             commentViewData.isLiked = !commentViewData.isLiked;

//             _postDetailScreenHandler!.rebuildPostWidget.value =
//                 !_postDetailScreenHandler!.rebuildPostWidget.value;
//           }
//         },
//         icon: const LMIcon(
//           type: LMIconType.icon,
//           icon: Icons.thumb_up_alt_outlined,
//           size: 20,
//         ),
//         activeIcon: const LMIcon(
//           type: LMIconType.svg,
//           color: Colors.red,
//           assetPath: clientLikeFilled,
//           size: 20,
//         ),
//         isActive: commentViewData.isLiked,
//       ),
//       const SizedBox(width: 12),
//       Row(
//         children: [
//           LMTextButton(
//             margin: 10,
//             text: const LMTextView(
//                 text: "Reply",
//                 textStyle: TextStyle(
//                   fontSize: 12,
//                 )),
//             onTap: () {
//               LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
//                     ..commentActionEntity(LMCommentType.parent)
//                     ..commentActionType(LMCommentActionType.replying)
//                     ..level(0)
//                     ..user(_postDetailScreenHandler!
//                         .users[commentViewData.userId]!)
//                     ..commentId(commentViewData.id))
//                   .build();

//               _postDetailScreenHandler!.commentHandlerBloc
//                   .add(LMCommentOngoingEvent(commentMetaData: commentMetaData));

//               _postDetailScreenHandler!.openOnScreenKeyboard();
//             },
//             icon: const LMIcon(
//               type: LMIconType.icon,
//               icon: Icons.comment_outlined,
//               size: 20,
//             ),
//           ),
//           LMThemeData.kHorizontalPaddingMedium,
//           commentViewData.repliesCount > 0
//               ? LMTextButton(
//                   onTap: () {
//                     if (replyShown &&
//                         commentIdReplyId != null &&
//                         commentIdReplyId == commentViewData.id) {
//                       _commentRepliesBloc.add(LMClearCommentReplies());
//                       replyShown = false;
//                       commentIdReplyId = null;
//                     } else if (replyShown &&
//                         commentIdReplyId != null &&
//                         commentIdReplyId != commentViewData.id) {
//                       _commentRepliesBloc.add(LMClearCommentReplies());
//                       replyShown = true;
//                       commentIdReplyId = commentViewData.id;
//                       _commentRepliesBloc.add(LMGetCommentReplies(
//                           commentDetailRequest: (GetCommentRequestBuilder()
//                                 ..commentId(commentViewData.id)
//                                 ..postId(widget.postId)
//                                 ..page(1))
//                               .build(),
//                           forLoadMore: true));
//                     } else {
//                       replyShown = true;
//                       commentIdReplyId = commentViewData.id;
//                       _commentRepliesBloc.add(LMGetCommentReplies(
//                           commentDetailRequest: (GetCommentRequestBuilder()
//                                 ..commentId(commentViewData.id)
//                                 ..postId(widget.postId)
//                                 ..page(1))
//                               .build(),
//                           forLoadMore: true));
//                     }
//                     _postDetailScreenHandler!.rebuildPostWidget.value =
//                         !_postDetailScreenHandler!.rebuildPostWidget.value;
//                   },
//                   text: LMTextView(
//                     text:
//                         "${commentViewData.repliesCount} ${commentViewData.repliesCount > 1 ? 'Replies' : 'Reply'}",
//                     textStyle: const TextStyle(
//                       color: LMThemeData.kPrimaryColor,
//                     ),
//                   ),
//                 )
//               : const SizedBox(),
//         ],
//       ),
//     ],
//     actionsPadding: const EdgeInsets.only(left: 48),
//     onMenuTap: (id) {
//       if (id == commentDeleteId) {
//         // Delete post
//         showDialog(
//             context: context,
//             builder: (childContext) => LMDeleteConfirmationDialog(
//                   title: 'Delete Comment',
//                   userId: commentViewData.userId,
//                   content:
//                       'Are you sure you want to delete this post. This action can not be reversed.',
//                   action: (String reason) async {
//                     Navigator.of(childContext).pop();

//                     LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
//                       eventName: LMAnalyticsKeys.commentDeleted,
//                       eventProperties: {
//                         "post_id": widget.postId,
//                         "comment_id": commentViewData.id,
//                       },
//                     ));

//                     DeleteCommentRequest deleteCommentRequest =
//                         (DeleteCommentRequestBuilder()
//                               ..postId(widget.postId)
//                               ..commentId(commentViewData.id)
//                               ..reason(reason.isEmpty
//                                   ? "Reason for deletion"
//                                   : reason))
//                             .build();

//                     LMCommentMetaData commentMetaData =
//                         (LMCommentMetaDataBuilder()
//                               ..commentActionEntity(LMCommentType.parent)
//                               ..commentActionType(LMCommentActionType.delete)
//                               ..level(0)
//                               ..commentId(commentViewData.id))
//                             .build();

//                     _postDetailScreenHandler!.commentHandlerBloc.add(
//                         LMCommentActionEvent(
//                             commentActionRequest: deleteCommentRequest,
//                             commentMetaData: commentMetaData));
//                   },
//                   actionText: 'Delete',
//                 ));
//       } else if (id == commentEditId) {
//         debugPrint('Editing functionality');
//         LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
//               ..commentActionEntity(LMCommentType.parent)
//               ..commentActionType(LMCommentActionType.edit)
//               ..level(0)
//               ..commentId(commentViewData.id))
//             .build();

//         _postDetailScreenHandler!.commentHandlerBloc
//             .add(LMCommentOngoingEvent(commentMetaData: commentMetaData));
//       }
//     },
//   );
// }
