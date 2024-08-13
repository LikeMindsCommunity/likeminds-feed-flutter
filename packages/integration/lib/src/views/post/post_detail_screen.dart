// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/bottom_textfield.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_list_widget.dart';
part 'post_detail_screen_configuration.dart';

/// {@template post_detail_screen}
/// A screen that displays a post in detail
/// with comments and likes
/// {@endtemplate}
class LMFeedPostDetailScreen extends StatefulWidget {
  ///{@macro post_detail_screen}
  const LMFeedPostDetailScreen({
    super.key,
    required this.postId,
    this.postBuilder,
    this.appBarBuilder,
    this.commentBuilder,
    this.bottomTextFieldBuilder,
    this.commentSeparatorBuilder,
    this.onPostTap,
    this.onLikeClick,
    this.onCommentClick,
    this.openKeyboard = false,
    this.config,
  });
  // Required variables
  final String postId;

  final Function()? onPostTap;
  final Function()? onLikeClick;
  final Function()? onCommentClick;

  // Optional variables
  // In case the below props are not provided,
  // the default in each case will be used
  /// {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;

  /// {@macro post_appbar_builder}
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  final Widget Function(BuildContext, LMPostViewData)? bottomTextFieldBuilder;

  final Widget Function(BuildContext)? commentSeparatorBuilder;

  final bool openKeyboard;

  final LMPostDetailScreenConfig? config;

  @override
  State<LMFeedPostDetailScreen> createState() => _LMFeedPostDetailScreenState();
}

class _LMFeedPostDetailScreenState extends State<LMFeedPostDetailScreen> {
  late Size screenSize;
  late bool isDesktopWeb;

  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  final LMFeedPostBloc postBloc = LMFeedPostBloc.instance;
  final LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;
  String? commentIdReplyId;
  bool replyShown = false;
  LMFeedThemeData feedTheme = LMFeedCore.theme;

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  bool right = true;
  List<LMUserTagViewData> userTags = [];
  LMPostDetailScreenConfig? config;

