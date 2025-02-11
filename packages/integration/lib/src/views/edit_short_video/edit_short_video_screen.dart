import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedEditShortVideoScreen extends StatefulWidget {
  const LMFeedEditShortVideoScreen({
    super.key,
    required this.postId,
  });
  final String postId;

  @override
  State<LMFeedEditShortVideoScreen> createState() =>
      _LMFeedEditShortVideoScreenState();
}

class _LMFeedEditShortVideoScreenState
    extends State<LMFeedEditShortVideoScreen> {
  LMPostViewData? _postViewData;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _theme = LMFeedCore.theme;
  final List<LMTopicViewData> _selectedTopics = [];
  final _composeBloc = LMFeedComposeBloc.instance;
  final _postBloc = LMFeedPostBloc.instance;
  // Get the post title in first letter capital singular form
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the post title in all small singular form
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);
  final config = LMFeedCore.config.editShortVideoConfig;
  final ValueNotifier<bool> _postValidationNotifier = ValueNotifier(false);
  bool _isPostValidationRequired = true;
  final _screenBuilder = LMFeedCore.config.editShortVideoConfig.builder;

  LMResponse<void> validatePost() {
    String postText = _textController.text;
    postText = postText.trim();

    // Validate the text if required
    if (config.setting.textRequiredToCreatePost && postText.isEmpty) {
      return LMResponse(
        success: false,
        errorMessage: "Can't create a $postTitleSmallCap without caption",
      );
    }

    // Validate the topic selection if required
    if (config.setting.topicRequiredToCreatePost && _selectedTopics.isEmpty) {
      return LMResponse(
        success: false,
        errorMessage: "Can't create a $postTitleSmallCap without topics",
      );
    }

    // return success if all validations pass
    return LMResponse(success: true);
  }

  @override
  void initState() {
    super.initState();
    _postBloc.add(
      LMFeedGetPostEvent(
        postId: widget.postId,
        page: 1,
        pageSize: 10,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _composeBloc.add(LMFeedComposeCloseEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<LMFeedPostBloc, LMFeedPostState>(
      bloc: _postBloc,
      builder: (context, state) {
        if (state is LMFeedGetPostLoadingState) {
          return Scaffold(
            backgroundColor: _theme.container,
            body: Center(child: LMFeedLoader()),
          );
        }
        if (state is LMFeedGetPostSuccessState) {
          _postViewData = state.post;
          _textController.text = _postViewData?.text ?? '';
          _selectedTopics.clear();
          _selectedTopics.addAll(_postViewData?.topics.copy() ?? []);
          _composeBloc.postMedia = _postViewData?.attachments ?? [];
          final videoAttachment = _postViewData?.attachments?.firstWhereOrNull(
            (attachment) {
              return (attachment.attachmentType == LMMediaType.reel) &&
                  attachment.attachmentMeta.url != null &&
                  attachment.attachmentMeta.url!.isNotEmpty;
            },
          );
          return _screenBuilder.scaffold(
            appBar: _screenBuilder.appBarBuilder(
              context,
              _defAppBar(),
              _onPostEdit,
              validatePost,
              _defPostButton(),
              _defCancelButton(),
              _onPostValidationFailed,
            ),
            canPop: false,
            onPopInvoked: (isPop) {
              if (!isPop) {
                _showDefaultDiscardDialog(context);
              }
            },
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (videoAttachment != null)
                      Center(
                        child: _screenBuilder.videoPreviewContainerBuilder(
                          context,
                          _defVideoPreviewContainer(size, videoAttachment),
                          _defVideoPreview(videoAttachment),
                        ),
                      ),
                    _screenBuilder.topicChipContainerBuilder(
                      context,
                      _defTopicsContainer(context),
                      _selectedTopics.copy(),
                      _defSelectTopicsButton(context),
                      _defEditSelectedTopicsButton(context),
                    ),
                    _screenBuilder.textFieldBuilder(
                      context,
                      _defContentTextField(),
                      _textController,
                      _focusNode,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: _theme.container,
          body: Center(
            child: LMFeedText(
              text: 'Failed to load $postTitleSmallCap',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _theme.secondaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Container _defVideoPreviewContainer(
      Size size, LMAttachmentViewData? attachment) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 420,
      width: size.width * 0.7,
      margin: const EdgeInsets.only(bottom: 64),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: _screenBuilder.videoPreviewBuilder(
        context,
        _defVideoPreview(attachment!),
        attachment,
      ),
    );
  }

  LMFeedVideo _defVideoPreview(LMAttachmentViewData attachment) {
    return LMFeedVideo(
      video: attachment,
      postId: _postViewData?.id ?? widget.postId,
    );
  }

  _showDefaultDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DefaultTextStyle(
        style: const TextStyle(),
        child: AlertDialog(
          backgroundColor: _theme.container,
          surfaceTintColor: Colors.transparent,
          title: Text('Discard $postTitleFirstCap?'),
          content: LMFeedText(
            text:
                'Are you sure you want to discard your reel? Any unsaved changes will be lost, and this action cannot be undone.',
            style: LMFeedTextStyle(
              maxLines: 10,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _theme.secondaryColor,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(
            bottom: 24,
            right: 24,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LMFeedButton(
                  text: LMFeedText(
                    text: "Cancel",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: LMFeedCore.theme.secondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                    text: "Discard",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: LMFeedCore.theme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Container _defTopicsContainer(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          for (final topic in _selectedTopics)
            _screenBuilder.topicChipBuilder(
              context,
              _defTopicChip(topic),
            ),
          _selectedTopics.isEmpty
              ? _screenBuilder.selectTopicButtonBuilder(
                  context,
                  _defSelectTopicsButton(context),
                )
              : _screenBuilder.editTopicButtonBuilder(
                  context,
                  _defEditSelectedTopicsButton(context),
                ),
        ],
      ),
    );
  }

  LMFeedTopicChip _defTopicChip(LMTopicViewData topic) {
    return LMFeedTopicChip(
      topic: topic,
      isSelected: true,
      style: LMFeedTopicChipStyle(
        backgroundColor: _theme.primaryColor.withOpacity(0.2),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _theme.primaryColor,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  LMFeedButton _defEditSelectedTopicsButton(BuildContext context) {
    return LMFeedButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedTopicSelectScreen(
              showAllTopicsTile: false,
              onTopicSelected: (topics) {
                _selectedTopics.clear();
                _selectedTopics.addAll(topics.copy());
                setState(() {});
              },
              selectedTopics: _selectedTopics.copy(),
            ),
          ),
        );
      },
      style: LMFeedButtonStyle(
        borderRadius: 4,
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        gap: 0,
        backgroundColor: _theme.primaryColor.withOpacity(0.2),
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.edit,
          style: LMFeedIconStyle(
            size: 16,
            color: _theme.primaryColor,
          ),
        ),
      ),
    );
  }

  LMFeedButton _defSelectTopicsButton(BuildContext context) {
    return LMFeedButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedTopicSelectScreen(
              showAllTopicsTile: false,
              onTopicSelected: (topics) {
                _selectedTopics.clear();
                _selectedTopics.addAll(topics.copy());
                setState(() {});
              },
              selectedTopics: _selectedTopics.copy(),
            ),
          ),
        );
      },
      style: LMFeedButtonStyle(
        borderRadius: 4,
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        margin: EdgeInsets.only(
          right: 8,
        ),
        backgroundColor: _theme.primaryColor.withOpacity(0.2),
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.add,
          style: LMFeedIconStyle(
            size: 16,
            color: _theme.primaryColor,
          ),
        ),
      ),
      text: LMFeedText(
        text: 'Select Topics',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _theme.primaryColor,
          ),
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      leading: _defCancelButton(),
      title: const LMFeedText(
        text: 'Edit Reel',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      trailing: [
        ValueListenableBuilder(
            valueListenable: _postValidationNotifier,
            builder: (context, value, child) {
              return _defPostButton();
            }),
      ],
      style: LMFeedAppBarStyle(
        height: 56,
      ),
    );
  }

  LMFeedButton _defPostButton() {
    return LMFeedButton(
      onTap: _onPostEdit,
      text: LMFeedText(
        text: 'POST',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _postValidationNotifier.value
                ? _theme.primaryColor
                : _theme.onContainer,
          ),
        ),
      ),
    );
  }

  void _onPostValidationFailed(String errorMessage) {
    // Show a snackbar with the error message
    LMFeedCore.showSnackBar(
      context,
      errorMessage,
      LMFeedWidgetSource
          .editShortVideoScreen, // Source of the widget, useful for tracking
    );
  }

  void _onPostEdit() {
    final result = _textController.text.trim();
    final selectedTopics = _selectedTopics;
    final postValidation = validatePost();
    if (!postValidation.success) {
      LMFeedCore.showSnackBar(
        context,
        postValidation.errorMessage ?? "$postTitleFirstCap validation failed",
        LMFeedWidgetSource.editShortVideoScreen,
      );
      return;
    }
    // Add a new post event to the post bloc
    LMFeedPostBloc.instance.add(
      LMFeedEditPostEvent(
        postId: widget.postId,
        postText: result,
        selectedTopics: selectedTopics,
        tempId: _postViewData?.tempId ?? '',
      ),
    );
    // Pop the screen
    Navigator.pop(context);
  }

  // Default "Cancel" button widget creation
  LMFeedButton _defCancelButton() {
    return LMFeedButton(
      // Defining the button's tap behavior
      onTap: () {
        // If a custom discard dialog is provided, show it
        // Otherwise, show the default discard dialog

        _showDefaultDiscardDialog(context);
      },
      // Applying additional style properties
      style: LMFeedButtonStyle(
        gap: 20.0,
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.arrow_back,
          style: LMFeedIconStyle(
            size: 28,
            color: _theme.onContainer,
          ),
        ),
      ),
    );
  }

  LMTaggingAheadTextField _defContentTextField() {
    return LMTaggingAheadTextField(
      isDown: true,
      taggingEnabled: config.setting.enableTagging,
      style: LMTaggingAheadTextFieldStyle(
        minLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: "Write a caption and hashtags...",
          hintStyle: TextStyle(
            overflow: TextOverflow.visible,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _theme.secondaryColor,
          ),
        ),
      ),
      onTagSelected: (tag) {
        // composeBloc.userTags.add(tag);
        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.userTaggedInPost,
            widgetSource: LMFeedWidgetSource.createPostScreen,
            eventProperties: {
              'tagged_user_id': tag.sdkClientInfo?.uuid ?? tag.uuid,
              // 'tagged_user_count': composeBloc.userTags.length.toString(),
            },
          ),
        );
      },
      controller: _textController,
      focusNode: _focusNode,
      onChange: (value) {
        if (_isPostValidationRequired) {
          final postValidation = validatePost();
          _postValidationNotifier.value = postValidation.success;
        }
      },
    );
  }
}
