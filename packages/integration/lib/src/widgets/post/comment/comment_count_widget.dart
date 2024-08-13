import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCommentCount extends StatefulWidget {
  const LMFeedCommentCount({
    super.key,
    this.config,
    this.countTextBuilder,
  });
  final LMPostDetailScreenConfig? config;
  final Widget Function(BuildContext context, LMFeedText textWidget)?
      countTextBuilder;

  @override
  State<LMFeedCommentCount> createState() => _LMFeedCommentCountState();
}

class _LMFeedCommentCountState extends State<LMFeedCommentCount> {
  int _commentCount = 0;
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance();
  late LMPostDetailScreenConfig config;
  late Size screenSize;
  late double screenWidth;
  bool isDesktopWeb = false;
  final webConfig = LMFeedCore.config.webConfiguration;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return BlocConsumer<LMFeedCommentBloc, LMFeedCommentState>(
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
                !config.showCommentCountOnList ||
                state is LMFeedGetCommentLoadingState
            ? const SizedBox.shrink()
            : Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: isDesktopWeb
                        ? BorderRadius.vertical(top: Radius.circular(8.0))
                        : null,
                    color: feedTheme.container),
                margin: const EdgeInsets.only(top: 10.0),
                padding: feedTheme.commentStyle.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                alignment: Alignment.topLeft,
                child:
                    widget.countTextBuilder?.call(context, _defCountText()) ??
                        _defCountText());
      },
    );
  }

  LMFeedText _defCountText() {
    return LMFeedText(
      text: LMFeedPostUtils.getCommentCountTextWithCount(_commentCount),
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: feedTheme.onContainer,
        ),
      ),
    );
  }
}
