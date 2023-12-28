import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post/post_bloc.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMPostComposeScreen extends StatefulWidget {
  //Builder for appbar
  //Builder for content
  //Builder for media preview
  //Builder for bottom bar for buttons
  const LMPostComposeScreen({
    super.key,
    //Widget builder functions for customizations
    this.composeDiscardDialogBuilder,
    this.composeAppBarBuilder,
    this.composeContentBuilder,
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

  /// The [SystemUiOVerlayStyle] for the [LMPostComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

  /// The hint text shown to a user while inputting text for post
  final String composeHint;

  final bool enableImages;
  final bool enableDocuments;
  final bool enableVideos;
  final bool enableTagging;
  final bool enableTopics;
  final bool enableLinkPreviews;

  final Function(BuildContext context)? composeDiscardDialogBuilder;
  final Widget Function()? composeAppBarBuilder;
  final Widget Function()? composeContentBuilder;

  @override
  State<LMPostComposeScreen> createState() => _LMPostComposeScreenState();
}

class _LMPostComposeScreenState extends State<LMPostComposeScreen> {
  final User user = LMUserLocalPreference.instance.fetchUserData();
  final LMPostBloc bloc = LMPostBloc.instance;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final CustomPopupMenuController _controllerPopUp =
      CustomPopupMenuController();

  // final List<LMMediaModel>? postMedia;
  // final List<LMTopicViewData>? postTopics;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          widget.composeDiscardDialogBuilder?.call(context) ??
              _showDefaultDiscardDialog(context);
          return Future.value(false);
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: widget.composeSystemOverlayStyle,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  widget.composeAppBarBuilder?.call() ?? _defAppBar(),
                  const SizedBox(height: 18),
                  widget.composeContentBuilder?.call() ?? _defContentInput(),
                ],
              ),
            ),
          ),
        ));
  }

  _showDefaultDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
    return LMAppBar(
      backgroundColor: kWhiteColor,
      height: 56,
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      leading: LMTextButton(
        text: LMTextView(
          text: "Cancel",
          textStyle: TextStyle(color: theme.colorScheme.primary),
        ),
        onTap: Navigator.of(context).pop,
      ),
      title: const LMTextView(
        text: "Create Post",
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: kGrey1Color,
        ),
      ),
      trailing: LMTextButton(
        text: LMTextView(
          text: "Post",
          textStyle: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        width: 48,
        borderRadius: 6,
        backgroundColor: theme.colorScheme.primary,
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
}
