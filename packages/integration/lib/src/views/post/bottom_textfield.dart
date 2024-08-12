import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc/lm_comment_bloc.dart';

class LMFeedBottomTextField extends StatefulWidget {
  const LMFeedBottomTextField({
    super.key,
    required this.postId,
  });
  final String postId;
  @override
  State<LMFeedBottomTextField> createState() => _LMFeedBottomTextFieldState();
}

class _LMFeedBottomTextFieldState extends State<LMFeedBottomTextField> {
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  late Size screenSize;
  double? screenWidth;
  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  late bool isDesktopWeb;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool right = LMFeedUserUtils.checkCommentRights();
  final LMCommentBloc _commentBloc = LMCommentBloc.instance();
  final ValueNotifier<bool> _rebuildCommentTextField = ValueNotifier(false);
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  final LMUserViewData currentUser =
      LMFeedLocalPreference.instance.fetchUserData()!;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  List<LMUserTagViewData> userTags = [];
  LMPostDetailScreenConfig? config = LMFeedCore.config.postDetailConfig;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    screenWidth = min(webConfig.maxWidth, screenSize.width);
    if (screenSize.width > webConfig.maxWidth && kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth!),
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
      child: SafeArea(
        top: false,
        child: BlocListener<LMCommentBloc, LMCommentState>(
          listener: (context, state) {
            if (state is LMEditingCommentState) {
              _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
              openOnScreenKeyboard();
              _commentController.text = state.comment;
            } else if (state is LMEditingCommentCancelState) {
              _commentController.clear();
              closeOnScreenKeyboard();
              _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
            } else if (state is LMReplyingCommentState) {
              _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
              openOnScreenKeyboard();
            } else if (state is LMReplyCancelState) {
              _commentController.clear();
              _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
              closeOnScreenKeyboard();
            } else {
              _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
            }
          },
          bloc: _commentBloc,
          child: ValueListenableBuilder(
              valueListenable: _rebuildCommentTextField,
              builder: (context, _, __) {
                final LMCommentState state = _commentBloc.state;
                final bool isEditing = (state is LMEditingCommentState);
                final bool isReply = (state is LMReplyingCommentState);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LikeMindsTheme.kVerticalPaddingMedium,
                    isEditing || isReply
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                LMFeedText(
                                  text: isEditing
                                      ? "Editing ${isReply ? 'reply' : '$commentTitleSmallCapSingular'} "
                                      : "Replying to ",
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: feedTheme.onContainer,
                                    ),
                                  ),
                                ),
                                isEditing
                                    ? const SizedBox()
                                    : LMFeedText(
                                        text: (state as LMReplyingCommentState)
                                            .userName,
                                        style: const LMFeedTextStyle(
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                const Spacer(),
                                LMFeedButton(
                                  onTap: () {
                                    isEditing
                                        ? _commentBloc
                                            .add(LMEditCommentCancelEvent())
                                        : _commentBloc
                                            .add(LMReplyCancelEvent());
                                  },
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 6.0),
                      child: Row(
                        children: [
                          LMFeedProfilePicture(
                            fallbackText: currentUser.name,
                            imageUrl: currentUser.imageUrl,
                            style: LMFeedProfilePictureStyle.basic().copyWith(
                              backgroundColor: feedTheme.primaryColor,
                              size: 36,
                              fallbackTextStyle:
                                  LMFeedProfilePictureStyle.basic()
                                      .fallbackTextStyle
                                      ?.copyWith(
                                        textStyle:
                                            LMFeedProfilePictureStyle.basic()
                                                .fallbackTextStyle
                                                ?.textStyle
                                                ?.copyWith(
                                                  fontSize: 14,
                                                ),
                                      ),
                            ),
                            onTap: () {
                              LMFeedCore.instance.lmFeedClient.routeToProfile(
                                  currentUser.sdkClientInfo.uuid);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LMTaggingAheadTextField(
                              isDown: false,
                              enabled:
                                  LMFeedCore.config.composeConfig.enableTagging,
                              maxLines: 5,
                              onTagSelected: (tag) {
                                userTags.add(tag);
                              },
                              onSubmitted: (_) =>
                                  handleCreateCommentButtonAction(),
                              controller: _commentController,
                              decoration:
                                  feedTheme.textFieldStyle.decoration?.copyWith(
                                enabled: right,
                                hintText: right
                                    ? config?.commentTextFieldHint ??
                                        'Write a $commentTitleSmallCapSingular'
                                    : "You do not have permission to create a $commentTitleSmallCapSingular.",
                              ),
                              onChange: (String p0) {},
                              scrollPhysics:
                                  const AlwaysScrollableScrollPhysics(),
                              focusNode: _commentFocusNode,
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: !right
                                ? null
                                : LMFeedButton(
                                    style: const LMFeedButtonStyle(
                                      height: 18,
                                    ),
                                    text: LMFeedText(
                                      text: "Create",
                                      style: LMFeedTextStyle(
                                        textAlign: TextAlign.center,
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: feedTheme
                                                  .textFieldStyle
                                                  .decoration
                                                  ?.hintStyle
                                                  ?.fontSize ??
                                              13,
                                          color: feedTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    onTap: () =>
                                        handleCreateCommentButtonAction(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    LikeMindsTheme.kVerticalPaddingMedium,
                  ],
                );
              }),
        ),
      ),
    );
  }

  void handleCreateCommentButtonAction([LMCommentState? state]) {
    closeOnScreenKeyboard();
    bool isEditing = _commentBloc.state is LMEditingCommentState;
    bool isReply = _commentBloc.state is LMReplyingCommentState;
    // extract text from comment controller
    String commentText = LMFeedTaggingHelper.encodeString(
      _commentController.text,
      userTags,
    ).trim();
    commentText = commentText.trim();
    if (commentText.isEmpty) {
      LMFeedCore.showSnackBar(
        context,
        "Please write something to create a $commentTitleSmallCapSingular",
        _widgetSource,
      );

      return;
    }

    if (isEditing) {
      // edit an existing comment
      final currentState = _commentBloc.state as LMEditingCommentState;
      _commentBloc.add(LMEditCommentEvent(
        widget.postId,
        currentState.commentId,
        commentText,
      ));
    } else if (isReply) {
      // create new reply
      final currentState = _commentBloc.state as LMReplyingCommentState;
      _commentBloc.add(LMReplyCommentEvent(
        postId: widget.postId,
        commentId: currentState.commentId,
        comment: commentText,
      ));
    } else {
      // create new comment
      _commentBloc.add(LMAddCommentEvent(
        postId: widget.postId,
        comment: commentText,
      ));
    }

    _commentController.clear();
    closeOnScreenKeyboard();
    // _postDetailScreenHandler!.users
    //     .putIfAbsent(currentUser.uuid, () => currentUser);

    // if (state is LMFeedCommentActionOngoingState) {
    // if (state.commentMetaData.commentActionType ==
    //     LMFeedCommentActionType.edit) {
    //   if (state.commentMetaData.commentActionEntity ==
    //       LMFeedCommentType.parent) {
    //     EditCommentRequest editCommentRequest = (EditCommentRequestBuilder()
    //           ..postId(widget.postId)
    //           ..commentId(state.commentMetaData.commentId!)
    //           ..text(commentText))
    //         .build();

    // _postDetailScreenHandler!.addTempEditingComment(
    //     state.commentMetaData.commentId ?? '', commentText);

    // _postDetailScreenHandler!.commentHandlerBloc.add(
    //     LMFeedCommentActionEvent(
    //         commentActionRequest: editCommentRequest,
    //         commentMetaData: state.commentMetaData));
    // } else {
    // EditCommentReplyRequest editCommentReplyRequest =
    //     (EditCommentReplyRequestBuilder()
    //           ..commentId(state.commentMetaData.commentId!)
    //           ..postId(widget.postId)
    //           ..replyId(state.commentMetaData.replyId!)
    //           ..text(commentText))
    //         .build();

    // _commentRepliesBloc.add(LMFeedEditLocalReplyEvent(
    //     text: commentText, replyId: state.commentMetaData.replyId!));

    // _postDetailScreenHandler!.commentHandlerBloc.add(
    //     LMFeedCommentActionEvent(
    //         commentActionRequest: editCommentReplyRequest,
    //         commentMetaData: state.commentMetaData));
    // }
    // } else if (state.commentMetaData.commentActionType ==
    // LMFeedCommentActionType.replying) {
    // LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
    //       ..commentActionEntity(LMFeedCommentType.reply)
    //       ..level(1)
    //       ..postId(widget.postId)
    //       ..commentId(state.commentMetaData.commentId!)
    //       ..commentActionType(LMFeedCommentActionType.replying))
    //     .build();
    // AddCommentReplyRequest addReplyRequest =
    //     (AddCommentReplyRequestBuilder()
    //           ..postId(widget.postId)
    //           ..text(commentText)
    //           ..tempId('${-DateTime.now().millisecondsSinceEpoch}')
    //           ..commentId(state.commentMetaData.commentId!))
    //         .build();

    // _postDetailScreenHandler!.addTempReplyCommentToController(
    //   addReplyRequest.tempId ?? '',
    //   commentText,
    //   1,
    //   state.commentMetaData.commentId!,
    //   replyShown,
    // );
    // commentIdReplyId = state.commentMetaData.commentId;
    // replyShown = true;
    // _rebuildComment.value = !_rebuildComment.value;
    // _postDetailScreenHandler!.commentHandlerBloc.add(
    //     LMFeedCommentActionEvent(
    //         commentActionRequest: addReplyRequest,
    //         commentMetaData: commentMetaData));
    // }
    // _postDetailScreenHandler!.openOnScreenKeyboard();
    // } else {
    // _postDetailScreenHandler!.addTempCommentToController(
    //   addCommentRequest.tempId ?? '',
    //   commentText,
    //   0,
    //   createdTime: currentTime,
    // );
    // _postDetailScreenHandler!.commentHandlerBloc.add(LMFeedCommentActionEvent(
    //     commentActionRequest: addCommentRequest,
    //     commentMetaData: commentMetaData));
    // }

    // _postDetailScreenHandler!.closeOnScreenKeyboard();
    // _postDetailScreenHandler!.commentController.clear();
  }

  void closeOnScreenKeyboard() {
    if (_commentFocusNode.hasFocus) {
      _commentFocusNode.unfocus();
    }
  }

  void openOnScreenKeyboard() {
    if (_commentFocusNode.canRequestFocus) {
      _commentFocusNode.requestFocus();
      if (_commentController.text.isNotEmpty) {
        _commentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _commentController.text.length));
      }
    }
  }
}
