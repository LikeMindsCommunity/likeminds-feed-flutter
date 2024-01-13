// Widget clientPostWidgetBuilder(
//     BuildContext context, LMFeedPostWidget postWidget) {
//   return Container(
//     decoration: BoxDecoration(
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           spreadRadius: 1,
//           blurRadius: 1,
//           offset: const Offset(0, 1), // changes position of shadow
//         ),
//       ],
//     ),
//     child: postWidget.copyWith(
//       footerBuilder: (context, postFooter, postViewData) {
//         return postFooter;
//       },
//     ),
//   );
// }

// Widget clientCommentWidgetBuilder(
//     BuildContext context,
//     LMPostViewData postViewData,
//     LMCommentViewData commentViewData,
//     LMUserViewData user) {
//   return LMFeedCommentTile(
//     user: user,
//     comment: commentViewData,
//     onTagTap: (String userId) {},
//     commentActions: [
//       LMTextButton(
//         margin: 10,
//         text: LMFeedText(
//           text: commentViewData.likesCount == 0
//               ? "Like"
//               : commentViewData.likesCount == 1
//                   ? "1 Like"
//                   : "${commentViewData.likesCount} Likes",
//           textStyle: const TextStyle(
//               color: LikeMindsTheme.kSecondaryColor700, fontSize: 12),
//         ),
//         activeText: LMFeedText(
//           text: commentViewData.likesCount == 0
//               ? "Like"
//               : commentViewData.likesCount == 1
//                   ? "1 Like"
//                   : "${commentViewData.likesCount} Likes",
//           textStyle: TextStyle(color: LikeMindsTheme.kPrimaryColor, fontSize: 12),
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
//         icon: const LMFeedIcon(
//           type: LMFeedIconType.icon,
//           icon: Icons.thumb_up_alt_outlined,
//           size: 20,
//         ),
//         activeIcon: const LMFeedIcon(
//           type: LMFeedIconType.svg,
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
//             text: const LMFeedText(
//                 text: "Reply",
//                 textStyle: TextStyle(
//                   fontSize: 12,
//                 )),
//             onTap: () {
//               LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
//                     ..commentActionEntity(LMFeedCommentType.parent)
//                     ..commentActionType(LMFeedCommentActionType.replying)
//                     ..level(0)
//                     ..user(_postDetailScreenHandler!
//                         .users[commentViewData.userId]!)
//                     ..commentId(commentViewData.id))
//                   .build();

//               _postDetailScreenHandler!.commentHandlerBloc
//                   .add(LMFeedCommentOngoingEvent(commentMetaData: commentMetaData));

//               _postDetailScreenHandler!.openOnScreenKeyboard();
//             },
//             icon: const LMFeedIcon(
//               type: LMFeedIconType.icon,
//               icon: Icons.comment_outlined,
//               size: 20,
//             ),
//           ),
//           LikeMindsTheme.kHorizontalPaddingMedium,
//           commentViewData.repliesCount > 0
//               ? LMTextButton(
//                   onTap: () {
//                     if (replyShown &&
//                         commentIdReplyId != null &&
//                         commentIdReplyId == commentViewData.id) {
//                       _commentRepliesBloc.add(LMFeedClearCommentReplies());
//                       replyShown = false;
//                       commentIdReplyId = null;
//                     } else if (replyShown &&
//                         commentIdReplyId != null &&
//                         commentIdReplyId != commentViewData.id) {
//                       _commentRepliesBloc.add(LMFeedClearCommentReplies());
//                       replyShown = true;
//                       commentIdReplyId = commentViewData.id;
//                       _commentRepliesBloc.add(LMFeedGetCommentReplies(
//                           commentDetailRequest: (GetCommentRequestBuilder()
//                                 ..commentId(commentViewData.id)
//                                 ..postId(widget.postId)
//                                 ..page(1))
//                               .build(),
//                           forLoadMore: true));
//                     } else {
//                       replyShown = true;
//                       commentIdReplyId = commentViewData.id;
//                       _commentRepliesBloc.add(LMFeedGetCommentReplies(
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
//                   text: LMFeedText(
//                     text:
//                         "${commentViewData.repliesCount} ${commentViewData.repliesCount > 1 ? 'Replies' : 'Reply'}",
//                     textStyle: const TextStyle(
//                       color: LikeMindsTheme.kPrimaryColor,
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

//                     LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
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
//                               ..commentActionEntity(LMFeedCommentType.parent)
//                               ..commentActionType(LMFeedCommentActionType.delete)
//                               ..level(0)
//                               ..commentId(commentViewData.id))
//                             .build();

//                     _postDetailScreenHandler!.commentHandlerBloc.add(
//                         LMFeedCommentActionEvent(
//                             commentActionRequest: deleteCommentRequest,
//                             commentMetaData: commentMetaData));
//                   },
//                   actionText: 'Delete',
//                 ));
//       } else if (id == commentEditId) {
//         debugPrint('Editing functionality');
//         LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
//               ..commentActionEntity(LMFeedCommentType.parent)
//               ..commentActionType(LMFeedCommentActionType.edit)
//               ..level(0)
//               ..commentId(commentViewData.id))
//             .build();

//         _postDetailScreenHandler!.commentHandlerBloc
//             .add(LMFeedCommentOngoingEvent(commentMetaData: commentMetaData));
//       }
//     },
//   );
// }
