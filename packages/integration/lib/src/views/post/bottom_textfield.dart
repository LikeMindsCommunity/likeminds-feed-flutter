import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedBottomTextField extends StatefulWidget {
  const LMFeedBottomTextField({
    super.key,
    required this.postId,
    this.controller,
    this.focusNode,
    this.style,
    this.profilePictureBuilder,
    this.createButtonBuilder,
  });

  /// [postId] is the id of the post for which the comment is to be added.
  final String postId;

  /// [focusNode] is the focus node for the text field.
  /// If not provided, a new focus node will be created,
  /// and used for the text field internally.
  final FocusNode? focusNode;

  /// [controller] is the Text Editing Controller for the text field.
  /// If not provided, a new controller will be created,
  /// and used for the text field internally.
  final TextEditingController? controller;

  /// [style] is the style of the bottom text field.
  final LMFeedBottomTextFieldStyle? style;

  /// [profilePictureBuilder] is the builder for the profile picture.
  /// If not provided, the default profile picture will be used.
  /// If [prefixIcon] is provided in the [InputDecoration] of [style], the [profilePictureBuilder]
  /// will not be used.
  final LMFeedProfilePictureBuilder? profilePictureBuilder;

  /// [createButtonBuilder] is the builder for the create button.
  /// If not provided, the default create button will be used.
  /// If [suffixIcon] is provided in the [InputDecoration] of [style], the [createButtonBuilder]
  /// will not be used.
  final LMFeedButtonBuilder? createButtonBuilder;

  /// [copyWith] is used to create a new instance of [LMFeedBottomTextField]
  /// with the provided values.
  /// If a value is not provided, the value from the current instance will be used.
  LMFeedBottomTextField copyWith({
    String? postId,
    FocusNode? focusNode,
    TextEditingController? controller,
    LMFeedBottomTextFieldStyle? style,
    LMFeedProfilePictureBuilder? profilePictureBuilder,
    LMFeedButtonBuilder? createButtonBuilder,
  }) {
    return LMFeedBottomTextField(
      postId: postId ?? this.postId,
      focusNode: focusNode ?? this.focusNode,
      controller: controller ?? this.controller,
      style: style ?? this.style,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      createButtonBuilder: createButtonBuilder ?? this.createButtonBuilder,
    );
  }

  @override
  State<LMFeedBottomTextField> createState() => _LMFeedBottomTextFieldState();
}

class _LMFeedBottomTextFieldState extends State<LMFeedBottomTextField> {
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  late Size screenSize;
  double? screenWidth;
  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  late bool isDesktopWeb;
  late final TextEditingController _commentController;
  late final FocusNode _commentFocusNode;
  bool right = LMFeedUserUtils.checkCommentRights();
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance;
  final ValueNotifier<bool> _rebuildCommentTextField = ValueNotifier(false);
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  final LMUserViewData currentUser =
      LMFeedLocalPreference.instance.fetchUserData()!;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  LMPostDetailScreenConfig? config = LMFeedCore.config.postDetailConfig;
  late final LMFeedBottomTextFieldStyle? _style;

