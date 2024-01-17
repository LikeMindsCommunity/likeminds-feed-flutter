import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/compose_screen_config.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/lists/topic_list.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedComposeScreen extends StatefulWidget {
  //Builder for appbar
  //Builder for content
  //Builder for media preview
  //Builder for bottom bar for buttons
  const LMFeedComposeScreen({
    super.key,
    //Widget builder functions for customizations
    this.composeDiscardDialogBuilder,
    this.composeAppBarBuilder,
    this.composeContentBuilder,
    this.composeTopicSelectorBuilder,
    this.composeMediaPreviewBuilder,
    //Config for the screen
    this.config = const LMFeedComposeScreenConfig(),
  });

  final LMFeedComposeScreenConfig config;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final Widget Function(LMFeedAppBar oldAppBar)? composeAppBarBuilder;
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

  /// Controllers and other helper classes' objects
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final CustomPopupMenuController _controllerPopUp =
      CustomPopupMenuController();
  Timer? _debounce;
  String? result;

  /// Lists to maintain throughout the screen for sending/receiving data
  List<LMUserTagViewData> userTags = [];
  List<LMTopicViewData> selectedTopics = [];

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
    final theme = LMFeedTheme.of(context);
    return WillPopScope(
      onWillPop: () {
        widget.composeDiscardDialogBuilder?.call(context) ??
            _showDefaultDiscardDialog(context);
        return Future.value(false);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.config.composeSystemOverlayStyle,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: BlocListener<LMFeedComposeBloc, LMFeedComposeState>(
            bloc: composeBloc,
            listener: _composeBlocListener,
            child: Scaffold(
              backgroundColor: theme.container,
              bottomSheet: _defMediaPicker(),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 42.0, left: 16.0),
                child: BlocBuilder<LMFeedComposeBloc, LMFeedComposeState>(
                  bloc: composeBloc,
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
                child: Column(
                  children: [
                    widget.composeAppBarBuilder?.call(_defAppBar()) ??
                        _defAppBar(),
                    const SizedBox(height: 18),
                    widget.composeContentBuilder?.call() ?? _defContentInput(),
                    const SizedBox(height: 18),
                    widget.composeMediaPreviewBuilder?.call() ??
                        _defMediaPreview(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDefaultDiscardDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Discard Post'),
        content:
            const Text('Are you sure you want to discard the current post?'),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.all(8),
        actions: <Widget>[
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
              Navigator.of(dialogContext).pop();
            },
          ),
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
        ],
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
          if (state is LMFeedComposeAddedImageState) {
            return Container(
              height: 240,
              width: double.infinity,
              color: Colors.grey,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: composeBloc.postMedia.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LMFeedPostImage(
                      imageFile: composeBloc.postMedia[index].mediaFile,
                    ),
                  );
                },
              ),
            );
          }
          if (state is LMFeedComposeAddedVideoState) {
            return SizedBox(
              height: 240,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: composeBloc.postMedia.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LMFeedPostVideo(
                      videoFile: composeBloc.postMedia[index].mediaFile,
                    ),
                  );
                },
              ),
            );
          }
          if (state is LMFeedComposeAddedDocumentState) {
            return Container(
              height: 240,
              width: double.infinity,
              color: Colors.grey,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: composeBloc.postMedia.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LMFeedDocument(
                      documentFile: composeBloc.postMedia[index].mediaFile,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        });
  }

  LMFeedAppBar _defAppBar() {
    final theme = LMFeedTheme.of(context);
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: Colors.white,
        height: 72,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      trailing: LMFeedButton(
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
          height: 32,
          borderRadius: 6,
        ),
        onTap: () {
          _focusNode.unfocus();

          String postText = _controller.text;
          postText = postText.trim();
          if (postText.isNotEmpty) {
            // if (selectedTopics.isEmpty) {
            //   toast(
            //     "Can't create a post without topic",
            //     duration: Toast.LENGTH_LONG,
            //   );
            //   return;
            // }
            // checkTextLinks();
            userTags =
                LMFeedTaggingHelper.matchTags(_controller.text, userTags);

            result =
                LMFeedTaggingHelper.encodeString(_controller.text, userTags);

            sendPostCreationCompletedEvent(
                composeBloc.postMedia, userTags, selectedTopics);

            LMFeedPostBloc.instance.add(LMFeedCreateNewPostEvent(
              user: user,
              postText: result!,
              selectedTopics: selectedTopics,
              postMedia: composeBloc.postMedia,
            ));
            composeBloc.add(LMFeedComposeCloseEvent());
            Navigator.pop(context);
          } else {
            toast(
              "Can't create a post without text or attachments",
              duration: Toast.LENGTH_LONG,
            );
          }
        },
      ),
    );
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
                    userTags.add(tag);
                  },
                  controller: _controller,
                  focusNode: _focusNode,
                  // onChange: _onTextChanged,
                  onChange: (p) {},
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defMediaPicker() {
    final theme = LMFeedTheme.of(context);
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
          LMFeedButton(
            isActive: false,
            style: LMFeedButtonStyle(
              placement: LMFeedIconButtonPlacement.start,
              height: 42,
              width: 42,
              showText: false,
              icon: LMFeedIcon(
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
          LMFeedButton(
            isActive: false,
            style: LMFeedButtonStyle(
              placement: LMFeedIconButtonPlacement.start,
              height: 42,
              width: 42,
              showText: false,
              icon: LMFeedIcon(
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
          LMFeedButton(
            isActive: false,
            style: LMFeedButtonStyle(
              placement: LMFeedIconButtonPlacement.start,
              height: 42,
              width: 42,
              showText: false,
              icon: LMFeedIcon(
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
  }

  Widget _defTopicSelector(List<LMTopicViewData> topics) {
    return Row(
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
                          selectedTopics: selectedTopics,
                          isEnabled: true,
                          onTopicSelected: (updatedTopics, tappedTopic) {
                            if (selectedTopics.isEmpty) {
                              selectedTopics.add(tappedTopic);
                            } else {
                              if (selectedTopics.first.id == tappedTopic.id) {
                                selectedTopics.clear();
                              } else {
                                selectedTopics.clear();
                                selectedTopics.add(tappedTopic);
                              }
                            }
                            _controllerPopUp.hideMenu();
                            rebuildTopicFloatingButton.value =
                                !rebuildTopicFloatingButton.value;
                          }),
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
                          topic: selectedTopics.isEmpty
                              ? (LMTopicViewDataBuilder()
                                    ..id("0")
                                    ..isEnabled(true)
                                    ..name("Topic"))
                                  .build()
                              : selectedTopics.first,
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
    eventProperties: propertiesMap,
  ));
}
