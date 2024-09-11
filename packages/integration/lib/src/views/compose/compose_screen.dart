// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:math';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:url_launcher/url_launcher.dart';

class LMFeedComposeScreen extends StatefulWidget {
  const LMFeedComposeScreen({
    super.key,
    // Widget builder functions for customizations
    this.composeDiscardDialogBuilder,
    this.composeAppBarBuilder,
    this.composeContentBuilder,
    this.composeTopicSelectorBuilder,
    this.composeMediaPreviewBuilder,
    this.composeUserHeaderBuilder,
    // Config for the screen
    this.config,
    this.style,
    this.attachments,
    this.displayName,
    this.displayUrl,
    this.feedroomId,
    this.widgetSource,
  });

  final LMFeedComposeScreenConfig? config;

  final LMFeedWidgetSource? widgetSource;

  final LMFeedComposeScreenStyle? style;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final PreferredSizeWidget Function(
    LMFeedAppBar oldAppBar,
    // Precheck validation for text, heading and attachments
    LMResponse<void> Function() onPostCreate,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  )? composeAppBarBuilder;
  final Widget Function()? composeContentBuilder;
  final Widget Function(
          BuildContext context, Widget topicSelector, List<LMTopicViewData>)?
      composeTopicSelectorBuilder;
  final Widget Function()? composeMediaPreviewBuilder;
  final Widget Function(BuildContext context, LMUserViewData user)?
      composeUserHeaderBuilder;
  final List<LMAttachmentViewData>? attachments;
  final String? displayName;
  final String? displayUrl;
  final int? feedroomId;

  @override
  State<LMFeedComposeScreen> createState() => _LMFeedComposeScreenState();
}

class _LMFeedComposeScreenState extends State<LMFeedComposeScreen> {
  /// Required blocs and data for basic functionality, or state management
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  final LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  final LMFeedPostBloc bloc = LMFeedPostBloc.instance;
  final LMFeedComposeBloc composeBloc = LMFeedComposeBloc.instance;
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  LMFeedWidgetUtility widgetUtility = LMFeedCore.widgetUtility;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.createPostScreen;
  LMFeedComposeScreenStyle? style;
  LMFeedComposeScreenConfig? config;
  LMPostViewData? repost;

  /// Controllers and other helper classes' objects
  FocusNode? _headingFocusNode;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  TextEditingController? _headingController;
  final CustomPopupMenuController _controllerPopUp =
      CustomPopupMenuController();
  Timer? _debounce;
  String? result;
  Size? screenSize;
  double? screenWidth;
  // bool to check if the user has tapped on the cancel icon
  // of link preview, in that case toggle the bool to true
  // and don't generate link preview any further
  bool linkCancelled = false;

