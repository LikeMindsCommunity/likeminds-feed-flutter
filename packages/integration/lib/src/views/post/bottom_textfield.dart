import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/config.dart';

class LMFeedBottomTextField extends StatefulWidget {
  const LMFeedBottomTextField({
    super.key,
    required this.postId,
    this.controller,
    this.focusNode,
    this.style,
    this.profilePictureBuilder,
    this.createButtonBuilder,
    this.bannerBuilder,
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

  /// [bannerBuilder] is the builder for the banner shown above the text field.
  /// The banner is shown when the user is editing a comment or a reply.
  /// If not provided, the default banner will be used.
  final Widget Function(BuildContext, LMFeedBottomTextFieldBanner)?
      bannerBuilder;

  /// [copyWith] is used to create a new instance of [LMFeedBottomTextField]
  /// with the provided values.
  /// If a value is not provided, the value from the current instance will be used.
  LMFeedBottomTextField copyWith(
      {String? postId,
      FocusNode? focusNode,
      TextEditingController? controller,
      LMFeedBottomTextFieldStyle? style,
      LMFeedProfilePictureBuilder? profilePictureBuilder,
      LMFeedButtonBuilder? createButtonBuilder,
      Widget Function(BuildContext, LMFeedBottomTextFieldBanner)?
          bannerBuilder}) {
    return LMFeedBottomTextField(
      postId: postId ?? this.postId,
      focusNode: focusNode ?? this.focusNode,
      controller: controller ?? this.controller,
      style: style ?? this.style,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      createButtonBuilder: createButtonBuilder ?? this.createButtonBuilder,
      bannerBuilder: bannerBuilder ?? this.bannerBuilder,
    );
  }

  @override
  State<LMFeedBottomTextField> createState() => _LMFeedBottomTextFieldState();
}

class _LMFeedBottomTextFieldState extends State<LMFeedBottomTextField> {
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  late Size screenSize;
  double? screenWidth;
  LMFeedWebConfiguration webConfig = LMFeedCore.config.webConfiguration;
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
  LMFeedPostDetailScreenSetting? settings =
      LMFeedCore.config.postDetailScreenConfig.setting;
  late LMFeedBottomTextFieldStyle? _style;
  final bool isGuestUser = LMFeedUserUtils.isGuestUser();

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
                        ? widget.bannerBuilder?.call(
                              context,
                              _defTextFieldBanner(
                                isEditing,
                                isReplyEditing,
                                isReply,
                              ),
                            ) ??
                            _defTextFieldBanner(
                              isEditing,
                              isReplyEditing,
                              isReply,
                            )
                        : const SizedBox.shrink(),
                    LMTaggingAheadTextField(
                      isDown: false,
                      taggingEnabled: LMFeedCore
                          .config.composeScreenConfig.setting.enableTagging,
                      enabled: !isGuestUser && right,
                      style: LMTaggingAheadTextFieldStyle(
                        maxLines: _style?.maxLines,
                        textStyle: _style?.textStyle ??
                            TextStyle(fontWeight: FontWeight.w400),
                        minLines: _style?.minLines ?? 1,
                        decoration: _style?.inputDecoration
                                ?.call(_defInputDecoration()) ??
                            _defInputDecoration(),
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      ),
                      onTagSelected: (tag) {
                        _commentBloc.userTags.add(tag);
                      },
                      onSubmitted: (_) => handleCreateCommentButtonAction(),
                      controller: _commentController,
                      onChange: (String p0) {},
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
      prefixIcon: _style?.showPrefixIcon ?? true ? _defProfilePicture() : null,
      suffixIcon: _style?.showSuffixIcon ?? true ? _defCreateButton() : null,
      fillColor: feedTheme.primaryColor.withOpacity(0.04),
      filled: true,
      enabled: right,
      hintText: right
          ? settings?.commentTextFieldHint ??
              'Write a $commentTitleSmallCapSingular'
          : "You do not have permission to create a $commentTitleSmallCapSingular.",
    );
  }

  LMFeedButton? _defCreateButton() {
    final bool isGuestUser = LMFeedUserUtils.isGuestUser();
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
                  color: isGuestUser
                      ? feedTheme.inActiveColor
                      : feedTheme.primaryColor,
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

  LMFeedBottomTextFieldBanner _defTextFieldBanner(
    bool isEditing,
    bool isReplyEditing,
    bool isReplying,
  ) {
    return LMFeedBottomTextFieldBanner(
      isEditing: isEditing,
      isReplyEditing: isReplyEditing,
      isReplying: isReplying,
    );
  }

  void _handleListener(context, state) {
    if (state is LMFeedEditingCommentState) {
      openOnScreenKeyboard();
      final String commentText =
          LMFeedTaggingHelper.convertRouteToTag(state.oldComment.text);
      _commentController.text = commentText;
    } else if (state is LMFeedEditingCommentCancelState) {
      _commentController.clear();
      closeOnScreenKeyboard();
    } else if (state is LMFeedReplyingCommentState) {
      openOnScreenKeyboard();
    } else if (state is LMFeedReplyCancelState) {
      _commentController.clear();

      closeOnScreenKeyboard();
    } else if (state is LMFeedEditingReplyState) {
      openOnScreenKeyboard();
      final String replyText =
          LMFeedTaggingHelper.convertRouteToTag(state.replyText);
      _commentController.text = replyText;
    }
    // Do not rebuild the text field if the state is not related to the text field.
    if (state is LMFeedCloseReplyState ||
        state is LMFeedGetReplyCommentSuccessState ||
        state is LMFeedGetReplyCommentLoadingState ||
        state is LMFeedGetReplyCommentPaginationLoadingState) {
      return;
    }
    _rebuildCommentTextField.value = !_rebuildCommentTextField.value;
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
  int maxLines;
  int minLines;
  TextStyle? textStyle;
  final InputDecoration? Function(InputDecoration?)? inputDecoration;
  bool? showPrefixIcon;
  bool? showSuffixIcon;

  LMFeedBottomTextFieldStyle({
    this.constraints,
    this.boxDecoration,
    this.padding,
    this.margin,
    this.textStyle,
    this.inputDecoration,
    this.showPrefixIcon,
    this.showSuffixIcon,
    this.maxLines = 5,
    this.minLines = 1,
  });

  LMFeedBottomTextFieldStyle copyWith({
    BoxConstraints? constraints,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? showPrefixIcon,
    bool? showSuffixIcon,
    TextStyle? textStyle,
    InputDecoration? Function(InputDecoration?)? inputDecoration,
    int? maxLines,
    int? minLines,
  }) {
    return LMFeedBottomTextFieldStyle(
      constraints: constraints ?? this.constraints,
      boxDecoration: decoration ?? this.boxDecoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      showPrefixIcon: showPrefixIcon ?? this.showPrefixIcon,
      showSuffixIcon: showSuffixIcon ?? this.showSuffixIcon,
      textStyle: textStyle ?? this.textStyle,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
    );
  }

  factory LMFeedBottomTextFieldStyle.basic({
    Color? containerColor,
  }) {
    return LMFeedBottomTextFieldStyle(
      padding: const EdgeInsets.symmetric(
        horizontal: LikeMindsTheme.kPaddingSmall,
        vertical: LikeMindsTheme.kPaddingMedium,
      ),
      boxDecoration: BoxDecoration(
        color: containerColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      showPrefixIcon: true,
      showSuffixIcon: true,
    );
  }
}
