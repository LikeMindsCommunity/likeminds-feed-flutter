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

/// {@template feed_compose_screen}
/// A screen widget that facilitates the creation of a new feed post.
///
/// The `LMFeedComposeScreen` provides a customizable interface for users
/// to create and submit posts. It supports various content types like text,
/// media, and topics, and offers several customization points to adapt the UI
/// and behavior to specific requirements.
///
/// ### Customization Options:
/// - [composeDiscardDialogBuilder]: A function to build a custom dialog when the discard action is triggered.
/// - [composeAppBarBuilder]: A function to build a custom app bar for the compose screen.
/// - [composeContentBuilder]: A function to build a custom content area for the post.
/// - [composeTopicSelectorBuilder]: A function to build a custom topic selector widget.
/// - [composeMediaPreviewBuilder]: A function to build a custom media preview for selected attachments.
/// - [composeUserHeaderBuilder]: A function to build a custom user header widget displaying user information.
///
/// ### Configuration Options:
/// - [config]: Configuration settings for the feed compose screen, such as whether heading and topics are required.
/// - [style]: Style settings for customizing the visual appearance of the compose screen.
/// - [attachments]: A list of pre-selected attachments (media) to include in the post.
/// - [displayName]: The name to display for the user creating the post.
/// - [displayUrl]: A URL pointing to the user's display picture.
/// - [feedroomId]: The ID of the feed room where the post is being created.
/// - [widgetSource]: Information about the source of the widget, for internal tracking.
///
/// ### Example Usage:
/// ```dart
/// LMFeedComposeScreen(
///   composeAppBarBuilder: (oldAppBar, onPostCreate, createPostButton, cancelButton, onValidationFailed) {
///     return AppBar(
///       title: Text('Custom Compose App Bar'),
///       actions: [
///         IconButton(
///           icon: Icon(Icons.cancel),
///           onPressed: () => cancelButton.onTap(),
///         ),
///         IconButton(
///           icon: Icon(Icons.check),
///           onPressed: () {
///             LMResponse response = onPostCreate();
///             if (!response.success) {
///               onValidationFailed(response.errorMessage ?? 'Validation failed');
///             }
///           },
///         ),
///       ],
///     );
///   },
///   config: LMFeedComposeScreenConfig(
///     enableHeading: true,
///     textRequiredToCreatePost: true,
///     topicRequiredToCreatePost: true,
///   ),
///   style: LMFeedComposeScreenStyle(
///     backgroundColor: Colors.white,
///   ),
///   displayName: 'John Doe',
///   displayUrl: 'https://example.com/avatar.png',
///   feedroomId: 12345,
/// )
/// ```
///
/// This screen manages user input, validation, and submission, allowing you
/// to build a fully customizable post creation experience.
/// {@endtemplate}
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

  /// {@template composeAppBarBuilder}
  /// A builder function for customizing the app bar in the feed compose screen.
  ///
  /// This function allows you to override the default app bar with a custom
  /// implementation. It provides various parameters related to post creation
  /// and validation that can be used to control the behavior of the app bar.
  ///
  /// - [oldAppBar]: The default `LMFeedAppBar` that can be modified or replaced.
  /// - [onPostCreate]: A function to be called when the post creation process starts.
  ///   It validates the post content (e.g., text, heading, attachments).
  ///   Returns an `LMResponse` indicating success or failure.
  /// - [createPostButton]: The default button used to trigger post creation. Can be customized.
  /// - [cancelButton]: The default cancel button used to discard the post creation process.
  /// - [onValidationFailed]: A callback function triggered when post creation validation fails,
  ///   taking an error message as input.
  ///
  /// Example:
  /// ```dart
  /// composeAppBarBuilder: (oldAppBar, onPostCreate, createPostButton, cancelButton, onValidationFailed) {
  ///   return AppBar(
  ///     title: Text('Custom Compose App Bar'),
  ///     actions: [
  ///       IconButton(
  ///         icon: Icon(Icons.cancel),
  ///         onPressed: () => cancelButton.onTap(),
  ///       ),
  ///       IconButton(
  ///         icon: Icon(Icons.check),
  ///         onPressed: () {
  ///           LMResponse response = onPostCreate();
  ///           if (!response.success) {
  ///             onValidationFailed(response.errorMessage ?? 'Post creation failed');
  ///           }
  ///         },
  ///       ),
  ///     ],
  ///   );
  /// },
  /// ```
  /// {@endtemplate}
  final PreferredSizeWidget Function(
    LMFeedAppBar oldAppBar,
    LMResponse<void> Function() onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  )? composeAppBarBuilder;

  /// {@template composeContentBuilder}
  /// A function to build a custom content area for the post.
  ///
  /// The `composeContentBuilder` allows you to override the default post content
  /// area. You can provide a custom widget to display as the main content of
  /// the post creation screen.
  ///
  /// - Returns: A custom widget to be displayed as the content area.
  /// {@endtemplate}
  final Widget Function()? composeContentBuilder;

  /// {@template composeTopicSelectorBuilder}
  /// A function to build a custom topic selector widget.
  ///
  /// The `composeTopicSelectorBuilder` allows you to override the default topic
  /// selector. This function provides a context, the default `topicSelector` widget,
  /// and a list of selected topics (`LMTopicViewData`), which can be used to customize
  /// how topics are selected or displayed.
  ///
  /// - [context]: The build context.
  /// - [topicSelector]: The default topic selector widget, which you can modify or replace.
  /// - [List<LMTopicViewData>]: A list of selected topics to display.
  ///
  /// - Returns: A custom widget that serves as the topic selector.
  /// {@endtemplate}
  final Widget Function(
          BuildContext context, Widget topicSelector, List<LMTopicViewData>)?
      composeTopicSelectorBuilder;

  /// {@template composeMediaPreviewBuilder}
  /// A function to build a custom media preview for the selected attachments.
  ///
  /// The `composeMediaPreviewBuilder` allows you to customize how selected
  /// media attachments (images, videos, etc.) are previewed in the compose screen.
  ///
  /// - Returns: A custom widget for displaying the media preview.
  /// {@endtemplate}
  final Widget Function()? composeMediaPreviewBuilder;

  /// {@template composeUserHeaderBuilder}
  /// A function to build a custom user header widget displaying user information.
  ///
  /// The `composeUserHeaderBuilder` allows you to customize the appearance and content
  /// of the user header at the top of the compose screen, typically showing user
  /// information like their name and profile picture.
  ///
  /// - [context]: The build context.
  /// - [user]: An instance of `LMUserViewData` representing the user.
  ///
  /// - Returns: A custom widget displaying the user header.
  /// {@endtemplate}
  final Widget Function(BuildContext context, LMUserViewData user)?
      composeUserHeaderBuilder;

  /// {@template lmFeedComposeScreenAttachments}
  /// A list of attachments (media) selected for the post.
  ///
  /// This field contains any pre-selected media attachments (e.g., images, videos)
  /// that will be included in the post.
  ///
  /// - [LMAttachmentViewData]: A list of media attachments.
  /// {@endtemplate}
  final List<LMAttachmentViewData>? attachments;

  /// {@template lmFeedComposeScreenDisplayName}
  /// The display name of the user creating the post.
  ///
  /// This field represents the name that is displayed on the compose screen for
  /// the user who is creating the post.
  /// {@endtemplate}
  final String? displayName;

  /// {@template lmFeedComposeScreenDisplayUrl}
  /// The URL for the user's display picture.
  ///
  /// This field contains the URL pointing to the user's profile picture, which
  /// can be displayed in the user header or other relevant areas of the screen.
  /// {@endtemplate}
  final String? displayUrl;

  /// {@template lmFeedComposeScreenFeedroomId}
  /// The ID of the feed room where the post is being created.
  ///
  /// This field represents the unique identifier of the feed room (or group)
  /// in which the post is being submitted.
  /// {@endtemplate}
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
  String? heading;
  String postText = '';
  List<LMTopicViewData> selectedTopics = [];
  List<LMUserTagViewData> userTags = [];

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
              attachmentMeta: (LMAttachmentMetaViewData.builder()
                    ..post(repost)
                    ..postId(repost?.id))
                  .build(),
            ),
          );
        } else {
          // Handle other attachment types (images/videos)
          composeBloc.postMedia.add(
            LMAttachmentViewData.fromAttachmentMeta(
              attachmentType: attachment.attachmentType,
              attachmentMeta: attachment.attachmentMeta,
            ),
          );
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
                  validatePost,
                  _defPostCreateButton(),
                  _defCancelButton(),
                  onPostValidationFailed,
                ) ??
                widgetUtility.composeScreenAppBar(
                  context,
                  _defAppBar(),
                  onPostCreate,
                  validatePost,
                  _defPostCreateButton(),
                  _defCancelButton(),
                  onPostValidationFailed,
                ),
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
    return BlocBuilder<LMFeedPostBloc, LMFeedPostState>(
      bloc: LMFeedPostBloc.instance,
      builder: (context, state) {
        if (state is LMFeedNewPostUploadingState) {
          return StreamBuilder<double>(
            stream: state.progress,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return LinearProgressIndicator(
                  value: snapshot.data,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(feedTheme.primaryColor),
                );
              }
              return const SizedBox();
            },
          );
        }

        // Rest of the media preview code remains the same
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
                      text: getFormattedDateTime(composeBloc
                          .postMedia.first.attachmentMeta.expiryTime),
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
                                  color: LMFeedCore.theme.onContainer
                                      .withOpacity(0.1),
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
                            color:
                                style?.mediaStyle?.imageStyle?.backgroundColor,
                            borderRadius:
                                style?.mediaStyle?.imageStyle?.borderRadius,
                          ),
                          height: style?.mediaStyle?.imageStyle?.height ??
                              screenWidth,
                          width: style?.mediaStyle?.imageStyle?.width ??
                              screenWidth,
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
                          height: style?.mediaStyle?.videoStyle?.height ??
                              screenWidth,
                          width: style?.mediaStyle?.videoStyle?.width ??
                              screenWidth,
                          decoration: BoxDecoration(
                            color:
                                style?.mediaStyle?.imageStyle?.backgroundColor,
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
                              Uri.parse(composeBloc.postMedia[index]
                                      .attachmentMeta.ogTags?.url ??
                                  ''),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          title: LMFeedText(
                            text: composeBloc.postMedia[index].attachmentMeta
                                    .ogTags?.title ??
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
                            text: composeBloc.postMedia[index].attachmentMeta
                                    .ogTags?.description ??
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
                                  width:
                                      style?.mediaStyle?.documentStyle?.width ??
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
                              right:
                                  composeBloc.postMedia.first.attachmentType ==
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
                                    LMFeedVideoProvider.instance
                                        .clearPostController(
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
      },
    );
  }

  // Default "Cancel" button widget creation
  LMFeedButton _defCancelButton() {
    return LMFeedButton(
      // Setting the button text and style
      text: LMFeedText(
        text: "Cancel",
        style: LMFeedTextStyle(
          textStyle: TextStyle(color: feedTheme.primaryColor),
        ),
      ),
      // Defining the button's tap behavior
      onTap: () {
        // If a custom discard dialog is provided, show it
        // Otherwise, show the default discard dialog
        widget.composeDiscardDialogBuilder?.call(context) ??
            _showDefaultDiscardDialog(context);
      },
      // Applying additional style properties
      style: const LMFeedButtonStyle(),
    );
  }

