import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/handler/post_detail_screen_handler.dart';

class LMFeedAddCommentWidgetStyle {}

class LMFeedAddCommentWidget extends StatefulWidget {
  const LMFeedAddCommentWidget({
    super.key,
    required this.postDetailScreenHandler,
    required this.postId,
    this.onCancelTap,
    this.onPostTap,
    this.onTagTap,
    this.onProfileTap,
  });
  final LMFeedPostDetailScreenHandler postDetailScreenHandler;
  final String postId;
  final VoidCallback? onCancelTap;
  final VoidCallback? onPostTap;
  final VoidCallback? onTagTap;
  final VoidCallback? onProfileTap;

  LMFeedAddCommentWidget copyWith({
    LMFeedPostDetailScreenHandler? postDetailScreenHandler,
    String? postId,
    VoidCallback? onCancelTap,
    VoidCallback? onPostTap,
    VoidCallback? onTagTap,
    VoidCallback? onProfileTap,
  }) {
    return LMFeedAddCommentWidget(
      postDetailScreenHandler:
          postDetailScreenHandler ?? this.postDetailScreenHandler,
      postId: postId ?? this.postId,
      onCancelTap: onCancelTap ?? this.onCancelTap,
      onPostTap: onPostTap ?? this.onPostTap,
      onTagTap: onTagTap ?? this.onTagTap,
      onProfileTap: onProfileTap ?? this.onProfileTap,
    );
  }

  @override
  State<LMFeedAddCommentWidget> createState() => LMFeedAddCommentWidgetState();
}

class LMFeedAddCommentWidgetState extends State<LMFeedAddCommentWidget> {
  late LMFeedPostDetailScreenHandler _postDetailScreenHandler;
  LMUserViewData currentUser = LMUserViewDataConvertor.fromUser(
      LMFeedUserLocalPreference.instance.fetchUserData());
  bool right = true;
  List<LMUserTagViewData> userTags = [];

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler = widget.postDetailScreenHandler;
    right = _postDetailScreenHandler.checkCommentRights();
  }

  @override
  Widget build(BuildContext context) {
    final feedTheme = LMFeedTheme.of(context);
    return SafeArea(
      child: BlocBuilder<LMFeedCommentHandlerBloc, LMFeedCommentHandlerState>(
        bloc: _postDetailScreenHandler.commentHandlerBloc,
        builder: (context, state) => Container(
          decoration: BoxDecoration(
            color: feedTheme.container,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeMindsTheme.kVerticalPaddingMedium,
              state is LMFeedCommentActionOngoingState
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          LMFeedText(
                            text: state.commentMetaData.commentActionType ==
                                    LMFeedCommentActionType.edit
                                ? "Editing ${state.commentMetaData.replyId != null ? 'reply' : 'comment'}"
                                : "Replying to",
                            style: const LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: LikeMindsTheme.greyColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          state.commentMetaData.commentActionType ==
                                  LMFeedCommentActionType.edit
                              ? const SizedBox()
                              : LMFeedText(
                                  text: state.commentMetaData.user!.name,
                                  style: const LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                          const Spacer(),
                          LMFeedButton(
                            onTap: widget.onCancelTap ?? () {},
                            style: const LMFeedButtonStyle(
                              icon: LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: Icons.close,
                                style: LMFeedIconStyle(
                                  color: LikeMindsTheme.greyColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              Container(
                decoration: BoxDecoration(
                    color: feedTheme.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    LMFeedProfilePicture(
                      fallbackText: currentUser.name,
                      imageUrl: currentUser.imageUrl,
                      style: LMFeedProfilePictureStyle(
                        backgroundColor: feedTheme.primaryColor,
                        size: 36,
                      ),
                      onTap: () {
                        widget.onProfileTap?.call();
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LMTaggingAheadTextField(
                        isDown: false,
                        maxLines: 5,
                        onTagSelected: (tag) {
                          userTags.add(tag);
                        },
                        controller: _postDetailScreenHandler.commentController,
                        decoration:
                            feedTheme.textFieldStyle.decoration?.copyWith(
                          enabled: right,
                          hintText: right
                              ? 'Write a comment'
                              : "You do not have permission to comment.",
                        ),
                        focusNode: _postDetailScreenHandler.focusNode,
                        onChange: (String p0) {},
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: !right
                          ? null
                          : state is LMFeedCommentLoadingState
                              ? LMFeedLoader(
                                  color: feedTheme.primaryColor,
                                )
                              : LMFeedButton(
                                  style: const LMFeedButtonStyle(
                                    height: 18,
                                  ),
                                  text: LMFeedText(
                                    text: "Post",
                                    style: LMFeedTextStyle(
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        color: feedTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    widget.onPostTap?.call();
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              LikeMindsTheme.kVerticalPaddingLarge,
            ],
          ),
        ),
      ),
    );
  }
}