  @override
  void initState() {
    super.initState();
    _commentFocusNode = widget.focusNode ?? FocusNode();
    _commentController = widget.controller ?? TextEditingController();
    // clear user tags list when the widget is initialized
    // to avoid any previous tags being present
    _commentBloc.userTags.clear();
    _style = widget.style;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    screenWidth = min(webConfig.maxWidth, screenSize.width);
    if (screenSize.width > webConfig.maxWidth && kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          _style?.constraints ?? BoxConstraints(maxWidth: screenWidth!),
      decoration: _style?.boxDecoration ??
          BoxDecoration(
            color: feedTheme.container,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
      margin: _style?.margin,
      padding: _style?.padding ??
          const EdgeInsets.symmetric(
            horizontal: LikeMindsTheme.kPaddingSmall,
            vertical: LikeMindsTheme.kPaddingMedium,
          ),
      child: SafeArea(
        top: false,
        child: BlocListener<LMFeedCommentBloc, LMFeedCommentState>(
          listener: _handleListener,
          bloc: _commentBloc,
          child: ValueListenableBuilder(
              valueListenable: _rebuildCommentTextField,
              builder: (context, _, __) {
                final LMFeedCommentState state = _commentBloc.state;
                final bool isEditing = (state is LMFeedEditingCommentState);
                final bool isReply = (state is LMFeedReplyingCommentState);
                final bool isReplyEditing = (state is LMFeedEditingReplyState);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isEditing || isReply || isReplyEditing
                        ? _defTextFieldBanner(isEditing, isReplyEditing, state)
                        : const SizedBox.shrink(),
                    LMTaggingAheadTextField(
                      isDown: false,
                      enabled: LMFeedCore.config.composeConfig.enableTagging,
                      maxLines: 5,
                      onTagSelected: (tag) {
                        _commentBloc.userTags.add(tag);
                      },
                      onSubmitted: (_) => handleCreateCommentButtonAction(),
                      controller: _commentController,
                      decoration: _style?.inputDecoration
                              ?.call(_defInputDecoration()) ??
                          _defInputDecoration(),
                      onChange: (String p0) {},
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      focusNode: _commentFocusNode,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  InputDecoration? _defInputDecoration() {
    return feedTheme.textFieldStyle.decoration?.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 6.0,
      ),
      prefixIcon: _defProfilePicture(),
      suffixIcon: _defCreateButton(),
      fillColor: feedTheme.primaryColor.withOpacity(0.04),
      filled: true,
      enabled: right,
      hintText: right
          ? config?.commentTextFieldHint ??
              'Write a $commentTitleSmallCapSingular'
          : "You do not have permission to create a $commentTitleSmallCapSingular.",
    );
  }

  LMFeedButton? _defCreateButton() {
    return !right
        ? null
        : LMFeedButton(
            style: const LMFeedButtonStyle(
              height: 18,
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            text: LMFeedText(
              text: "Create",
              style: LMFeedTextStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: feedTheme
                          .textFieldStyle.decoration?.hintStyle?.fontSize ??
                      13,
                  color: feedTheme.primaryColor,
                ),
              ),
            ),
            onTap: () => handleCreateCommentButtonAction(),
          );
  }

  LMFeedProfilePicture _defProfilePicture() {
    return LMFeedProfilePicture(
      fallbackText: currentUser.name,
      imageUrl: currentUser.imageUrl,
      style: LMFeedProfilePictureStyle.basic().copyWith(
        backgroundColor: feedTheme.primaryColor,
        size: 24,
        margin: const EdgeInsets.all(6),
        fallbackTextStyle:
            LMFeedProfilePictureStyle.basic().fallbackTextStyle?.copyWith(
                  textStyle: LMFeedProfilePictureStyle.basic()
                      .fallbackTextStyle
                      ?.textStyle
                      ?.copyWith(
                        fontSize: 14,
                      ),
                ),
      ),
      onTap: () {
        LMFeedCore.instance.lmFeedClient
            .routeToProfile(currentUser.sdkClientInfo.uuid);
      },
    );
  }

  Container _defTextFieldBanner(
      bool isEditing, bool isReplyEditing, LMFeedCommentState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          LMFeedText(
            text: isEditing
                ? "Editing ${'$commentTitleSmallCapSingular'} "
                : isReplyEditing
                    ? "Editing reply"
                    : "Replying to ",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: feedTheme.onContainer,
              ),
            ),
          ),
          isEditing || isReplyEditing
              ? const SizedBox()
              : LMFeedText(
                  text: (state as LMFeedReplyingCommentState).userName,
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          const Spacer(),
          LMFeedButton(
            onTap: () {
              isEditing
                  ? _commentBloc.add(LMFeedEditCommentCancelEvent())
                  : _commentBloc.add(LMFeedReplyCancelEvent());
            },
            style: const LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.icon,
                icon: Icons.close,
                style: LMFeedIconStyle(
                  color: LikeMindsTheme.greyColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleListener(context, state) {
    if (state is LMFeedEditingCommentState) {
      openOnScreenKeyboard();
      final String commentText =
          LMFeedTaggingHelper.convertRouteToTag(state.oldComment.text);
      _commentController.text = commentText;
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
    } else if (state is LMFeedEditingCommentCancelState) {
      _commentController.clear();
      closeOnScreenKeyboard();
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
    } else if (state is LMFeedReplyingCommentState) {
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
      openOnScreenKeyboard();
    } else if (state is LMFeedReplyCancelState) {
      _commentController.clear();
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
      closeOnScreenKeyboard();
    } else if (state is LMFeedEditingReplyState) {
      openOnScreenKeyboard();
      final String replyText =
          LMFeedTaggingHelper.convertRouteToTag(state.replyText);
      _commentController.text = replyText;
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
    } else if (state is LMFeedEditReplyCancelEvent) {
      _commentController.clear();
      closeOnScreenKeyboard();
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
    } else {
      _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
    }
  }

  void handleCreateCommentButtonAction() {
    _commentBloc.add(LMFeedSubmitCommentEvent(
      context: context,
      commentController: _commentController,
      focusNode: _commentFocusNode,
      widgetSource: _widgetSource,
      postId: widget.postId,
    ));
    return;
  }

  void closeOnScreenKeyboard() {
    if (_commentFocusNode.hasFocus) {
      _commentFocusNode.unfocus();
    }
  }

  void openOnScreenKeyboard() {
    if (_commentFocusNode.canRequestFocus) {
      _commentFocusNode.requestFocus();
      if (_commentController.text.isNotEmpty) {
        _commentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _commentController.text.length));
      }
    }
  }
}

class LMFeedBottomTextFieldStyle {
  BoxConstraints? constraints;
  BoxDecoration? boxDecoration;
  EdgeInsets? padding;
  EdgeInsets? margin;
  InputDecoration Function(InputDecoration?)? inputDecoration;

  LMFeedBottomTextFieldStyle({
    this.constraints,
    this.boxDecoration,
    this.padding,
    this.margin,
    this.inputDecoration,
  });

  LMFeedBottomTextFieldStyle copyWith({
    BoxConstraints? constraints,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    InputDecoration Function(InputDecoration?)? inputDecoration,
  }) {
    return LMFeedBottomTextFieldStyle(
      constraints: constraints ?? this.constraints,
      boxDecoration: decoration ?? this.boxDecoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      inputDecoration: inputDecoration ?? this.inputDecoration,
    );
  }

  LMFeedBottomTextFieldStyle basic(
    Color containerColor,
  ) {
    return LMFeedBottomTextFieldStyle(
        boxDecoration: BoxDecoration(
      color: containerColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ));
  }
}
