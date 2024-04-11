// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

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
  });

  final LMFeedComposeScreenConfig? config;

  final LMFeedComposeScreenStyle? style;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final PreferredSizeWidget Function(LMFeedAppBar oldAppBar)?
      composeAppBarBuilder;
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
          composeBloc.postMedia.first.mediaFile?.uri.toString() ?? '');
    }
    composeBloc.add(LMFeedComposeCloseEvent());
    super.dispose();
  }

  void _checkForRepost() {
    if (widget.attachments != null) {
      for (LMAttachmentViewData attachment in widget.attachments!) {
        if (attachment.attachmentType == 8) {
          repost = attachment.attachmentMeta.repost;
          composeBloc.postMedia.add(
            LMMediaModel(
              mediaType: LMMediaType.repost,
              postId: repost?.id,
              post: repost,
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
        LMFeedSnackBar(
          content: LMFeedText(
            text: 'Error while selecting media, please try again',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

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
            appBar:
                widget.composeAppBarBuilder?.call(_defAppBar()) ?? _defAppBar(),
            canPop: false,
            onPopInvoked: (canPop) {
              widget.composeDiscardDialogBuilder?.call(context) ??
                  _showDefaultDiscardDialog(context);
            },
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 42.0, left: 16.0),
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
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 150,
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
    );
  }

  _showDefaultDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DefaultTextStyle(
        style: const TextStyle(),
        child: AlertDialog(
          backgroundColor: feedTheme.container,
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
          if (composeBloc.postMedia.first.mediaType == LMMediaType.repost) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: screenSize?.width,
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
            height: screenSize?.width,
            width: screenSize?.width,
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
                switch (composeBloc.postMedia[index].mediaType) {
                  case LMMediaType.image:
                    mediaWidget = Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: feedTheme.onContainer,
                        borderRadius:
                            style?.mediaStyle?.imageStyle?.borderRadius,
                      ),
                      height: style?.mediaStyle?.imageStyle?.height ??
                          screenSize?.width,
                      width: style?.mediaStyle?.imageStyle?.width ??
                          screenSize?.width,
                      child: LMFeedImage(
                        imageFile: composeBloc.postMedia[index].mediaFile,
                        style: style?.mediaStyle?.imageStyle,
                      ),
                    );
                    break;
                  case LMMediaType.video:
                    mediaWidget = Container(
                      clipBehavior: Clip.hardEdge,
                      height: style?.mediaStyle?.videoStyle?.height ??
                          screenSize?.width,
                      width: style?.mediaStyle?.videoStyle?.width ??
                          screenSize?.width,
                      decoration: BoxDecoration(
                        color: feedTheme.onContainer,
                        borderRadius:
                            style?.mediaStyle?.videoStyle?.borderRadius,
                      ),
                      child: LMFeedVideo(
                        videoFile: composeBloc.postMedia[index].mediaFile,
                        style: style?.mediaStyle?.videoStyle,
                        postId: composeBloc.postMedia[index].mediaFile!.uri
                            .toString(),
                      ),
                    );
                    break;
                  case LMMediaType.link:
                    mediaWidget = LMFeedLinkPreview(
                      linkModel: composeBloc.postMedia[index],
                      style: style?.mediaStyle?.linkStyle?.copyWith(
                            width: style?.mediaStyle?.linkStyle?.width ??
                                MediaQuery.of(context).size.width - 84,
                          ) ??
                          LMFeedPostLinkPreviewStyle(
                            height: 215,
                            width: MediaQuery.of(context).size.width - 84,
                            imageHeight: 138,
                            backgroundColor: LikeMindsTheme.backgroundColor,
                            border: Border.all(
                              color: LikeMindsTheme.secondaryColor,
                            ),
                          ),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                              composeBloc.postMedia[index].ogTags?.url ?? ''),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      title: LMFeedText(
                        text:
                            composeBloc.postMedia[index].ogTags?.title ?? "--",
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
                        text:
                            composeBloc.postMedia[index].ogTags?.description ??
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
                      mediaWidget = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: LMFeedDocument(
                          onRemove: () {
                            composeBloc.add(
                              LMFeedComposeRemoveAttachmentEvent(
                                index: index,
                              ),
                            );
                          },
                          documentFile: composeBloc.postMedia[index].mediaFile,
                          style: style?.mediaStyle?.documentStyle?.copyWith(
                                width:
                                    style?.mediaStyle?.documentStyle?.width ??
                                        MediaQuery.of(context).size.width,
                              ) ??
                              LMFeedPostDocumentStyle(
                                width: screenSize!.width,
                                height: 90,
                              ),
                          size: PostHelper.getFileSizeString(
                              bytes: composeBloc.postMedia[index].size ?? 0),
                        ),
                      );
                      break;
                    }
                  default:
                    mediaWidget = const SizedBox();
                }
                return Padding(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: <Widget>[
                      mediaWidget,
                      if (composeBloc.postMedia[index].mediaType !=
                          LMMediaType.document)
                        Positioned(
                          top: 7.5,
                          right: 7.5,
                          child: GestureDetector(
                            onTap: () {
                              if (composeBloc.postMedia[index].mediaType ==
                                  LMMediaType.link) {
                                linkCancelled = true;
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
        leading: LMFeedButton(
          text: LMFeedText(
            text: "Cancel",
            style: LMFeedTextStyle(
              textStyle: TextStyle(color: theme.primaryColor),
            ),
          ),
          onTap: () {
            widget.composeDiscardDialogBuilder?.call(context) ??
                _showDefaultDiscardDialog(context);
          },
          style: const LMFeedButtonStyle(),
        ),
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
          LMFeedButton(
            text: LMFeedText(
              text: "Create",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: theme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            style: LMFeedButtonStyle(
              backgroundColor: theme.primaryColor,
              borderRadius: 6,
              height: 34,
            ),
            onTap: () {
              _focusNode.unfocus();

              String? heading = _headingController?.text;
              heading = heading?.trim();

              String postText = _controller.text;
              postText = postText.trim();
              if ((heading?.isNotEmpty ?? false) ||
                  postText.isNotEmpty ||
                  composeBloc.postMedia.isNotEmpty) {
                List<LMUserTagViewData> userTags = [...composeBloc.userTags];
                List<LMTopicViewData> selectedTopics = [
                  ...composeBloc.selectedTopics
                ];

                if (config!.enableHeading &&
                    config!.headingRequiredToCreatePost &&
                    (heading == null || heading.isEmpty)) {
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text:
                            "Can't create a $postTitleSmallCap without heading",
                      ),
                    ),
                  );
                  return;
                }

                if (config!.textRequiredToCreatePost && postText.isEmpty) {
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: "Can't create a $postTitleSmallCap without text",
                      ),
                    ),
                  );
                  return;
                }

                if (config!.topicRequiredToCreatePost &&
                    selectedTopics.isEmpty &&
                    config!.enableTopics) {
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: "Can't create a $postTitleSmallCap without topic",
                      ),
                    ),
                  );
                  return;
                }
                userTags =
                    LMFeedTaggingHelper.matchTags(_controller.text, userTags);

                result =
                    LMFeedTaggingHelper.encodeString(_controller.text, userTags)
                        .trim();

                sendPostCreationCompletedEvent(
                    [...composeBloc.postMedia], userTags, selectedTopics);
                if (widget.attachments != null &&
                    widget.attachments!.isNotEmpty &&
                    widget.attachments!.first.attachmentType == 5) {
                  composeBloc.postMedia.add(
                    LMMediaModel(
                      mediaType: LMMediaType.widget,
                      widgetsMeta:
                          widget.attachments?.first.attachmentMeta.meta,
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
                ));

                Navigator.pop(context);
              } else {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text:
                          "Can't create a $postTitleSmallCap without text or attachments",
                    ),
                  ),
                );
              }
            },
          ),
        ]);
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
                      width: MediaQuery.of(context).size.width - 82,
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
            deprecatedEventName: LMFeedAnalyticsKeysDep.userTaggedInPost,
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
            state is LMFeedComposeAddedVideoState) {
          rebuildTopicFloatingButton.value = !rebuildTopicFloatingButton.value;
        }
      },
      builder: (context, state) {
        if (composeBloc.postMedia.length == 10) {
          return const SizedBox();
        }
        if (composeBloc.postMedia.isNotEmpty &&
            composeBloc.postMedia.first.mediaType == LMMediaType.repost) {
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

    return ValueListenableBuilder(
        valueListenable: rebuildTopicFloatingButton,
        builder: (context, _, __) {
          return Container(
            margin: EdgeInsets.only(
              bottom: composeBloc.postMedia.length == 10 ? 0 : 25,
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
                          if (composeBloc.selectedTopics.isEmpty) {
                            composeBloc.selectedTopics.add(tappedTopic);
                          } else {
                            if (composeBloc.selectedTopics.first.id ==
                                tappedTopic.id) {
                              composeBloc.selectedTopics.clear();
                            } else {
                              composeBloc.selectedTopics.clear();
                              composeBloc.selectedTopics.add(tappedTopic);
                            }
                          }
                          _controllerPopUp.hideMenu();
                          rebuildTopicFloatingButton.value =
                              !rebuildTopicFloatingButton.value;
                        },
                      ),
                      child: Container(
                        height: 36,
                        alignment: Alignment.bottomLeft,
                        margin: const EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(500),
                          color: LMFeedCore.theme.container,
                          border: Border.all(
                            color: LMFeedCore.theme.primaryColor,
                          ),
                        ),
                        child: LMFeedTopicChip(
                          isSelected: false,
                          topic: composeBloc.selectedTopics.isEmpty
                              ? (LMTopicViewDataBuilder()
                                    ..id("0")
                                    ..isEnabled(true)
                                    ..name("Topic"))
                                  .build()
                              : composeBloc.selectedTopics.first,
                          style: LMFeedTopicChipStyle(
                            textStyle: TextStyle(
                              color: LMFeedCore.theme.primaryColor,
                            ),
                            icon: LMFeedIcon(
                              type: LMFeedIconType.icon,
                              icon: CupertinoIcons.chevron_down,
                              style: LMFeedIconStyle(
                                size: 16,
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

void sendPostCreationCompletedEvent(
  List<LMMediaModel> postMedia,
  List<LMUserTagViewData> usersTagged,
  List<LMTopicViewData> topics,
) {
  Map<String, String> propertiesMap = {};

  if (postMedia.isNotEmpty) {
    if (postMedia.first.mediaType == LMMediaType.link) {
      propertiesMap['link_attached'] = 'yes';
      propertiesMap['link'] =
          postMedia.first.ogTags?.url ?? postMedia.first.link!;
    } else {
      propertiesMap['link_attached'] = 'no';
      int imageCount = 0;
      int videoCount = 0;
      int documentCount = 0;
      for (LMMediaModel media in postMedia) {
        if (media.mediaType == LMMediaType.image) {
          imageCount++;
        } else if (media.mediaType == LMMediaType.video) {
          videoCount++;
        } else if (media.mediaType == LMMediaType.document) {
          documentCount++;
        }
      }
      if (imageCount > 0) {
        propertiesMap['image_attached'] = 'yes';
        propertiesMap['image_count'] = imageCount.toString();
      } else {
        propertiesMap['image_attached'] = 'no';
      }
      if (videoCount > 0) {
        propertiesMap['video_attached'] = 'yes';
        propertiesMap['video_count'] = videoCount.toString();
      } else {
        propertiesMap['video_attached'] = 'no';
      }

      if (documentCount > 0) {
        propertiesMap['document_attached'] = 'yes';
        propertiesMap['document_count'] = documentCount.toString();
      } else {
        propertiesMap['document_attached'] = 'no';
      }
    }
  }

  if (usersTagged.isNotEmpty) {
    int taggedUserCount = 0;
    List<String> taggedUserId = [];

    taggedUserCount = usersTagged.length;
    taggedUserId =
        usersTagged.map((e) => e.sdkClientInfo?.uuid ?? e.uuid!).toList();

    propertiesMap['user_tagged'] = taggedUserCount == 0 ? 'no' : 'yes';
    if (taggedUserCount > 0) {
      propertiesMap['tagged_users_count'] = taggedUserCount.toString();
      propertiesMap['tagged_users_id'] = taggedUserId.join(',');
    }
  }

  if (topics.isNotEmpty) {
    propertiesMap['topics_added'] = 'yes';
    propertiesMap['topics'] = topics.map((e) => e.id).toList().join(',');
  } else {
    propertiesMap['topics_added'] = 'no';
  }

  LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.postCreationCompleted,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    deprecatedEventName: LMFeedAnalyticsKeysDep.postCreationCompleted,
    eventProperties: propertiesMap,
  ));
}
