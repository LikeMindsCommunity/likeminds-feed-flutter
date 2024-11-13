// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_count_widget.dart';
part 'post_detail_screen_configuration.dart';

/// {@template post_detail_screen}
/// A screen that displays a post in detail
/// with comments and likes
/// {@endtemplate}
class LMFeedPostDetailScreen extends StatefulWidget {
  ///{@macro post_detail_screen}
  const LMFeedPostDetailScreen({
    super.key,
    required this.postId,
    this.postBuilder,
    this.appBarBuilder,
    this.commentBuilder,
    this.bottomTextFieldBuilder,
    this.commentSeparatorBuilder,
    this.onPostTap,
    this.onLikeClick,
    this.onCommentClick,
    this.openKeyboard = false,
    this.config,
    this.commentListBuilder,
  });
  // Required variables
  final String postId;

  final Function()? onPostTap;
  final Function()? onLikeClick;
  final Function()? onCommentClick;

  // Optional variables
  // In case the below props are not provided,
  // the default in each case will be used
  /// {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;

  /// {@macro post_appbar_builder}
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  /// {@macro lm_feed_comment_list_builder}
  final LMFeedCommentListBuilder? commentListBuilder;

  final Widget Function(
    BuildContext,
    LMFeedBottomTextField,
    TextEditingController,
    FocusNode,
  )? bottomTextFieldBuilder;

  final Widget Function(BuildContext)? commentSeparatorBuilder;

  final bool openKeyboard;

  final LMPostDetailScreenConfig? config;

  LMFeedPostDetailScreen copyWith({
    String? postId,
    Function()? onPostTap,
    Function()? onLikeClick,
    Function()? onCommentClick,
    LMFeedPostWidgetBuilder? postBuilder,
    LMFeedPostAppBarBuilder? appBarBuilder,
    LMFeedPostCommentBuilder? commentBuilder,
    LMFeedCommentListBuilder? commentListBuilder,
    Widget Function(BuildContext, LMFeedBottomTextField, TextEditingController,
            FocusNode)?
        bottomTextFieldBuilder,
    Widget Function(BuildContext)? commentSeparatorBuilder,
    bool? openKeyboard,
    LMPostDetailScreenConfig? config,
  }) {
    return LMFeedPostDetailScreen(
      postId: postId ?? this.postId,
      onPostTap: onPostTap ?? this.onPostTap,
      onLikeClick: onLikeClick ?? this.onLikeClick,
      onCommentClick: onCommentClick ?? this.onCommentClick,
      postBuilder: postBuilder ?? this.postBuilder,
      appBarBuilder: appBarBuilder ?? this.appBarBuilder,
      commentBuilder: commentBuilder ?? this.commentBuilder,
      commentListBuilder: commentListBuilder ?? this.commentListBuilder,
      bottomTextFieldBuilder:
          bottomTextFieldBuilder ?? this.bottomTextFieldBuilder,
      commentSeparatorBuilder:
          commentSeparatorBuilder ?? this.commentSeparatorBuilder,
      openKeyboard: openKeyboard ?? this.openKeyboard,
      config: config ?? this.config,
    );
  }

  @override
  State<LMFeedPostDetailScreen> createState() => _LMFeedPostDetailScreenState();
}

class _LMFeedPostDetailScreenState extends State<LMFeedPostDetailScreen> {
  late Size screenSize;
  late bool isDesktopWeb;

  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  final LMFeedPostBloc postBloc = LMFeedPostBloc.instance;
  final LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;
  String? commentIdReplyId;
  bool replyShown = false;
  LMFeedThemeData feedTheme = LMFeedCore.theme;

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  bool right = true;
  List<LMUserTagViewData> userTags = [];
  LMPostDetailScreenConfig? config;

