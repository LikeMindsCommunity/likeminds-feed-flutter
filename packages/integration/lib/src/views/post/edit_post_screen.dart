// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template lm_feed_edit_post_screen}
/// This screen is used to edit a post
/// It provides the user with the ability to edit the post
/// Attachments are not editable except links
/// [postViewData] is a required parameter
/// and is of type [LMPostViewData]
/// {@endtemplate}
class LMFeedEditPostScreen extends StatefulWidget {
  const LMFeedEditPostScreen({
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
    // Style for the screen
    this.style,
    // Post data to be edited
    required this.postId,
    this.displayName,
    this.displayUrl,
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
  final String postId;
  final String? displayName;
  final String? displayUrl;

  @override
  State<LMFeedEditPostScreen> createState() => _LMFeedEditPostScreenState();
}

class _LMFeedEditPostScreenState extends State<LMFeedEditPostScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);
  LMPostViewData? postViewData;
  final LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  final LMFeedPostBloc bloc = LMFeedPostBloc.instance;
  final LMFeedComposeBloc composeBloc = LMFeedComposeBloc.instance;
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  LMFeedComposeScreenStyle? style;
  LMFeedComposeScreenConfig? config;
  LMPostViewData? repost;
  LMFeedWidgetUtility widgetUtility = LMFeedCore.widgetUtility;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.editPostScreen;

  /// Controllers and other helper classes' objects
  FocusNode? _headingFocusNode;
  final FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();
  TextEditingController? _headingController = TextEditingController();
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

  // This function handles all the actions
  // for populating edit post screen with post data
  void onBoardPostDetails(LMPostViewData postViewData) {
    // Set the postViewData from the widget
    this.postViewData = postViewData;
    // Check if the post is a repost
    // If it is, then populate the repost object to generate
    // the repost preview
    _checkForRepost();
    // Set the config from the widget
    // If the widget does not have a config, then set the config
    // from the core
    config = widget.config ?? LMFeedCore.config.composeConfig;
    // Set the heading controller if the config allows it
    _headingController =
        (config?.enableHeading ?? false) ? TextEditingController() : null;
    // Populate the screen with the post details
    // heading controller with heading
    // text controller with post text
    fillScreenWithPostDetails();
    // Add an event in the compose bloc to
    // fetch the topics from the server
    composeBloc.add(LMFeedComposeFetchTopicsEvent());
    // Map the list of [AttachmentViewData] to [LMMediaModel]
    // and set the list in the compose bloc
    composeBloc.postMedia = postViewData.attachments
            ?.map((e) => LMMediaModel.fromAttachmentViewData(e))
            .toList() ??
        [];

    for (LMMediaModel media in composeBloc.postMedia) {
      if (media.mediaType == LMMediaType.video) {
        composeBloc.videoCount++;
      } else if (media.mediaType == LMMediaType.document) {
        composeBloc.documentCount++;
      } else if (media.mediaType == LMMediaType.image) {
        composeBloc.imageCount++;
      }
    }

    composeBloc.selectedTopics = postViewData.topics;
    // Open the on screen keyboard
    if (_headingController != null && config?.enableHeading == true) {
      _headingFocusNode = FocusNode();
      _headingFocusNode?.requestFocus();
    } else if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    // populate the post details
    // when the screen is initialized
    LMFeedPostBloc.instance
        .add(LMFeedGetPostEvent(postId: widget.postId, page: 1, pageSize: 10));
  }

  @override
  void didUpdateWidget(LMFeedEditPostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // populate the post details
    // when the widget is updated
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Clear the video controller from the media provider
    // to free up memory and avoid memory leaks
    if (composeBloc.videoCount > 0) {
      LMFeedVideoProvider.instance.clearPostController(
          composeBloc.postMedia.first.mediaFile?.uri.toString() ?? '');
    }
    // Add an event in the compose bloc to clear the current state
    composeBloc.add(LMFeedComposeCloseEvent());
    super.dispose();
  }