// Default "Create Post" button widget creation
  LMFeedButton _defPostCreateButton() {
    return LMFeedButton(
      // Setting the button text and style
      text: LMFeedText(
        text: "Create",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: feedTheme.onPrimary, // Button text color
            fontSize: 14, // Font size
            fontWeight: FontWeight.w500, // Font weight
          ),
        ),
      ),
      // Button style including background color and padding
      style: LMFeedButtonStyle(
        backgroundColor: feedTheme.primaryColor, // Button background color
        borderRadius: 6, // Border radius
        height: 34, // Button height
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      // Defining the button's tap behavior
      onTap: () {
        // Trigger the post creation process
        LMResponse response = onPostCreate.call();

        // Check if post creation was successful
        if (response.success) {
          // If successful, proceed with post validation success flow
          onPostValidationSuccess();
        } else {
          // If failed, handle validation failure and show an error message
          onPostValidationFailed(
              response.errorMessage ?? "An error occurred, please try again");
        }
      },
    );
  }

// Function to handle post creation success
  void onPostValidationSuccess() {
    // Close the screen and return to the previous view
    Navigator.pop(context);
  }

// Function to handle post creation failure
  void onPostValidationFailed(String errorMessage) {
    // Show a snackbar with the error message
    LMFeedCore.showSnackBar(
      context,
      errorMessage,
      widgetSource, // Source of the widget, useful for tracking
    );
  }