  bool isAndroid = LMFeedPlatform.instance.isAndroid();
  bool isWeb = LMFeedPlatform.instance.isWeb();
  double? screenWidth;
  final _commentBloc = LMFeedCommentBloc.instance();
  final ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  LMPostViewData? postData;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("Post ID: ${widget.postId}");
    right = LMFeedUserUtils.checkCommentRights();
    if (widget.openKeyboard && right) {
      openOnScreenKeyboard();
    }
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
  }

  @override
  void didUpdateWidget(covariant LMFeedPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {}
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
  }

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          _commentBloc.add(LMFeedCommentRefreshEvent());
          return Future.value();
        },
        color: feedTheme.primaryColor,
        backgroundColor: feedTheme.container,
        child: BlocListener(
          listener: (context, state) {
            if (state is LMFeedPostUpdateState) {
              if (state.postId == widget.postId) {
                if (state.actionType == LMFeedPostActionType.pollSubmit) {
                  postData = LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? postData!,
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  ).copyWith();
                } else {
                  LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? postData!,
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  );
                }
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
            } else if (state is LMFeedEditPostUploadedState) {
              LMPostViewData editedPost = state.postData.copyWith();
              postData = editedPost;
              rebuildPostWidget.value = !rebuildPostWidget.value;
            } else if (state is LMFeedPostDeletionErrorState) {
              LMFeedCore.showSnackBar(
                context,
                state.message,
                _widgetSource,
              );
            }
          },
          bloc: postBloc,
          child: ValueListenableBuilder(
              valueListenable: rebuildPostWidget,
              builder: (context, _, __) {
                return _widgetBuilder.scaffold(
                  source: _widgetSource,
                  resizeToAvoidBottomInset: true,
                  backgroundColor: feedTheme.backgroundColor,
                  bottomNavigationBar: LMFeedBottomTextField(
                    postId: widget.postId,
                    focusNode: _commentFocusNode,
                  ),
                  appBar: widget.appBarBuilder?.call(context, defAppBar()) ??
                      defAppBar(),
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        width: screenWidth,
                        child: CustomScrollView(
                          slivers: [
                            if (isDesktopWeb)
                              SliverPadding(
                                  padding: EdgeInsets.only(top: 20.0)),
                            SliverToBoxAdapter(
                              child: BlocBuilder<LMFeedCommentBloc,
                                  LMFeedCommentState>(
                                bloc: _commentBloc,
                                buildWhen: (previous, current) {
                                  if (current is LMFeedGetCommentSuccessState) {
                                    return true;
                                  }
                                  if (current is LMFeedGetCommentErrorState) {
                                    return true;
                                  }
                                  if (current is LMFeedGetCommentLoadingState) {
                                    return true;
                                  }
                                  return false;
                                },
                                builder: (context, state) {
                                  if (state is LMFeedGetCommentLoadingState) {
                                    return SizedBox.shrink();
                                  }
                                  if (state is LMFeedGetCommentSuccessState) {
                                    postData = state.post;
                                    return defPostWidget(context, state.post);
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            _defCommentsCount(),
                            LMFeedCommentList(
                              postId: widget.postId,
                              commentBuilder: widget.commentBuilder,
                              commentSeparatorBuilder:
                                  widget.commentSeparatorBuilder,
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 100,
                              ),
                            ),
                          ],
                        )),
                  ),
                );
              }),
        ),
      ),
    );
  }

  SliverToBoxAdapter _defCommentsCount() {
    return SliverToBoxAdapter(
      child: BlocConsumer<LMFeedCommentBloc, LMFeedCommentState>(
        bloc: _commentBloc,
        listener: (context, state) {
          if (state is LMFeedGetCommentSuccessState) {
            _commentCount = state.post.commentCount;
          } else if (state is LMFeedAddCommentSuccessState) {
            if (state.comment.tempId == state.comment.id) {
              _commentCount = _commentCount + 1;
            }
          } else if (state is LMFeedAddCommentErrorState) {
            _commentCount = _commentCount - 1;
          } else if (state is LMFeedDeleteCommentSuccessState) {
            _commentCount = _commentCount - 1;
          } else if (state is LMFeedDeleteCommentErrorState) {
            _commentCount = _commentCount + 1;
          }
        },
        buildWhen: (previous, current) =>
            current is LMFeedGetCommentSuccessState ||
            current is LMFeedGetCommentLoadingState ||
            current is LMFeedAddCommentSuccessState ||
            current is LMFeedDeleteCommentSuccessState,
        builder: (context, state) {
          return _commentCount == 0 ||
                  !config!.showCommentCountOnList ||
                  state is LMFeedGetCommentLoadingState
              ? const SizedBox.shrink()
              : Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: isDesktopWeb
                          ? BorderRadius.vertical(top: Radius.circular(8.0))
                          : null,
                      color: feedTheme.container),
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: feedTheme.commentStyle.padding ??
                      const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                  alignment: Alignment.topLeft,
                  child: LMFeedText(
                    text: LMFeedPostUtils.getCommentCountTextWithCount(
                        _commentCount),
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: feedTheme.onContainer,
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  LMFeedAppBar defAppBar() {
    return LMFeedAppBar(
      leading: LMFeedButton(
        style: LMFeedButtonStyle(
          margin: 20.0,
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: isAndroid ? Icons.arrow_back : CupertinoIcons.chevron_back,
            style: LMFeedIconStyle(
              size: 28,
              color: feedTheme.onContainer,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedText(
            text: postTitleFirstCap,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: feedTheme.onContainer,
              ),
            ),
          ),
          BlocBuilder<LMFeedCommentBloc, LMFeedCommentState>(
            bloc: _commentBloc,
            buildWhen: (previous, current) =>
                current is LMFeedGetCommentSuccessState ||
                current is LMFeedGetCommentLoadingState ||
                current is LMFeedAddCommentSuccessState ||
                current is LMFeedDeleteCommentSuccessState,
            builder: (context, state) {
              return _commentCount == 0 ||
                      !config!.showCommentCountOnList ||
                      state is LMFeedGetCommentLoadingState
                  ? const SizedBox.shrink()
                  : LMFeedText(
                      text: LMFeedPostUtils.getCommentCountTextWithCount(
                              _commentCount)
                          .toLowerCase(),
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: feedTheme.primaryColor,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
      trailing: const [SizedBox(width: 36)],
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 61,
      ),
    );
  }

  LMFeedPostWidget defPostWidget(
      BuildContext context, LMPostViewData postData) {
    return LMFeedPostWidget(
      post: postData,
      user: postData.user,
      topics: postData.topics,
      onMediaTap: (int index) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: postData.attachments ?? [],
              post: postData,
              user: postData.user,
              position: index,
            ),
          ),
        );
      },
      onPostTap: (context, post) {
        widget.onPostTap?.call();
      },
      isFeed: false,
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      style: feedTheme.postStyle,
      header: _defPostHeader(context),
      content: _defContentWidget(postData),
      footer: _defFooterWidget(),
      topicWidget: _defTopicWidget(),
      media: _defPostMedia(),
    );
  }

  LMFeedPostTopic _defTopicWidget() {
    return LMFeedPostTopic(
      topics: postData!.topics,
      post: postData!,
      style: feedTheme.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postData!, topicViewData, _widgetSource),
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      style: feedTheme.contentStyle,
      text: post.text,
      heading: post.heading,
      expanded: true,
    );
  }

  LMFeedPostFooter _defFooterWidget() {
    return LMFeedPostFooter(
      likeButton: defLikeButton(),
      commentButton: defCommentButton(),
      shareButton: defShareButton(),
      saveButton: defSaveButton(),
      repostButton: defRepostButton(),
      postFooterStyle: feedTheme.footerStyle,
      showRepostButton: postData!.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(BuildContext context) {
    LMPostViewData postViewData = postData!;
    LMUserViewData userViewData = postViewData.user;
    return LMFeedPostHeader(
      user: userViewData,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedTheme.headerStyle,
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, _widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, _widgetSource),
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {},
        onMenuOpen: () {
          LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.postMenu,
            eventProperties: {
              'uuid': userViewData.sdkClientInfo.uuid,
              'post_id': postViewData.id,
              'topics': postViewData.topics.map((e) => e.name).toList(),
              'post_type':
                  LMFeedPostUtils.getPostType(postViewData.attachments),
            },
          ));
        },
        action: LMFeedMenuAction(
          onPostReport: () => handlePostReportAction(),
          onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
          onPostUnpin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
          onPostEdit: () {
            // Mute all video controllers
            // to prevent video from playing in background
            // while editing the post
            LMFeedVideoProvider.instance.forcePauseAllControllers();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LMFeedEditPostScreen(
                  postId: widget.postId,
                ),
              ),
            );
          },
          onPostDelete: () {
            String postCreatorUUID = userViewData.sdkClientInfo.uuid;

            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $postTitleFirstCap',
                uuid: postCreatorUUID,
                widgetSource: _widgetSource,
                content:
                    'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();

                  String postType =
                      LMFeedPostUtils.getPostType(postViewData.attachments);

                  postBloc.add(
                    LMFeedDeletePostEvent(
                      postId: postViewData.id,
                      reason: reason,
                      isRepost: postViewData.isRepost,
                      postType: postType,
                      userId: postCreatorUUID,
                      userState: isCm ? "CM" : "member",
                    ),
                  );
                  Navigator.of(context).pop();
                },
                actionText: 'Delete',
              ),
            );
          },
        ),
      ),
    );
  }

  LMFeedPostMedia _defPostMedia() {
    LMPostViewData postViewData = postData!;
    LMUserViewData userViewData = postData!.user;
    return LMFeedPostMedia(
      postId: postViewData.id,
      attachments: postViewData.attachments!,
      style: feedTheme.mediaStyle,
      carouselIndicatorBuilder:
          _widgetBuilder.postMediaCarouselIndicatorBuilder,
      imageBuilder: _widgetBuilder.imageBuilder,
      videoBuilder: _widgetBuilder.videoBuilder,
      pollBuilder: _widgetBuilder.pollWidgetBuilder,
      poll: _defPollWidget(postViewData),
      onMediaTap: (int index) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: postViewData.attachments ?? [],
              post: postViewData,
              user: userViewData,
              position: index,
            ),
          ),
        );
      },
    );
  }

  LMFeedPoll? _defPollWidget(LMPostViewData postViewData) {
    Map<String, bool> isVoteEditing = {"value": false};
    if (postViewData.attachments == null || postViewData.attachments!.isEmpty) {
      return null;
    }
    bool isPoll = false;
    postViewData.attachments?.forEach((element) {
      if (element.attachmentType == LMMediaType.poll) {
        isPoll = true;
      }
    });

    if (!isPoll) {
      return null;
    }

    LMAttachmentMetaViewData pollValue =
        postViewData.attachments!.first.attachmentMeta;
    LMAttachmentMetaViewData previousValue = pollValue.copyWith();
    List<String> selectedOptions = [];
    final ValueNotifier<bool> rebuildPollWidget = ValueNotifier(false);
    return LMFeedPoll(
      rebuildPollWidget: rebuildPollWidget,
      isVoteEditing: isVoteEditing["value"]!,
      selectedOption: selectedOptions,
      attachmentMeta: pollValue,
      style: feedTheme.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: feedTheme.primaryColor,
              containerColor: feedTheme.container),
      onEditVote: (pollData) {
        isVoteEditing["value"] = true;
        selectedOptions.clear();
        selectedOptions.addAll(pollData.options!
            .where((element) => element.isSelected)
            .map((e) => e.id)
            .toList());
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      onOptionSelect: (optionData) async {
        if (hasPollEnded(pollValue.expiryTime)) {
          LMFeedCore.showSnackBar(
            context,
            "Poll ended. Vote can not be submitted now.",
            LMFeedWidgetSource.universalFeed,
          );
          return;
        }
        if ((isPollSubmitted(pollValue.options ?? [])) &&
            !isVoteEditing["value"]!) return;
        if (!isMultiChoicePoll(
            pollValue.multiSelectNo, pollValue.multiSelectState)) {
          submitVote(
            context,
            pollValue,
            [optionData.id],
            postViewData.id,
            isVoteEditing,
            previousValue,
            rebuildPostWidget,
            LMFeedWidgetSource.universalFeed,
          );
        } else if (selectedOptions.contains(optionData.id)) {
          selectedOptions.remove(optionData.id);
        } else {
          selectedOptions.add(optionData.id);
        }
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      showSubmitButton: isVoteEditing["value"]! || showSubmitButton(pollValue),
      showEditVoteButton: !isVoteEditing["value"]! &&
          !isInstantPoll(pollValue.pollType) &&
          !hasPollEnded(pollValue.expiryTime) &&
          isPollSubmitted(pollValue.options ?? []),
      showAddOptionButton: showAddOptionButton(pollValue),
      showTick: (option) {
        return showTick(
            pollValue, option, selectedOptions, isVoteEditing["value"]!);
      },
      isMultiChoicePoll: isMultiChoicePoll(
          pollValue.multiSelectNo, pollValue.multiSelectState),
      pollSelectionText: getPollSelectionText(
          pollValue.multiSelectState, pollValue.multiSelectNo),
      timeLeft: getTimeLeftInPoll(pollValue.expiryTime),
      onSameOptionAdded: () {
        LMFeedCore.showSnackBar(
          context,
          "Option already exists",
          LMFeedWidgetSource.universalFeed,
        );
      },
      onAddOptionSubmit: (option) async {
        await addOption(
          context,
          pollValue,
          option,
          postViewData.id,
          currentUser,
          rebuildPollWidget,
          LMFeedWidgetSource.universalFeed,
        );
        selectedOptions.clear();
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      onSubtextTap: () {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
        );
      },
      onVoteClick: (option) {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
          option: option,
        );
      },
      onSubmit: (options) {
        submitVote(
          context,
          pollValue,
          options,
          postViewData.id,
          isVoteEditing,
          previousValue,
          rebuildPostWidget,
          LMFeedWidgetSource.universalFeed,
        );
      },
    );
  }

  LMFeedButton defLikeButton() => LMFeedButton(
        isActive: postData!.isLiked,
        text: LMFeedText(
            text:
                LMFeedPostUtils.getLikeCountTextWithCount(postData!.likeCount)),
        style: feedTheme.footerStyle.likeButtonStyle,
        onTextTap: () {
          if (postData!.likeCount == 0) {
            return;
          }
          LMFeedVideoProvider.instance.pauseCurrentVideo();

          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedLikesScreen(
                postId: postData!.id,
                widgetSource: _widgetSource,
              ),
            ),
          );
        },
        onTap: () async {
          LMPostViewData postViewData = postData!;
          postBloc.add(LMFeedUpdatePostEvent(
              postId: postViewData.id,
              source: LMFeedWidgetSource.postDetailScreen,
              actionType: postViewData.isLiked
                  ? LMFeedPostActionType.unlike
                  : LMFeedPostActionType.like));

          final likePostRequest =
              (LikePostRequestBuilder()..postId(postViewData.id)).build();

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (response.success) {
            LMFeedPostUtils.handlePostLikeTapEvent(
                postViewData, _widgetSource, postViewData.isLiked);
          }
        },
      );

  LMFeedButton defCommentButton() => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              postData!.commentCount),
        ),
        style: feedTheme.footerStyle.commentButtonStyle,
        onTap: () {
          LMFeedPostUtils.handlePostCommentButtonTap(postData!, _widgetSource);
          openOnScreenKeyboard();
        },
        onTextTap: () {
          openOnScreenKeyboard();
        },
      );

  LMFeedButton defSaveButton() => LMFeedButton(
        isActive: postData!.isSaved,
        onTap: () async {
          LMPostViewData postViewData = postData!;
          postBloc.add(LMFeedUpdatePostEvent(
            postId: postViewData.id,
            source: LMFeedWidgetSource.postDetailScreen,
            actionType: postViewData.isSaved
                ? LMFeedPostActionType.unsaved
                : LMFeedPostActionType.saved,
          ));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postBloc.add(LMFeedUpdatePostEvent(
              postId: postViewData.id,
              source: LMFeedWidgetSource.postDetailScreen,
              actionType: postViewData.isSaved
                  ? LMFeedPostActionType.unsaved
                  : LMFeedPostActionType.saved,
            ));
          } else {
            LMFeedPostUtils.handlePostSaveTapEvent(
                postViewData, postViewData.isSaved, _widgetSource);
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              _widgetSource,
            );
          }
        },
        style: feedTheme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton() => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postData!, _widgetSource);

          LMFeedDeepLinkHandler().sharePost(postData!.id);
        },
        style: feedTheme.footerStyle.shareButtonStyle,
      );
  LMFeedButton defRepostButton() => LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: postData!.isRepostedByUser ? feedTheme.primaryColor : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postData!.repostCount == 0
              ? ''
              : postData!.repostCount.toString(),
        ),
        onTap: right
            ? () async {
                if (postBloc.state is! LMFeedEditPostUploadingState) {
                  LMFeedVideoProvider.instance.forcePauseAllControllers();
                  // ignore: use_build_context_synchronously
                  LMAttachmentViewData attachmentViewData =
                      (LMAttachmentViewDataBuilder()
                            ..attachmentType(LMMediaType.repost)
                            ..attachmentMeta((LMAttachmentMetaViewDataBuilder()
                                  ..repost(postData!))
                                .build()))
                          .build();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LMFeedComposeScreen(
                        attachments: [attachmentViewData],
                        widgetSource: LMFeedWidgetSource.postDetailScreen,
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                    context,
                    'A $postTitleSmallCap is already uploading.',
                    _widgetSource,
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  context,
                  'You do not have permission to create a $postTitleSmallCap',
                  _widgetSource,
                );
              },
        style: feedTheme.footerStyle.repostButtonStyle?.copyWith(
            icon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postData!.isRepostedByUser
                          ? feedTheme.primaryColor
                          : null),
            ),
            activeIcon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postData!.isRepostedByUser
                          ? feedTheme.primaryColor
                          : null),
            )),
      );

  void handlePostReportAction() {
    LMPostViewData postViewData = postData!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedReportScreen(
          entityId: postViewData.id,
          entityType: postEntityId,
          entityCreatorId: postViewData.user.uuid,
        ),
      ),
    );
  }

  void handleCreateCommentButtonAction([LMFeedCommentState? state]) {
    closeOnScreenKeyboard();
    bool isEditing = _commentBloc.state is LMFeedEditingCommentState;
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
      final currentState = _commentBloc.state as LMFeedEditingCommentState;
      _commentBloc.add(LMFeedEditCommentEvent(
        widget.postId,
        currentState.oldComment,
        commentText,
      ));
    } else {
      // create new comment
      _commentBloc.add(LMFeedAddCommentEvent(
        postId: widget.postId,
        commentText: commentText,
      ));
    }

    _commentController.clear();
    closeOnScreenKeyboard();
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