  // This function is used to populate
  // heading controller and text controller
  // with post heading and text content
  // It also populates the media list with
  // the media attached to the post
  void fillScreenWithPostDetails() {
    _headingController?.text = postViewData?.heading ?? '';

    composeBloc.userTags =
        LMFeedTaggingHelper.addUserTagsIfMatched(_controller.text);

    String postText = LMFeedTaggingHelper.convertRouteToTag(postViewData!.text);

    _controller = TextEditingController();
    _controller.text = postText;
  }

  // This function is used to populate
  // the repost object with the post
  // that is being reposted
  // The post that will be reposted will be added
  // to the media list
  void _checkForRepost() {
    if (postViewData?.attachments != null) {
      for (LMAttachmentViewData attachment in postViewData!.attachments!) {
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
        context,
        state.error ?? 'Error while selecting media, please try again',
        widgetSource,
      );
    }
  }

  // This functions checks for any disabled topics
  // in the selected topics list
  // return true if any topic is disabled
  // else return false
  bool checkForDisabledTopics() {
    List<String> disabledTopics = [];

    for (LMTopicViewData topic in composeBloc.selectedTopics) {
      if (!topic.isEnabled) {
        disabledTopics.add(topic.name);
      }
    }

    if (disabledTopics.isNotEmpty) {
      // Show a dialog to inform the user
      // that the selected topics are disabled
      // and the post cannot be saved
      showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
                backgroundColor: feedTheme.container,
                title: Text(
                  "Topic Disabled",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: feedTheme.onContainer),
                ),
                content: Text(
                  "The following topics have been disabled. Please remove them to save the $postTitleSmallCap.\n${disabledTopics.join(', ')}.",
                  style: TextStyle(
                    fontSize: 14,
                    color: feedTheme.onContainer,
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: Text(
                        'Okay',
                        style: TextStyle(
                          fontSize: 14,
                          color: feedTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ));
      return true;
    }
    return false;
  }

  // This function checks if topics are required
  // and selected
  // If topics are required and not selected
  // then show a snackbar and return false
  bool checkIfTopicAreRequiredAndSelected() {
    if (config!.topicRequiredToCreatePost &&
        composeBloc.selectedTopics.isEmpty &&
        config!.enableTopics) {
      LMFeedCore.showSnackBar(
        context,
        "Can't create a $postTitleSmallCap without topic",
        widgetSource,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    config = widget.config ?? LMFeedCore.config.composeConfig;
    style = widget.style ?? feedTheme.composeScreenStyle;
    screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        widget.composeDiscardDialogBuilder?.call(context) ??
            _showDefaultDiscardDialog(context);
        return Future.value(false);
      },
      child: BlocConsumer(
          listener: (prev, curr) {
            if (curr is LMFeedGetPostSuccessState) {
              onBoardPostDetails(curr.post);
            } else if (curr is LMFeedPostErrorState) {
              LMFeedCore.showSnackBar(context, curr.errorMessage, widgetSource);
            }
          },
          bloc: LMFeedPostBloc.instance,
          builder: (context, state) {
            if (state is LMFeedGetPostLoadingState) {
              return Scaffold(
                backgroundColor: feedTheme.container,
                body: Center(child: LMFeedLoader()),
              );
            } else if (state is LMFeedGetPostSuccessState) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: config!.composeSystemOverlayStyle,
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
                    bloc: composeBloc,
                    listener: _composeBlocListener,
                    child: widgetUtility.scaffold(
                      source: widgetSource,
                      backgroundColor: feedTheme.container,
                      appBar: widget.composeAppBarBuilder?.call(_defAppBar()) ??
                          _defAppBar(),
                      floatingActionButton: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child:
                            BlocBuilder<LMFeedComposeBloc, LMFeedComposeState>(
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
                            bottom: 100,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 18),
                                widget.composeUserHeaderBuilder
                                        ?.call(context, user!) ??
                                    widgetUtility
                                        .composeScreenUserHeaderBuilder(
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
            } else {
              return Scaffold(
                backgroundColor: feedTheme.container,
                body: const SizedBox(),
              );
            }
          }),
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
                        onPostTap: (context, postData) {},
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
                LMMediaModel mediaModel = composeBloc.postMedia[index];
                switch (mediaModel.mediaType) {
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
                        imageUrl: mediaModel.link,
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
                        videoUrl: mediaModel.link,
                        style: style?.mediaStyle?.videoStyle,
                        postId: postViewData!.id,
                      ),
                    );
                    break;
                  case LMMediaType.link:
                    mediaWidget = LMFeedLinkPreview(
                      linkModel: mediaModel,
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
                          Uri.parse(mediaModel.ogTags?.url ?? ''),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      title: LMFeedText(
                        text: mediaModel.ogTags?.title ?? "--",
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
                        text: mediaModel.ogTags?.description ?? "--",
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
                        documentUrl: mediaModel.link,
                        style: style?.mediaStyle?.documentStyle?.copyWith(
                              width: style?.mediaStyle?.documentStyle?.width ??
                                  MediaQuery.of(context).size.width - 84,
                            ) ??
                            LMFeedPostDocumentStyle(
                              width: screenSize!.width - 84,
                              height: 90,
                              removeIcon: null,
                            ),
                        size: PostHelper.getFileSizeString(
                            bytes: mediaModel.size ?? 0),
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
                      if (composeBloc.postMedia[index].mediaType ==
                          LMMediaType.link)
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
          text: "Edit $postTitleFirstCap",
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
              text: "Save",
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
            onTap: () async {
              // Close the on screen keyboard if it is open
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
                    context,
                    "Can't create a $postTitleSmallCap without heading",
                    widgetSource,
                  );
                  return;
                }

                if (config!.textRequiredToCreatePost && postText.isEmpty) {
                  LMFeedCore.showSnackBar(
                    context,
                    "Can't create a $postTitleSmallCap without text",
                    widgetSource,
                  );
                  return;
                }

                // Check if topics are required to create/edit a post
                // if yes, check if the selected topics list is empty
                // if it is, then show a snackbar and return
                if (!checkIfTopicAreRequiredAndSelected()) {
                  return;
                }

                // check if the selected topic list has any
                // disabled topics in it or not
                // if it has, then show a snackbar and return
                if (checkForDisabledTopics()) {
                  return;
                }

                userTags =
                    LMFeedTaggingHelper.matchTags(_controller.text, userTags);

                result =
                    LMFeedTaggingHelper.encodeString(_controller.text, userTags)
                        .trim();

                if (postViewData?.attachments != null &&
                    postViewData!.attachments!.isNotEmpty &&
                    postViewData!.attachments!.first.attachmentType == 5) {
                  composeBloc.postMedia.add(
                    LMMediaModel(
                      mediaType: LMMediaType.widget,
                      widgetsMeta:
                          postViewData!.attachments?.first.attachmentMeta.meta,
                    ),
                  );
                }

                LMFeedPostBloc.instance.add(
                  LMFeedEditPostEvent(
                    postId: postViewData!.id,
                    postText: result!,
                    selectedTopics: selectedTopics,
                    heading: _headingController?.text,
                  ),
                );

                Navigator.pop(context);
              } else {
                LMFeedCore.showSnackBar(
                  context,
                  "Can't create a $postTitleSmallCap without text or attachments",
                  widgetSource,
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
              ? TextField(
                  focusNode: _headingFocusNode,
                  controller: _headingController,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: feedTheme.primaryColor,
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
                    ),
                  ),
                  style: TextStyle(
                    color: theme.onContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
                    child: LMTaggingAheadTextField(
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
                      ),
                      onTagSelected: (tag) {
                        composeBloc.userTags.add(tag);
                        LMFeedAnalyticsBloc.instance.add(
                          LMFeedFireAnalyticsEvent(
                            eventName: LMFeedAnalyticsKeys.userTaggedInPost,
                            widgetSource: LMFeedWidgetSource.editPostScreen,
                            eventProperties: {
                              'tagged_user_id':
                                  tag.sdkClientInfo?.uuid ?? tag.uuid,
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
    return BlocBuilder(
      bloc: composeBloc,
      builder: (context, state) {
        if (composeBloc.postMedia.length == 10 || composeBloc.videoCount == 1) {
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
                  );
                }),
          ),
        ],
      ),
    );
  }
}
