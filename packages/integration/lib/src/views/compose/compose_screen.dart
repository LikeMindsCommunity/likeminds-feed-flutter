import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/widgets/lists/topic_list.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMFeedPostComposeScreen extends StatefulWidget {
  //Builder for appbar
  //Builder for content
  //Builder for media preview
  //Builder for bottom bar for buttons
  const LMFeedPostComposeScreen({
    super.key,
    //Widget builder functions for customizations
    this.composeDiscardDialogBuilder,
    this.composeAppBarBuilder,
    this.composeContentBuilder,
    this.composeTopicSelectorBuilder,
    //Default values for additional variables
    this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
    this.composeHint = "Write something here..",
    this.enableDocuments = true,
    this.enableImages = true,
    this.enableLinkPreviews = true,
    this.enableTagging = true,
    this.enableTopics = true,
    this.enableVideos = true,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedPostComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

  /// The hint text shown to a user while inputting text for post
  final String composeHint;

  ///@{template}
  /// Feature booleans to enable/disable features on the fly
  /// [bool] to enable/disable image upload
  final bool enableImages;

  /// [bool] to enable/disable documents upload
  final bool enableDocuments;

  /// [bool] to enable/disable videos upload
  final bool enableVideos;

  /// [bool] to enable/disable tagging feature
  final bool enableTagging;

  /// [bool] to enable/disable topic selection
  final bool enableTopics;

  /// [bool] to enable/disable link previews
  final bool enableLinkPreviews;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final Widget Function()? composeAppBarBuilder;
  final Widget Function()? composeContentBuilder;
  final Widget Function(List<LMTopicViewData>)? composeTopicSelectorBuilder;

  @override
  State<LMFeedPostComposeScreen> createState() =>
      _LMFeedPostComposeScreenState();
}

class _LMFeedPostComposeScreenState extends State<LMFeedPostComposeScreen> {
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

  /// Lists to maintain throughout the screen for sending/receiving data
  List<LMMediaModel> postMedia = [];
  List<UserTag> userTags = [];
  List<LMTopicViewData> selectedTopics = [];

  /// Value notifiers to rebuild small widgets throughout the screen
  /// Rather than handling state management from complex classes
  ValueNotifier<bool> rebuildLinkPreview = ValueNotifier(false);
  ValueNotifier<bool> rebuildTopicFloatingButton = ValueNotifier(false);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    composeBloc.add(LMFeedComposeFetchTopicsEvent());
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
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
        value: widget.composeSystemOverlayStyle,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                widget.composeAppBarBuilder?.call() ?? _defAppBar(),
                const SizedBox(height: 18),
                widget.composeContentBuilder?.call() ?? _defContentInput(),
              ],
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
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _defAppBar() {
    final theme = LMFeedTheme.of(context);
    return LMFeedAppBar(
      backgroundColor: Colors.white,
      height: 56,
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      leading: LMFeedButton(
        text: LMFeedText(
          text: "Cancel",
          style: LMFeedTextStyle(
            textStyle: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        onTap: () {
          widget.composeDiscardDialogBuilder?.call(context) ??
              _showDefaultDiscardDialog(context);
        },
      ),
      title: const LMFeedText(
        text: "Create Post",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
      ),
      trailing: LMFeedButton(
        text: LMFeedText(
          text: "Post",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: LMFeedButtonStyle(
          backgroundColor: theme.colorScheme.primary,
          width: 48,
          borderRadius: 6,
        ),
        onTap: () {
          _focusNode.unfocus();

          String postText = _controller.text;
          postText = postText.trim();
          // if (postText.isNotEmpty || postMedia.isNotEmpty) {
          //   if (selectedTopic.isEmpty) {
          //     toast(
          //       "Can't create a post without topic",
          //       duration: Toast.LENGTH_LONG,
          //     );
          //     return;
          //   }
          //   checkTextLinks();
          //   userTags = TaggingHelper.matchTags(_controller.text, userTags);

          //   result = TaggingHelper.encodeString(_controller.text, userTags);

          //   sendPostCreationCompletedEvent(postMedia, userTags, selectedTopic);

          //   lmPostBloc!.add(
          //     CreateNewPost(
          //       postText: result!,
          //       postMedia: postMedia,
          //       selectedTopics: selectedTopic,
          //       user: user,
          //     ),
          //   );
          //   videoController?.player.pause();
          //   Navigator.pop(context);
          // } else {
          //   toast(
          //     "Can't create a post without text or attachments",
          //     duration: Toast.LENGTH_LONG,
          //   );
          // }
        },
      ),
    );
  }

  Widget _defContentInput() {
    return Container();
  }

  Widget _defMediaPicker() {
    return Container(
      color: Colors.red,
      height: 72,
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
                          color: LMFeedTheme.of(context).colorScheme.background,
                          border: Border.all(
                            color: LMFeedTheme.of(context).primaryColor,
                          ),
                        ),
                        child: LMFeedTopicChip(
                          topic: selectedTopics.isEmpty
                              ? (LMTopicViewDataBuilder()
                                    ..id("0")
                                    ..isEnabled(true)
                                    ..name("Topic"))
                                  .build()
                              : selectedTopics.first,
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
                );
              }),
        ),
      ],
    );
  }
}