  bool isAndroid = LMFeedPlatform.instance.isAndroid();
  bool isWeb = LMFeedPlatform.instance.isWeb();
  double? screenWidth;
  final _commentBloc = LMFeedCommentBloc.instance;
  final ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  LMPostViewData? postData;
  final FocusNode _commentFocusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    right = LMFeedUserUtils.checkCommentRights();
    if (widget.openKeyboard && right) {
      openOnScreenKeyboard();
    }
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
  }

  @override
  void didUpdateWidget(covariant LMFeedPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {}
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          _commentBloc.add(LMFeedCommentRefreshEvent());
          return Future.value();
        },
        color: feedTheme.primaryColor,
        backgroundColor: feedTheme.container,
        child: BlocListener(
          listener: (context, state) {
            if (state is LMFeedPostUpdateState) {
              if (state.postId == widget.postId) {
                if (state.actionType == LMFeedPostActionType.pollSubmit) {
                  postData = LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? postData!,
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  ).copyWith();
                } else {
                  LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? postData!,
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  );
                }
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
            } else if (state is LMFeedEditPostUploadedState) {
              LMPostViewData editedPost = state.postData.copyWith();
              postData = editedPost;
              rebuildPostWidget.value = !rebuildPostWidget.value;
            } else if (state is LMFeedPostDeletionErrorState) {
              LMFeedCore.showSnackBar(
                context,
                state.message,
                _widgetSource,
              );
            }
          },
          bloc: postBloc,
          child: ValueListenableBuilder(
              valueListenable: rebuildPostWidget,
              builder: (context, _, __) {
                return _widgetBuilder.scaffold(
                  source: _widgetSource,
                  resizeToAvoidBottomInset: true,
                  backgroundColor: feedTheme.backgroundColor,
                  bottomNavigationBar: widget.bottomTextFieldBuilder?.call(
                        context,
                        _defBottomTextFiled(),
                        _commentController,
                        _commentFocusNode,
                      ) ??
                      _widgetBuilder.bottomTextFieldBuilder.call(
                        context,
                        _defBottomTextFiled(),
                        _commentController,
                        _commentFocusNode,
                        _widgetSource,
                      ),
                  appBar: widget.appBarBuilder?.call(context, defAppBar()) ??
                      defAppBar(),
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        width: screenWidth,
                        child: CustomScrollView(
                          slivers: [
                            if (isDesktopWeb)
                              SliverPadding(
                                  padding: EdgeInsets.only(top: 20.0)),
                            SliverToBoxAdapter(
                              child: BlocBuilder<LMFeedCommentBloc,
                                  LMFeedCommentState>(
                                bloc: _commentBloc,
                                buildWhen: (previous, current) {
                                  if (current is LMFeedGetCommentSuccessState) {
                                    return true;
                                  }
                                  if (current is LMFeedGetCommentErrorState) {
                                    return true;
                                  }
                                  if (current is LMFeedGetCommentLoadingState) {
                                    return true;
                                  }
                                  return false;
                                },
                                builder: (context, state) {
                                  if (state is LMFeedGetCommentLoadingState) {
                                    return SizedBox.shrink();
                                  }
                                  if (state is LMFeedGetCommentSuccessState) {
                                    postData = state.post;
                                    LMFeedPostWidget postWidget =
                                        LMFeedDefaultWidgets.instance
                                            .defPostWidget(
                                      context,
                                      feedTheme,
                                      postData!,
                                      _widgetSource,
                                    );
                                    return widget.postBuilder?.call(
                                            context, postWidget, postData!) ??
                                        _widgetBuilder.postWidgetBuilder.call(
                                            context, postWidget, postData!,
                                            source: _widgetSource);
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                            ),
                            _defCommentsCount(),
                            widget.commentListBuilder
                                    ?.call(context, _defCommentList()) ??
                                _defCommentList(),
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 100,
                              ),
                            ),
                          ],
                        )),
                  ),
                );
              }),
        ),
      ),
    );
  }

  LMFeedCommentList _defCommentList() {
    return LMFeedCommentList(
      postId: widget.postId,
      commentBuilder: widget.commentBuilder,
      commentSeparatorBuilder: widget.commentSeparatorBuilder,
      widgetSource: _widgetSource,
    );
  }

  LMFeedBottomTextField _defBottomTextFiled() {
    return LMFeedBottomTextField(
      postId: widget.postId,
      focusNode: _commentFocusNode,
      controller: _commentController,
      style: LMFeedBottomTextFieldStyle.basic(
        containerColor: feedTheme.container,
      ),
    );
  }

  SliverToBoxAdapter _defCommentsCount() {
    return SliverToBoxAdapter(child: LMFeedCommentCount());
  }

  LMFeedAppBar defAppBar() {
    return LMFeedAppBar(
      leading: LMFeedButton(
        style: LMFeedButtonStyle(
          gap: 20.0,
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: isAndroid ? Icons.arrow_back : CupertinoIcons.chevron_back,
            style: LMFeedIconStyle(
              size: 28,
              color: feedTheme.onContainer,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedText(
            text: postTitleFirstCap,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: feedTheme.onContainer,
              ),
            ),
          ),
          BlocConsumer<LMFeedCommentBloc, LMFeedCommentState>(
            bloc: _commentBloc,
            listener: (context, state) {
              if (state is LMFeedGetCommentSuccessState) {
                _commentCount = state.post.commentCount;
              } else if (state is LMFeedAddCommentSuccessState) {
                if (state.comment.tempId == state.comment.id) {
                  _commentCount++;
                }
              } else if (state is LMFeedAddCommentErrorState) {
                _commentCount--;
              } else if (state is LMFeedDeleteCommentSuccessState) {
                _commentCount--;
              } else if (state is LMFeedDeleteCommentErrorState) {
                _commentCount++;
              }
            },
            buildWhen: (previous, current) =>
                current is LMFeedGetCommentSuccessState ||
                current is LMFeedGetCommentLoadingState ||
                current is LMFeedAddCommentSuccessState ||
                current is LMFeedDeleteCommentSuccessState,
            builder: (context, state) {
              return _commentCount == 0 ||
                      !config!.showCommentCountOnList ||
                      state is LMFeedGetCommentLoadingState
                  ? const SizedBox.shrink()
                  : LMFeedText(
                      text: LMFeedPostUtils.getCommentCountTextWithCount(
                              _commentCount)
                          .toLowerCase(),
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: feedTheme.primaryColor,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
      trailing: const [SizedBox(width: 36)],
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 61,
      ),
    );
  }

  void closeOnScreenKeyboard() {
    if (_commentFocusNode.hasFocus) {
      _commentFocusNode.unfocus();
    }
  }

  void openOnScreenKeyboard() {
    if (_commentFocusNode.canRequestFocus) {
      _commentFocusNode.requestFocus();
    }
  }
}
