import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class LMFeedComposeScreen extends StatefulWidget {
  // Builder for appbar
  // Builder for content
  // Builder for media preview
  // Builder for bottom bar for buttons
  const LMFeedComposeScreen({
    super.key,
    //Widget builder functions for customizations
    this.composeDiscardDialogBuilder,
    this.composeAppBarBuilder,
    this.composeContentBuilder,
    this.composeTopicSelectorBuilder,
    this.composeMediaPreviewBuilder,
    //Config for the screen
    this.config,
    this.style,
  });

  final LMFeedComposeScreenConfig? config;

  final LMFeedComposeScreenStyle? style;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final PreferredSizeWidget Function(LMFeedAppBar oldAppBar)?
      composeAppBarBuilder;
  final Widget Function()? composeContentBuilder;
  final Widget Function(List<LMTopicViewData>)? composeTopicSelectorBuilder;
  final Widget Function()? composeMediaPreviewBuilder;

  @override
  State<LMFeedComposeScreen> createState() => _LMFeedComposeScreenState();
}

class _LMFeedComposeScreenState extends State<LMFeedComposeScreen> {
  /// Required blocs and data for basic functionality, or state management
  final User user = LMFeedUserLocalPreference.instance.fetchUserData();
  final LMFeedPostBloc bloc = LMFeedPostBloc.instance;
  final LMFeedComposeBloc composeBloc = LMFeedComposeBloc.instance;
  LMFeedThemeData? feedTheme;
  LMFeedComposeScreenStyle? style;
  LMFeedComposeScreenConfig? config;

  /// Controllers and other helper classes' objects
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final CustomPopupMenuController _controllerPopUp =
      CustomPopupMenuController();
  Timer? _debounce;
  String? result;
  Size? screenSize;