// Function to build the default app bar
  LMFeedAppBar _defAppBar() {
    final theme = LMFeedCore.theme;
    return LMFeedAppBar(
      // App bar style properties
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container, // Background color of the app bar
        height: 48, // App bar height
        centerTitle: true, // Center the title
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        shadow: [
          BoxShadow(
            color: Colors.grey.shade300, // Shadow color
            blurRadius: 1.0, // Shadow blur radius
            offset: const Offset(0.0, 1.0), // Shadow offset
          ),
        ],
      ),
      // Setting the leading widget (Cancel button)
      leading: _defCancelButton(),
      // Setting the app bar title
      title: LMFeedText(
        text: "Create $postTitleFirstCap",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 18, // Title font size
            fontWeight: FontWeight.w700, // Title font weight
            color: theme.onContainer, // Title text color
          ),
        ),
      ),
      // Setting the trailing widget (Post create button)
      trailing: [
        _defPostCreateButton(),
      ],
    );
  }

  LMResponse<void> validatePost() {
    // Remove focus from text fields to dismiss the keyboard
    _focusNode.unfocus();

    // Get the trimmed heading and post text values
    heading = _headingController?.text;
    heading = heading?.trim();

    postText = _controller.text;
    postText = postText.trim();

    // Check if there is content (heading, post text, or media) to create the post
    if ((heading?.isNotEmpty ?? false) ||
        postText.isNotEmpty ||
        composeBloc.postMedia.isNotEmpty) {
      // Collect user tags and topics for the post
      userTags = [...composeBloc.userTags];
      selectedTopics = [...composeBloc.selectedTopics];

      // Validate the heading if required
      if (config!.enableHeading &&
          config!.headingRequiredToCreatePost &&
          (heading == null || heading!.isEmpty)) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without heading",
        );
      }

      // Validate the text if required
      if (config!.textRequiredToCreatePost && postText.isEmpty) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without text",
        );
      }

      // Validate the topic selection if required
      if (config!.topicRequiredToCreatePost &&
          selectedTopics.isEmpty &&
          config!.enableTopics) {
        return LMResponse(
          success: false,
          errorMessage: "Can't create a $postTitleSmallCap without topic",
        );
      }

      // Match user tags from the post text and prepare for encoding
      userTags = LMFeedTaggingHelper.matchTags(_controller.text, userTags);
      result =
          LMFeedTaggingHelper.encodeString(_controller.text, userTags).trim();
      return LMResponse(success: true);
    } else {
      // Return error response if no content to create the post
      return LMResponse(
        success: false,
        errorMessage:
            "Can't create a $postTitleSmallCap without text or attachments",
      );
    }
  }

