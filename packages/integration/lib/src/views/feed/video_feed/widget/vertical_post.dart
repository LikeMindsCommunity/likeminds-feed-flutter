import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_vertical_video_post}
/// A widget to display a vertical video post in the feed.
/// Contains the video, post header, post content, post topic, post menu, like button, comment button.
/// Can be customized using the [LMFeedVerticalVideoPostStyle].
/// {@endtemplate}
class LMFeedVerticalVideoPost extends StatefulWidget {
  const LMFeedVerticalVideoPost({
    super.key,
    required this.postViewData,
    this.widgetSource = LMFeedWidgetSource.videoFeed,
    this.videoBuilder,
    this.postHeaderBuilder,
    this.postContentBuilder,
    this.postTopicBuilder,
    this.postMenuBuilder,
    this.postLikeButtonBuilder,
    this.postCommentButtonBuilder,
    this.preActionWidgets = const [],
    this.postActionWidgets = const [],
    this.style,
  });

  /// The post view data to display in the post.
  final LMPostViewData postViewData;

  /// The source of the widget.
  final LMFeedWidgetSource widgetSource;

  ///  The builder for the video widget.
  final LMFeedVideoBuilder? videoBuilder;

  /// The builder for the post header widget.
  final LMFeedPostHeaderBuilder? postHeaderBuilder;

  /// The builder for the post content widget.
  final LMFeedPostContentBuilder? postContentBuilder;

  /// The builder for the post topic widget.
  final LMFeedPostTopicBuilder? postTopicBuilder;

  ///  The builder for the post menu widget.
  final LMFeedPostMenuBuilder? postMenuBuilder;

  /// The builder for the post like button widget.
  final LMFeedButtonBuilder? postLikeButtonBuilder;

  /// The builder for the post comment button widget.
  final LMFeedButtonBuilder? postCommentButtonBuilder;

  /// The list of widgets to display before the action buttons.
  final List<Widget> preActionWidgets;

  /// The list of widgets to display after the action buttons.
  final List<Widget> postActionWidgets;

  /// The style for the vertical video post.
  final LMFeedVerticalVideoPostStyle? style;

  /// copyWith method for the [LMFeedVerticalVideoPost]
  /// This method is used to create a copy of the [LMFeedVerticalVideoPost] with the new values
  /// provided in the parameters.
  LMFeedVerticalVideoPost copyWith({
    LMPostViewData? postViewData,
    LMFeedWidgetSource? widgetSource,
    LMFeedVideoBuilder? videoBuilder,
    LMFeedPostHeaderBuilder? postHeaderBuilder,
    LMFeedPostContentBuilder? postContentBuilder,
    LMFeedPostTopicBuilder? postTopicBuilder,
    LMFeedPostMenuBuilder? postMenuBuilder,
    LMFeedButtonBuilder? postLikeButtonBuilder,
    LMFeedButtonBuilder? postCommentButtonBuilder,
    List<Widget>? preActionWidgets,
    List<Widget>? postActionWidgets,
    LMFeedVerticalVideoPostStyle? style,
  }) {
    return LMFeedVerticalVideoPost(
      postViewData: postViewData ?? this.postViewData,
      widgetSource: widgetSource ?? this.widgetSource,
      videoBuilder: videoBuilder ?? this.videoBuilder,
      postHeaderBuilder: postHeaderBuilder ?? this.postHeaderBuilder,
      postContentBuilder: postContentBuilder ?? this.postContentBuilder,
      postTopicBuilder: postTopicBuilder ?? this.postTopicBuilder,
      postMenuBuilder: postMenuBuilder ?? this.postMenuBuilder,
      postLikeButtonBuilder:
          postLikeButtonBuilder ?? this.postLikeButtonBuilder,
      postCommentButtonBuilder:
          postCommentButtonBuilder ?? this.postCommentButtonBuilder,
      preActionWidgets: preActionWidgets ?? this.preActionWidgets,
      postActionWidgets: postActionWidgets ?? this.postActionWidgets,
      style: style ?? this.style,
    );
  }

  @override
  State<LMFeedVerticalVideoPost> createState() =>
      _LMFeedVerticalVideoPostState();
}