  /// Value notifiers to rebuild small widgets throughout the screen
  /// Rather than handling state management from complex classes
  ValueNotifier<bool> rebuildLinkPreview = ValueNotifier(false);
  ValueNotifier<bool> rebuildTopicFloatingButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
          widgetSource: widget.widgetSource,
          eventName: LMFeedAnalyticsKeys.postCreationStarted,
          eventProperties: {}),
    );
    style = widget.style ?? feedTheme.composeScreenStyle;
    _checkForRepost();
    config = widget.config ?? LMFeedCore.config.composeConfig;
    _headingController =
        (config?.enableHeading ?? false) ? TextEditingController() : null;
    composeBloc.add(LMFeedComposeFetchTopicsEvent());
    if (_headingController != null) {
      _headingFocusNode = FocusNode();
      _headingFocusNode?.requestFocus();
    } else if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(LMFeedComposeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForRepost();
    style = widget.style ?? feedTheme.composeScreenStyle;
    _checkForRepost();
    config = widget.config ?? LMFeedCore.config.composeConfig;
    _headingController =
        (config?.enableHeading ?? false) ? TextEditingController() : null;
    composeBloc.add(LMFeedComposeFetchTopicsEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (composeBloc.videoCount > 0) {
      LMFeedVideoProvider.instance.clearPostController(
          composeBloc.postMedia.first.attachmentMeta.path?.toString() ?? '');
    }
    composeBloc.add(LMFeedComposeCloseEvent());
    super.dispose();
  }

  void _checkForRepost() {
    if (widget.attachments != null) {
      for (LMAttachmentViewData attachment in widget.attachments!) {
        if (attachment.attachmentType == LMMediaType.repost) {
          repost = attachment.attachmentMeta.repost;
          composeBloc.postMedia.add(
            LMAttachmentViewData.fromAttachmentMeta(
              attachmentType: LMMediaType.repost,
              attachmentMeta: (LMAttachmentMetaViewDataBuilder()
                    ..post(repost)
                    ..postId(repost?.id))
                  .build(),
            ),
          );
          return;
        }
      }
    }
  }

  /// Bloc listener for the compose bloc
  /// Handles all the events and states emitted by the compose bloc
  _composeBlocListener(BuildContext context, LMFeedComposeState state) {
    if (state is LMFeedComposeMediaErrorState) {
      LMFeedCore.showSnackBar(
        context,
        state.error ?? 'Error while selecting media, please try again',
        widgetSource,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    screenWidth = min(LMFeedCore.webConfiguration.maxWidth, screenSize!.width);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: config!.composeSystemOverlayStyle,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
          bloc: composeBloc,
          listener: _composeBlocListener,
          child: widgetUtility.scaffold(
            source: LMFeedWidgetSource.createPostScreen,
            backgroundColor: feedTheme.container,
            bottomSheet: _defMediaPicker(),
            appBar: widget.composeAppBarBuilder?.call(
                    _defAppBar(),
                    onPostCreate,
                    _defPostCreateButton(),
                    _defCancelButton(),
                    onPostValidationFailed) ??
                widgetUtility.composeScreenAppBar(context, _defAppBar()),
            canPop: false,
            onPopInvoked: (canPop) {
              widget.composeDiscardDialogBuilder?.call(context) ??
                  _showDefaultDiscardDialog(context);
            },
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 16.0),
              child: BlocBuilder<LMFeedComposeBloc, LMFeedComposeState>(
                bloc: composeBloc,
                buildWhen: (previous, current) {
                  if (current is LMFeedComposeFetchedTopicsState) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) {
                  if (state is LMFeedComposeFetchedTopicsState) {
                    if (state.topics.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return widget.composeTopicSelectorBuilder?.call(
                            context,
                            _defTopicSelector(state.topics),
                            composeBloc.selectedTopics) ??
                        LMFeedCore.widgetUtility
                            .composeScreenTopicSelectorBuilder(
                                context,
                                _defTopicSelector(state.topics),
                                composeBloc.selectedTopics);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            body: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: screenWidth,
                  margin: EdgeInsets.only(
                    bottom: 100,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        widget.composeUserHeaderBuilder?.call(context, user!) ??
                            widgetUtility.composeScreenUserHeaderBuilder(
                                context, user!),
                        const SizedBox(height: 18),
                        widget.composeContentBuilder?.call() ??
                            _defContentInput(),
                        const SizedBox(height: 18),
                        widget.composeMediaPreviewBuilder?.call() ??
                            _defMediaPreview(),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDefaultDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DefaultTextStyle(
        style: const TextStyle(),
        child: AlertDialog(
          backgroundColor: feedTheme.container,
          surfaceTintColor: Colors.transparent,
          title: Text('Discard $postTitleFirstCap'),
          content: Text(
              'Are you sure you want to discard the current $postTitleSmallCap?'),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.all(8),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LMFeedButton(
                  text: LMFeedText(
                    text: "No",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: LMFeedCore.theme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: const LMFeedButtonStyle(height: 42),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                LikeMindsTheme.kHorizontalPaddingXLarge,
                LMFeedButton(
                  text: LMFeedText(
                    text: "Yes",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: LMFeedCore.theme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: const LMFeedButtonStyle(height: 42),
                  onTap: () {
                    LMFeedComposeBloc.instance.add(LMFeedComposeCloseEvent());

                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                ),
                LikeMindsTheme.kHorizontalPaddingLarge,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defMediaPreview() {
    return BlocBuilder<LMFeedComposeBloc, LMFeedComposeState>(
      bloc: composeBloc,
      builder: (context, state) {
        if (state is LMFeedComposeMediaLoadingState) {
          return const LMFeedLoader();
        }
        if (composeBloc.postMedia.isNotEmpty) {
          if (composeBloc.isPollAdded) {
            return LMFeedPoll(
              style: feedTheme.composeScreenStyle.mediaStyle?.pollStyle
                      ?.copyWith() ??
                  LMFeedPollStyle.basic(isComposable: true).copyWith(
                    backgroundColor: feedTheme.container,
                  ),
              attachmentMeta: composeBloc.postMedia.first.attachmentMeta,
              subTextBuilder: (context) {
                return LMFeedText(
                  text: getFormattedDateTime(
                      composeBloc.postMedia.first.attachmentMeta.expiryTime),
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: feedTheme.onContainer.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
              onCancel: () {
                composeBloc.add(LMFeedComposeCloseEvent());
              },
              onEdit: (attachmentMeta) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LMFeedCreatePollScreen(
                      attachmentMeta: attachmentMeta,
                    ),
                  ),
                );
              },
            );
          }
          if (composeBloc.postMedia.first.attachmentType ==
              LMMediaType.repost) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: screenWidth,
                    decoration: const BoxDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LMFeedPostWidget(
                        post: repost!,
                        user: repost!.user,
                        isFeed: false,
                        topics: repost?.topics ?? [],
                        footerBuilder: (context, footer, footerData) =>
                            const SizedBox.shrink(),
                        headerBuilder: (context, header, headerData) {
                          return header.copyWith(menuBuilder: (_) {
                            return const SizedBox.shrink();
                          });
                        },
                        style: LMFeedPostStyle.basic().copyWith(
                            borderRadius: BorderRadius.circular(8),
                            padding: const EdgeInsets.all(8),
                            border: Border.all(
                              color:
                                  LMFeedCore.theme.onContainer.withOpacity(0.1),
                            )),
                        onPostTap: (context, postData) {
                          debugPrint('Post tapped');
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        composeBloc.add(
                          const LMFeedComposeRemoveAttachmentEvent(
                            index: 0,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(500),
                        ),
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.cancel,
                          color: feedTheme.disabledColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            padding: style?.mediaPadding ?? EdgeInsets.zero,
            width: screenWidth,
            height: LMFeedComposeBloc.instance.documentCount > 0
                ? null
                : screenWidth,
            child: ListView.builder(
              scrollDirection: LMFeedComposeBloc.instance.documentCount > 0
                  ? Axis.vertical
                  : Axis.horizontal,
              physics: LMFeedComposeBloc.instance.documentCount > 0
                  ? const NeverScrollableScrollPhysics()
                  : null,
              shrinkWrap: true,
              itemCount: composeBloc.postMedia.length,
              itemBuilder: (context, index) {
                Widget mediaWidget;
                switch (composeBloc.postMedia[index].attachmentType) {
                  case LMMediaType.image:
                    mediaWidget = Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: style?.mediaStyle?.imageStyle?.backgroundColor,
                        borderRadius:
                            style?.mediaStyle?.imageStyle?.borderRadius,
                      ),
                      height:
                          style?.mediaStyle?.imageStyle?.height ?? screenWidth,
                      width:
                          style?.mediaStyle?.imageStyle?.width ?? screenWidth,
                      alignment: Alignment.center,
                      child: LMFeedImage(
                        image: composeBloc.postMedia[index],
                        style: style?.mediaStyle?.imageStyle,
                        position: index,
                      ),
                    );
                    break;
                  case LMMediaType.video:
                    mediaWidget = Container(
                      clipBehavior: Clip.hardEdge,
                      height:
                          style?.mediaStyle?.videoStyle?.height ?? screenWidth,
                      width:
                          style?.mediaStyle?.videoStyle?.width ?? screenWidth,
                      decoration: BoxDecoration(
                        color: style?.mediaStyle?.imageStyle?.backgroundColor,
                        borderRadius:
                            style?.mediaStyle?.videoStyle?.borderRadius,
                      ),
                      alignment: Alignment.center,
                      child: LMFeedVideo(
                        video: composeBloc.postMedia[index],
                        style: style?.mediaStyle?.videoStyle,
                        postId:
                            "${composeBloc.postMedia[index].attachmentMeta.path.toString()}$index",
                      ),
                    );
                    break;
                  case LMMediaType.link:
                    mediaWidget = LMFeedLinkPreview(
                      attachment: composeBloc.postMedia[index],
                      style: style?.mediaStyle?.linkStyle?.copyWith(
                            width: style?.mediaStyle?.linkStyle?.width ??
                                screenWidth! - 84,
                          ) ??
                          LMFeedPostLinkPreviewStyle(
                            height: 215,
                            width: screenWidth! - 84,
                            imageHeight: 138,
                            backgroundColor: LikeMindsTheme.backgroundColor,
                            border: Border.all(
                              color: LikeMindsTheme.secondaryColor,
                            ),
                          ),
                      onTap: () {
                        launchUrl(
                          Uri.parse(composeBloc.postMedia[index].attachmentMeta
                                  .ogTags?.url ??
                              ''),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      title: LMFeedText(
                        text: composeBloc.postMedia[index].attachmentMeta.ogTags
                                ?.title ??
                            "--",
                        style: const LMFeedTextStyle(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: LikeMindsTheme.blackColor,
                            height: 1.30,
                          ),
                        ),
                      ),
                      subtitle: LMFeedText(
                        text: composeBloc.postMedia[index].attachmentMeta.ogTags
                                ?.description ??
                            "--",
                        style: const LMFeedTextStyle(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            color: LikeMindsTheme.blackColor,
                            fontWeight: FontWeight.w400,
                            height: 1.30,
                          ),
                        ),
                      ),
                    );
                    break;
                  case LMMediaType.document:
                    {
                      mediaWidget = LMFeedDocument(
                        onRemove: () {
                          composeBloc.add(
                            LMFeedComposeRemoveAttachmentEvent(
                              index: index,
                            ),
                          );
                        },
                        document: composeBloc.postMedia[index],
                        style: style?.mediaStyle?.documentStyle?.copyWith(
                              width: style?.mediaStyle?.documentStyle?.width ??
                                  screenWidth,
                            ) ??
                            LMFeedPostDocumentStyle(
                              width: screenWidth,
                              height: 90,
                            ),
                        size: PostHelper.getFileSizeString(
                            bytes: composeBloc
                                    .postMedia[index].attachmentMeta.size ??
                                0),
                      );
                      break;
                    }
                  default:
                    mediaWidget = const SizedBox();
                }
                return Padding(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      mediaWidget,
                      if (composeBloc.postMedia[index].attachmentType !=
                          LMMediaType.document)
                        Positioned(
                          top: 7.5,
                          right: composeBloc.postMedia.first.attachmentType ==
                                  LMMediaType.link
                              ? 20.0
                              : 7.5,
                          child: GestureDetector(
                            onTap: () {
                              LMAttachmentViewData removedMedia =
                                  composeBloc.postMedia[index];
                              if (removedMedia.attachmentType ==
                                  LMMediaType.link) {
                                linkCancelled = true;
                              } else if (removedMedia.attachmentType ==
                                  LMMediaType.video) {
                                LMFeedVideoProvider.instance.clearPostController(
                                    "${removedMedia.attachmentMeta.path}$index");
                              }

                              composeBloc.add(
                                LMFeedComposeRemoveAttachmentEvent(
                                  index: index,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(500),
                              ),
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.cancel,
                                color: feedTheme.disabledColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  LMFeedButton _defCancelButton() {
    return LMFeedButton(
      text: LMFeedText(
        text: "Cancel",
        style: LMFeedTextStyle(
          textStyle: TextStyle(color: feedTheme.primaryColor),
        ),
      ),
      onTap: () {
        widget.composeDiscardDialogBuilder?.call(context) ??
            _showDefaultDiscardDialog(context);
      },
      style: const LMFeedButtonStyle(),
    );
  }

  LMFeedButton _defPostCreateButton() {
    return LMFeedButton(
      text: LMFeedText(
        text: "Create",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: feedTheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      style: LMFeedButtonStyle(
        backgroundColor: feedTheme.primaryColor,
        borderRadius: 6,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      onTap: () {
        LMResponse response = onPostCreate.call();

        if (response.success) {
          onPostValidationSuccess();
        } else {
          onPostValidationFailed(
              response.errorMessage ?? "An error occurred, please try again");
        }
      },
    );
  }

  void onPostValidationSuccess() {
    Navigator.pop(context);
  }

  void onPostValidationFailed(String errorMessage) {
    LMFeedCore.showSnackBar(
      context,
      errorMessage,
      widgetSource,
    );
  }

  LMFeedAppBar _defAppBar() {
    final theme = LMFeedCore.theme;
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 48,
        centerTitle: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 8.0,
        ),
        shadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 1.0,
            offset: const Offset(0.0, 1.0), // shadow direction: bottom right
          ),
        ],
      ),
      leading: _defCancelButton(),
      title: LMFeedText(
        text: "Create $postTitleFirstCap",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.onContainer,
          ),
        ),
      ),
      trailing: [
        _defPostCreateButton(),
      ],
    );
  }

  LMResponse<void> onPostCreate() {
    _focusNode.unfocus();

    String? heading = _headingController?.text;
    heading = heading?.trim();

    String postText = _controller.text;
    postText = postText.trim();
    if ((heading?.isNotEmpty ?? false) ||
        postText.isNotEmpty ||
        composeBloc.postMedia.isNotEmpty) {
      List<LMUserTagViewData> userTags = [...composeBloc.userTags];
      List<LMTopicViewData> selectedTopics = [...composeBloc.selectedTopics];

      if (config!.enableHeading &&
          config!.headingRequiredToCreatePost &&
          (heading == null || heading.isEmpty)) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without heading",
        );
      }

      if (config!.textRequiredToCreatePost && postText.isEmpty) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without text",
        );
      }

      if (config!.topicRequiredToCreatePost &&
          selectedTopics.isEmpty &&
          config!.enableTopics) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without topic",
        );
      }
      userTags = LMFeedTaggingHelper.matchTags(_controller.text, userTags);

      result =
          LMFeedTaggingHelper.encodeString(_controller.text, userTags).trim();

      if (widget.attachments != null &&
          widget.attachments!.isNotEmpty &&
          widget.attachments!.first.attachmentType == LMMediaType.widget) {
        composeBloc.postMedia.add(
          LMAttachmentViewData.fromAttachmentMeta(
            attachmentType: LMMediaType.widget,
            attachmentMeta: (LMAttachmentMetaViewDataBuilder()
                  ..meta(widget.attachments?.first.attachmentMeta.meta ?? {}))
                .build(),
          ),
        );
      }
      LMFeedPostBloc.instance.add(LMFeedCreateNewPostEvent(
        user: user!,
        postText: result!,
        selectedTopics: selectedTopics,
        postMedia: [...composeBloc.postMedia],
        heading: _headingController?.text,
        feedroomId: widget.feedroomId,
        userTagged: userTags,
      ));

      return LMResponse(success: true);
    } else {
      return LMResponse(
        success: false,
        errorMessage:
            "Can't create a $postTitleSmallCap without text or attachments",
      );
    }
  }

  Widget _defContentInput() {
    final theme = LMFeedCore.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Column(
        children: [
          (config?.enableHeading ?? false)
              ? LMFeedCore.widgetUtility.composeScreenHeadingTextfieldBuilder(
                  context,
                  _defHeadingTextfield(theme),
                )
              : const SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !(config?.enableHeading ?? false)
                  ? Container(
                      padding: const EdgeInsets.only(top: 4.0),
                      margin: const EdgeInsets.only(right: 12),
                      child: LMFeedProfilePicture(
                        fallbackText: widget.displayName ?? user!.name,
                        imageUrl: widget.displayUrl ?? user!.imageUrl,
                        style: LMFeedProfilePictureStyle(
                          backgroundColor: theme.primaryColor,
                          size: 36,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              Column(
                children: [
                  Container(
                      width: screenWidth! - 82,
                      decoration: BoxDecoration(
                        color: theme.container,
                      ),
                      child: LMFeedCore.widgetUtility
                          .composeScreenContentTextfieldBuilder(
                        context,
                        _defContentTextField(),
                      )),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  LMTaggingAheadTextField _defContentTextField() {
    return LMTaggingAheadTextField(
      isDown: true,
      minLines: 3,
      enabled: config!.enableTagging,
      // maxLines: 200,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: config?.composeHint,
        hintStyle: TextStyle(
          overflow: TextOverflow.visible,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: feedTheme.onContainer.withOpacity(0.5),
        ),
      ),
      onTagSelected: (tag) {
        composeBloc.userTags.add(tag);
        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.userTaggedInPost,
            widgetSource: LMFeedWidgetSource.createPostScreen,
            eventProperties: {
              'tagged_user_id': tag.sdkClientInfo?.uuid ?? tag.uuid,
              'tagged_user_count': composeBloc.userTags.length.toString(),
            },
          ),
        );
      },
      controller: _controller,
      focusNode: _focusNode,
      onChange: _onTextChanged,
    );
  }

  TextField _defHeadingTextfield(LMFeedThemeData theme) {
    return TextField(
      focusNode: _headingFocusNode,
      controller: _headingController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: config?.headingHint,
        hintStyle: TextStyle(
          color: theme.onContainer.withOpacity(0.5),
          overflow: TextOverflow.visible,
        ),
      ),
      cursorColor: theme.primaryColor,
      style: TextStyle(
        color: theme.onContainer,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _onTextChanged(String p0) {
    if (!config!.enableLinkPreviews) {
      return;
    }
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!linkCancelled) handleTextLinks(p0);
    });
  }

  /*
  * Takes a string as input
  * extracts the first valid link from the string
  * decodes the url using LikeMinds SDK
  * and generates a preview for the link
  */
  void handleTextLinks(String text) async {
    composeBloc.add(LMFeedComposeAddLinkPreviewEvent(url: text));
  }

  Widget _defMediaPicker() {
    final theme = LMFeedCore.theme;
    return BlocConsumer(
      bloc: composeBloc,
      listener: (context, state) {
        if (state is LMFeedComposeAddedDocumentState ||
            state is LMFeedComposeAddedImageState ||
            state is LMFeedComposeAddedVideoState ||
            state is LMFeedComposeAddedPollState ||
            state is LMFeedComposeRemovedAttachmentState ||
            state is LMFeedComposeInitialState) {
          rebuildTopicFloatingButton.value = !rebuildTopicFloatingButton.value;
        }
      },
      builder: (context, state) {
        if (composeBloc.isPollAdded) {
          return const SizedBox();
        }
        if (composeBloc.postMedia.length == 10) {
          return const SizedBox();
        }
        if (composeBloc.postMedia.isNotEmpty &&
            composeBloc.postMedia.first.attachmentType == LMMediaType.repost) {
          return const SizedBox();
        }
        return Container(
          decoration: BoxDecoration(
            color: theme.container,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(0.0, -1.0),
                blurRadius: 1.0,
              ), //BoxShadow
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          height: 72,
          child: Row(
            children: [
              if (composeBloc.documentCount == 0 && config!.enableImages)
                LMFeedButton(
                  isActive: false,
                  style: LMFeedButtonStyle(
                    placement: LMFeedIconButtonPlacement.start,
                    showText: false,
                    icon: style?.addImageIcon ??
                        LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: Icons.photo_outlined,
                          style: LMFeedIconStyle(
                            color: theme.primaryColor,
                            size: 32,
                            boxPadding: 0,
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                  onTap: () async {
                    composeBloc.add(LMFeedComposeAddImageEvent());
                  },
                ),
              if (composeBloc.documentCount == 0 && config!.enableVideos)
                LMFeedButton(
                  isActive: false,
                  style: LMFeedButtonStyle(
                    placement: LMFeedIconButtonPlacement.start,
                    showText: false,
                    icon: style?.addVideoIcon ??
                        LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: Icons.videocam_outlined,
                          style: LMFeedIconStyle(
                            color: theme.primaryColor,
                            size: 32,
                            boxPadding: 0,
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                  onTap: () async {
                    composeBloc.add(LMFeedComposeAddVideoEvent());
                  },
                ),
              if (composeBloc.videoCount == 0 &&
                  composeBloc.imageCount == 0 &&
                  config!.enableDocuments)
                LMFeedButton(
                  isActive: false,
                  style: LMFeedButtonStyle(
                    placement: LMFeedIconButtonPlacement.start,
                    showText: false,
                    icon: style?.addDocumentIcon ??
                        LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: Icons.file_open_outlined,
                          style: LMFeedIconStyle(
                            color: theme.primaryColor,
                            size: 32,
                            boxPadding: 0,
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                  onTap: () async {
                    composeBloc.add(LMFeedComposeAddDocumentEvent());
                  },
                ),
              if (config!.enablePolls &&
                  composeBloc.videoCount == 0 &&
                  composeBloc.imageCount == 0 &&
                  composeBloc.documentCount == 0)
                LMFeedButton(
                  isActive: false,
                  style: LMFeedButtonStyle(
                    placement: LMFeedIconButtonPlacement.start,
                    showText: false,
                    icon: style?.addPollIcon ??
                        LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: Icons.poll_outlined,
                          style: LMFeedIconStyle(
                            color: theme.primaryColor,
                            size: 32,
                            boxPadding: 0,
                            fit: BoxFit.contain,
                          ),
                        ),
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LMFeedCreatePollScreen(),
                      ),
                    );
                  },
                ),
              Spacer(),
              composeBloc.postMedia.length > 0 && config!.showMediaCount
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: LMFeedText(
                        text: "${composeBloc.postMedia.length}/10",
                        style: LMFeedTextStyle.basic(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _defTopicSelector(List<LMTopicViewData> topics) {
    if (!config!.enableTopics) {
      return const SizedBox.shrink();
    }

    if (topics.isEmpty) {
      return const SizedBox();
    }

    return ValueListenableBuilder(
        valueListenable: rebuildTopicFloatingButton,
        builder: (context, _, __) {
          return Container(
            height: 40,
            margin: EdgeInsets.only(
              bottom:
                  composeBloc.postMedia.length == 10 || composeBloc.isPollAdded
                      ? 0
                      : 25,
            ),
            child: Row(children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () async {
                    if (_focusNode.hasFocus) {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      currentFocus.unfocus();
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                    _controllerPopUp.showMenu();
                  },
                  child: AbsorbPointer(
                    child: CustomPopupMenu(
                      controller: _controllerPopUp,
                      showArrow: false,
                      horizontalMargin: 16.0,
                      pressType: PressType.singleClick,
                      menuBuilder: () => LMFeedTopicList(
                        selectedTopics: composeBloc.selectedTopics,
                        isEnabled: true,
                        onTopicSelected: (updatedTopics, tappedTopic) {
                          if (config!.multipleTopicsSelectable) {
                            int index = composeBloc.selectedTopics.indexWhere(
                                (element) => element.id == tappedTopic.id);
                            if (index == -1) {
                              composeBloc.selectedTopics.add(tappedTopic);
                            } else {
                              composeBloc.selectedTopics.removeAt(index);
                            }
                          } else {
                            composeBloc.selectedTopics.clear();
                            composeBloc.selectedTopics.add(tappedTopic);
                          }

                          if (!config!.multipleTopicsSelectable) {
                            _controllerPopUp.hideMenu();
                          }
                          rebuildTopicFloatingButton.value =
                              !rebuildTopicFloatingButton.value;
                        },
                      ),
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 16.0),
                        child: LMFeedTopicChip(
                          isSelected: false,
                          topic: composeBloc.selectedTopics.isEmpty
                              ? (LMTopicViewDataBuilder()
                                    ..id("0")
                                    ..isEnabled(true)
                                    ..name("Topic"))
                                  .build()
                              : composeBloc.selectedTopics.length == 1
                                  ? composeBloc.selectedTopics.first
                                  : (LMTopicViewDataBuilder()
                                        ..id("0")
                                        ..isEnabled(true)
                                        ..name(
                                            "Topics (${composeBloc.selectedTopics.length})"))
                                      .build(),
                          style: LMFeedTopicChipStyle(
                            textStyle: TextStyle(
                              color: LMFeedCore.theme.primaryColor,
                            ),
                            backgroundColor: feedTheme.container,
                            showBorder: true,
                            borderColor: LMFeedCore.theme.primaryColor,
                            borderRadius: BorderRadius.circular(500),
                            icon: LMFeedIcon(
                              type: LMFeedIconType.icon,
                              icon: CupertinoIcons.chevron_down,
                              style: LMFeedIconStyle(
                                size: 16,
                                boxPadding: 0.0,
                                color: LMFeedCore.theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          );
        });
  }
}