// Update the onPostCreate method to handle the new upload flow
  LMResponse<void> onPostCreate() {
    // Create a StreamController for upload progress
    StreamController<double> progressController =
        StreamController<double>.broadcast();
    // validate post creation data
    LMResponse response = validatePost();
    // if validation fails return the error response
    if (!response.success) {
      return response;
    }
    // Add a new post event to the post bloc
    LMFeedPostBloc.instance.add(LMFeedCreateNewPostEvent(
      user: user!,
      postText: result!,
      selectedTopicIds: selectedTopics.map((e) => e.id).toList(),
      postMedia: [...composeBloc.postMedia],
      heading: heading,
      feedroomId: widget.feedroomId,
      userTagged: userTags,
    ));

    // Return success response
    return LMResponse(success: true);
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
          if (config?.enableHeading ?? false)
            Column(
              children: [
                LMFeedCore.widgetUtility.composeScreenHeadingTextfieldBuilder(
                  context,
                  _defHeadingTextfield(theme),
                )
              ],
            ),
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
      enabled: config!.enableTagging,
      // maxLines: 200,

      style: LMTaggingAheadTextFieldStyle(
        minLines: 3,
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
      maxLength: 200,
      maxLines: 4,
      minLines: 1,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.inActiveColor,
          ),
        ),
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