class _LMFeedVerticalVideoPostState extends State<LMFeedVerticalVideoPost> {
  final _postBloc = LMFeedPostBloc.instance;
  final _theme = LMFeedCore.theme;
  late final _inStyle = widget.style ?? LMFeedVerticalVideoPostStyle.basic();
  final bool _isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  // Get the post title in first letter capital singular form
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the post title in all small singular form
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  LMAttachmentViewData? _getFirstReelAttachment(LMPostViewData post) {
    return post.attachments?.firstWhereOrNull(
      (attachment) {
        return attachment.attachmentType == LMMediaType.reel &&
            (attachment.attachmentMeta.url != null ||
                attachment.attachmentMeta.path != null);
      },
    );
  }

  final _currentUser = LMFeedLocalPreference.instance.fetchUserData();
  final _screenBuilder = LMFeedCore.config.videoFeedScreenConfig.builder;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final attachment = _getFirstReelAttachment(widget.postViewData);
    return Stack(
      alignment: _inStyle.alignment ?? Alignment.bottomLeft,
      children: [
        Container(
          height: _inStyle.height,
          width: _inStyle.width,
          decoration: _inStyle.decoration,
          padding: _inStyle.padding,
          margin: _inStyle.margin,
          child: Center(
            child: attachment != null
                ? widget.videoBuilder?.call(
                      _defVideoView(attachment),
                    ) ??
                    _defVideoView(attachment)
                : SizedBox(),
          ),
        ),
        // user view
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width - 68,
                  maxHeight: size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.postHeaderBuilder?.call(
                            context,
                            _defPostHeader(widget.postViewData),
                            widget.postViewData,
                          ) ??
                          _defPostHeader(widget.postViewData),
                      widget.postTopicBuilder?.call(
                            context,
                            _defTopicView(),
                            widget.postViewData,
                          ) ??
                          _defTopicView(),
                      widget.postContentBuilder?.call(
                            context,
                            _defPostContent(widget.postViewData),
                            widget.postViewData,
                          ) ??
                          _defPostContent(widget.postViewData),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...widget.preActionWidgets,
                    BlocBuilder<LMFeedPostBloc, LMFeedPostState>(
                      bloc: _postBloc,
                      builder: (context, state) {
                        return widget.postLikeButtonBuilder?.call(
                              _defLikeButton(widget.postViewData),
                            ) ??
                            _defLikeButton(widget.postViewData);
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    widget.postCommentButtonBuilder?.call(
                          _defCommentButton(widget.postViewData),
                        ) ??
                        _defCommentButton(widget.postViewData),
                    SizedBox(
                      height: 16,
                    ),
                    widget.postMenuBuilder?.call(
                          context,
                          _defMenu(context, widget.postViewData),
                          widget.postViewData,
                        ) ??
                        _defMenu(context, widget.postViewData),
                    ...widget.postActionWidgets,
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  LMFeedPostContent _defPostContent(LMPostViewData item) {
    return LMFeedPostContent(
      text: item.text,
      style: LMFeedPostContentStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        headingSeparator: const SizedBox(height: 0.0),
        visibleLines: 2,
        headingStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        expandTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(
          context,
          postViewData,
          LMFeedAnalyticsKeys.postProfileName,
          widget.widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(
          context,
          postViewData,
          LMFeedAnalyticsKeys.postProfilePicture,
          widget.widgetSource),
      createdAtBuilder: (context, text) {
        return text.copyWith(
            style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ));
      },
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: LMFeedPostHeaderStyle.basic().copyWith(
        showMenu: false,
        imageSize: 36,
        titleTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        subTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LMFeedMenu _defMenu(BuildContext context, LMPostViewData postViewData) {
    return LMFeedMenu(
      menuItems: postViewData.menuItems,
      style: LMFeedMenuStyle(
          menuType: LMFeedPostMenuType.bottomSheet,
          showBottomSheetTitle: false,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          menuIcon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Icons.more_horiz,
            style: LMFeedIconStyle(
              size: 32,
              color: _theme.container,
            ),
          ),
          menuTitleStyle: (menuId, titleStyle) {
            return titleStyle?.copyWith(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: menuId == LMFeedMenuAction.postDeleteId ||
                        menuId == LMFeedMenuAction.postReportId
                    ? _theme.errorColor
                    : _theme.onContainer,
              ),
            );
          }),
      removeItemIds: {},
      onMenuOpen: () {
        LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
          eventName: LMFeedAnalyticsKeys.postMenu,
          eventProperties: {
            'uuid': postViewData.user.sdkClientInfo.uuid,
            'post_id': postViewData.id,
            'topics': postViewData.topics.map((e) => e.name).toList(),
            'post_type': LMFeedPostUtils.getPostType(postViewData.attachments),
          },
        ));
      },
      action: LMFeedMenuAction(
        onPostEdit: () => _onPostEdit(postViewData),
        onPostReport: () => LMFeedDefaultWidgets.instance
            .handlePostReportAction(postViewData, context),
        onPostUnpin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
        onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
        onPostDelete: () => _onPostDelete(postViewData),
      ),
      menuItemBuilderForBottomSheet: (context, menuItem, menuData) {
        return menuItem.copyWith(
          leading: _getMenuIcon(menuData),
        );
      },
    );
  }

  LMFeedIcon? _getMenuIcon(LMPopUpMenuItemViewData menuData) {
    IconData? iconData;
    Color iconColor = _theme.onContainer;
    switch (menuData.id) {
      case LMFeedMenuAction.postEditId:
        iconData = Icons.edit_outlined;
        break;
      case LMFeedMenuAction.postDeleteId:
        iconData = Icons.delete_outline;
        iconColor = _theme.errorColor;
        break;
      case LMFeedMenuAction.postReportId:
        iconData = Icons.report_outlined;
        iconColor = _theme.errorColor;
        break;
    }
    return iconData != null
        ? LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: iconData,
            style: LMFeedIconStyle(
              size: 24,
              color: iconColor,
            ),
          )
        : null;
  }

  void _onPostDelete(LMPostViewData postViewData) {
    String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;
    showDialog(
      context: context,
      builder: (childContext) => LMFeedDeleteConfirmationDialog(
        title: 'Delete $postTitleFirstCap?',
        uuid: postCreatorUUID,
        widgetSource: widget.widgetSource,
        content:
            'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
        action: (String reason) async {
          Navigator.of(childContext).pop();

          String postType =
              LMFeedPostUtils.getPostType(postViewData.attachments);

          LMFeedPostBloc.instance.add(
            LMFeedDeletePostEvent(
              postId: postViewData.id,
              reason: reason,
              isRepost: postViewData.isRepost,
              postType: postType,
              userId: postCreatorUUID,
              userState: _isCm ? "CM" : "member",
            ),
          );
        },
        actionText: 'Delete',
      ),
    );
  }

  void _onPostEdit(LMPostViewData postViewData) {
    // Mute all video controllers
    // to prevent video from playing in background
    // while editing the post
    LMFeedVideoProvider.instance.forcePauseAllControllers();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedEditShortVideoScreen(
          postId: postViewData.id,
        ),
      ),
    );
  }