  /// Value notifiers to rebuild small widgets throughout the screen
  /// Rather than handling state management from complex classes
  ValueNotifier<bool> rebuildLinkPreview = ValueNotifier(false);
  ValueNotifier<bool> rebuildTopicFloatingButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    composeBloc.add(LMFeedComposeFetchTopicsEvent());
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (composeBloc.videoCount > 0) {
      LMFeedVideoProvider.instance.clearPostController(
          composeBloc.postMedia.first.mediaFile?.uri.toString() ?? '');
    }
    super.dispose();
  }

  /// Bloc listener for the compose bloc
  /// Handles all the events and states emitted by the compose bloc
  _composeBlocListener(BuildContext context, LMFeedComposeState state) {
    if (state is LMFeedComposeMediaErrorState) {
      toast("Error while selecting media, please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    feedTheme = LMFeedTheme.of(context);
    style = widget.style ?? feedTheme?.composeScreenStyle;
    screenSize = MediaQuery.of(context).size;
    config = widget.config ?? LMFeedCore.config.composeConfig;
    return WillPopScope(
      onWillPop: () {
        widget.composeDiscardDialogBuilder?.call(context) ??
            _showDefaultDiscardDialog(context);
        return Future.value(false);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: config!.composeSystemOverlayStyle,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
            bloc: composeBloc,
            listener: _composeBlocListener,
            child: Scaffold(
              backgroundColor: feedTheme?.container,
              bottomSheet: _defMediaPicker(),
              appBar: widget.composeAppBarBuilder?.call(_defAppBar()) ??
                  _defAppBar(),
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
                      return widget.composeTopicSelectorBuilder
                              ?.call(state.topics) ??
                          _defTopicSelector(state.topics);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
          backgroundColor: feedTheme?.container,
          title: const Text('Discard Post'),
          content:
              const Text('Are you sure you want to discard the current post?'),
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
                        color: LMFeedTheme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: const LMFeedButtonStyle(height: 42),
                  onTap: () {
                    LMFeedComposeBloc.instance.add(LMFeedComposeCloseEvent());
                    Navigator.of(dialogContext).pop();
                  },
                ),
                LikeMindsTheme.kHorizontalPaddingXLarge,
                LMFeedButton(
                  text: LMFeedText(
                    text: "Yes",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: LMFeedTheme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  style: const LMFeedButtonStyle(height: 42),
                  onTap: () {
                    composeBloc.postMedia.clear();
                    composeBloc.selectedTopics.clear();
                    composeBloc.userTags.clear();

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
                        color: feedTheme?.onContainer ?? Colors.black,
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
                        color: feedTheme?.onContainer ?? Colors.black,
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
                      mediaWidget = LMFeedDocument(
                        onRemove: () {
                          composeBloc.add(
                            LMFeedComposeRemoveAttachmentEvent(
                              index: index,
                            ),
                          );
                        },
                        documentFile: composeBloc.postMedia[index].mediaFile,
                        style: style?.mediaStyle?.documentStyle?.copyWith(
                              width: style?.mediaStyle?.documentStyle?.width ??
                                  MediaQuery.of(context).size.width - 84,
                            ) ??
                            LMFeedPostDocumentStyle(
                              width: screenSize!.width - 84,
                              height: 90,
                            ),
                        size: PostHelper.getFileSizeString(
                            bytes: composeBloc.postMedia[index].size ?? 0),
                      );
                      break;
                    }
                  default:
                    mediaWidget = const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
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
                                color: feedTheme?.disabledColor,
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
    final theme = LMFeedTheme.of(context);
    return LMFeedAppBar(
        style: LMFeedAppBarStyle(
          backgroundColor: feedTheme?.container ?? Colors.white,
          height: 72,
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
          text: "Create Post",
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
              text: "Post",
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
              width: 48,
              borderRadius: 6,
              height: 34,
            ),
            onTap: () {
              _focusNode.unfocus();

              String postText = _controller.text;
              postText = postText.trim();
              if (postText.isNotEmpty || composeBloc.postMedia.isNotEmpty) {
                List<LMUserTagViewData> userTags = composeBloc.userTags;
                List<LMTopicViewData> selectedTopics =
                    composeBloc.selectedTopics;

                if (config!.topicRequiredToCreatePost &&
                    selectedTopics.isEmpty &&
                    config!.enableTopics) {
                  toast(
                    "Can't create a post without topic",
                    duration: Toast.LENGTH_LONG,
                  );
                  return;
                }
                userTags =
                    LMFeedTaggingHelper.matchTags(_controller.text, userTags);

                result = LMFeedTaggingHelper.encodeString(
                    _controller.text, userTags);

                sendPostCreationCompletedEvent(
                    composeBloc.postMedia, userTags, selectedTopics);

                LMFeedPostBloc.instance.add(LMFeedCreateNewPostEvent(
                  user: user,
                  postText: result!,
                  selectedTopics: selectedTopics,
                  postMedia: composeBloc.postMedia,
                ));

                Navigator.pop(context);
              } else {
                toast(
                  "Can't create a post without text or attachments",
                  duration: Toast.LENGTH_LONG,
                );
              }
            },
          ),
        ]);
  }

  Widget _defContentInput() {
    final theme = LMFeedTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: LMFeedProfilePicture(
              fallbackText: user.name,
              imageUrl: user.imageUrl,
              style: LMFeedProfilePictureStyle(
                backgroundColor: theme.primaryColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 84,
                decoration: BoxDecoration(
                  color: theme.container,
                ),
                // constraints: BoxConstraints(
                //     maxHeight: screenSize.height * 0.8),
                child: LMTaggingAheadTextField(
                  isDown: true,
                  minLines: 3,
                  enabled: config!.enableTagging,
                  // maxLines: 200,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  onTagSelected: (tag) {
                    composeBloc.userTags.add(tag);
                    LMFeedAnalyticsBloc.instance.add(
                      LMFeedFireAnalyticsEvent(
                        eventName: LMFeedAnalyticsKeys.userTaggedInPost,
                        deprecatedEventName:
                            LMFeedAnalyticsKeysDep.userTaggedInPost,
                        eventProperties: {
                          'tagged_user_id': tag.sdkClientInfo?.userUniqueId ??
                              tag.userUniqueId,
                          'tagged_user_count':
                              composeBloc.userTags.length.toString(),
                        },
                      ),
                    );
                  },
                  controller: _controller,

                  focusNode: _focusNode,
                  onChange: _onTextChanged,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
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
      handleTextLinks(p0);
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
    final theme = LMFeedTheme.of(context);
    return BlocBuilder(
      bloc: composeBloc,
      builder: (context, state) {
        if (composeBloc.postMedia.length == 10 || composeBloc.videoCount == 1) {
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
              if (composeBloc.documentCount == 0 &&
                  composeBloc.imageCount == 0 &&
                  composeBloc.videoCount == 0 &&
                  config!.enableVideos)
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

    return Container(
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: ValueListenableBuilder(
                valueListenable: rebuildTopicFloatingButton,
                builder: (context, _, __) {
                  return GestureDetector(
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
                            color: LMFeedTheme.of(context).container,
                            border: Border.all(
                              color: LMFeedTheme.of(context).primaryColor,
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
                                color: LMFeedTheme.of(context).primaryColor,
                              ),
                              icon: LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: CupertinoIcons.chevron_down,
                                style: LMFeedIconStyle(
                                  size: 16,
                                  color: LMFeedTheme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
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
    taggedUserId = usersTagged
        .map((e) => e.sdkClientInfo?.userUniqueId ?? e.userUniqueId!)
        .toList();

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
    deprecatedEventName: LMFeedAnalyticsKeysDep.postCreationCompleted,
    eventProperties: propertiesMap,
  ));
}