  LMFeedPostTopic _defTopicView() {
    return LMFeedPostTopic(
      topics: widget.postViewData.topics,
      post: widget.postViewData,
      style: LMFeedPostTopicStyle.basic().copyWith(
        maxTopicsToShow: 3,
      ),
      onMoreTopicsTap: (context, topics) {
        showModalBottomSheet(
          showDragHandle: true,
          context: context,
          builder: (context) {
            return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Column(
                  children: [
                    LMFeedText(
                      text: "Topics",
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(topics[index].name),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  LMFeedVideo _defVideoView(LMAttachmentViewData attachment) {
    return LMFeedVideo(
      postId: widget.postViewData.id,
      video: attachment,
      autoPlay: true,
      style: LMFeedPostVideoStyle.basic().copyWith(
        allowMuting: false,
      ),
    );
  }

  LMFeedButton _defLikeButton(LMPostViewData postViewData) {
    return LMFeedButton(
      text: LMFeedText(
        text: postViewData.likeCount.toString(),
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      isActive: postViewData.isLiked,
      onTap: () async {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        // add analytics event
        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: postViewData.isLiked
                ? LMFeedAnalyticsKeys.reelUnliked
                : LMFeedAnalyticsKeys.reelLiked,
            widgetSource: LMFeedWidgetSource.videoFeed,
            eventProperties: {
              'uuid': _currentUser?.uuid,
              'reel_id': postViewData.id,
            },
          ),
        );
        _postBloc.add(LMFeedUpdatePostEvent(
          actionType: postViewData.isLiked
              ? LMFeedPostActionType.unlike
              : LMFeedPostActionType.like,
          postId: postViewData.id,
        ));

        final likePostRequest =
            (LikePostRequestBuilder()..postId(postViewData.id)).build();

        final LikePostResponse response =
            await LMFeedCore.client.likePost(likePostRequest);

        if (!response.success) {
          _postBloc.add(LMFeedUpdatePostEvent(
            actionType: postViewData.isLiked
                ? LMFeedPostActionType.unlike
                : LMFeedPostActionType.like,
            postId: postViewData.id,
          ));
        } else {
          LMFeedPostUtils.handlePostLikeTapEvent(
              postViewData, widget.widgetSource, postViewData.isLiked);
        }
      },
      onTextTap: () {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return _screenBuilder.likeListBottomSheetBuilder.call(
              context,
              _defLikeBottomSheet(context, postViewData),
              widget.postViewData.id,
            );
          },
        );
      },
      style: LMFeedButtonStyle(
        direction: Axis.vertical,
        gap: 0,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeInActiveSvg,
          style: LMFeedIconStyle(
            size: 32,
            fit: BoxFit.contain,
            color: _theme.container,
          ),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeActiveSvg,
          style: LMFeedIconStyle(
            size: 32,
            fit: BoxFit.contain,
          ),
        ),
        borderRadius: 100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(
              0.1,
            ),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  LMFeedLikeListBottomSheet _defLikeBottomSheet(
      BuildContext context, LMPostViewData postViewData) {
    return LMFeedLikeListBottomSheet(
      postViewData: postViewData,
      widgetSource: widget.widgetSource,
      style: LMFeedLikeListBottomSheetStyle(
        enableDrag: true,
        showDragHandle: true,
      ),
    );
  }

  LMFeedButton _defCommentButton(LMPostViewData postViewData) {
    final LMFeedButton commentButton = LMFeedButton(
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      text: LMFeedText(
        text: postViewData.commentCount.toString(),
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      style: LMFeedButtonStyle(
        direction: Axis.vertical,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmCommentSvg,
          style: LMFeedIconStyle(
            size: 32,
            color: _theme.container,
          ),
        ),
        borderRadius: 100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(
              0.1,
            ),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      onTap: () async {
        LMFeedPostUtils.handlePostCommentButtonTap(
            postViewData, widget.widgetSource);

        LMFeedVideoProvider.instance.pauseCurrentVideo();

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return _screenBuilder.commentBottomSheetBuilder.call(
              context,
              _defCommentBottomSheet(postViewData),
              widget.postViewData.id,
            );
          },
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );

    return commentButton;
  }

  LMFeedCommentBottomSheet _defCommentBottomSheet(LMPostViewData postViewData) {
    return LMFeedCommentBottomSheet(
      postId: postViewData.id,
      style: LMFeedCommentBottomSheetStyle(
        showDragHandle: true,
        enableDrag: true,
      ),
    );
  }
}

class LMFeedVerticalVideoPostStyle {
  final Alignment? alignment;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  LMFeedVerticalVideoPostStyle({
    this.alignment,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.decoration,
  });

  /// copyWith method for the [LMFeedVerticalVideoPostStyle]
  LMFeedVerticalVideoPostStyle copyWith({
    Alignment? alignment,
    double? height,
    double? width,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  }) {
    return LMFeedVerticalVideoPostStyle(
      alignment: alignment ?? this.alignment,
      height: height ?? this.height,
      width: width ?? this.width,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
    );
  }

  /// basic style for the vertical video post
  factory LMFeedVerticalVideoPostStyle.basic() {
    return LMFeedVerticalVideoPostStyle(
      alignment: Alignment.bottomLeft,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.black),
    );
  }
}
