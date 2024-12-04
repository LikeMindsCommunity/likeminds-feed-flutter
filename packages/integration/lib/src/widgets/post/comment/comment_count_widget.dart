// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/config.dart';

class LMFeedCommentCount extends StatefulWidget {
  const LMFeedCommentCount({
    super.key,
    this.settings,
    this.countTextBuilder,
    this.style,
  });
  final LMFeedPostDetailScreenSetting? settings;
  final Widget Function(BuildContext context, LMFeedText textWidget)?
      countTextBuilder;
  final LMFeedCommentCountStyle? style;

  @override
  State<LMFeedCommentCount> createState() => _LMFeedCommentCountState();
}

class _LMFeedCommentCountState extends State<LMFeedCommentCount> {
  int _commentCount = 0;
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance;
  late LMFeedPostDetailScreenSetting settings;
  late Size screenSize;
  late double screenWidth;
  bool isDesktopWeb = false;
  final webConfig = LMFeedCore.config.webConfiguration;

  @override
  void initState() {
    super.initState();
    settings =
        widget.settings ?? LMFeedCore.config.postDetailScreenConfig.setting;
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
                !settings.showCommentCountOnList ||
                state is LMFeedGetCommentLoadingState
            ? const SizedBox.shrink()
            : Container(
                clipBehavior: widget.style?.clipBehavior ?? Clip.hardEdge,
                decoration: widget.style?.decoration ??
                    BoxDecoration(
                        borderRadius: isDesktopWeb
                            ? widget.style?.borderRadius ??
                                BorderRadius.vertical(top: Radius.circular(8.0))
                            : null,
                        color: feedTheme.container),
                margin:
                    widget.style?.margin ?? const EdgeInsets.only(top: 10.0),
                padding: widget.style?.padding ??
                    feedTheme.commentStyle.padding ??
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

class LMFeedCommentCountStyle {
  final BoxDecoration? decoration;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final BorderRadiusGeometry? borderRadius;

  const LMFeedCommentCountStyle({
    this.decoration,
    this.clipBehavior,
    this.margin,
    this.padding,
    this.alignment,
    this.borderRadius,
  });

  factory LMFeedCommentCountStyle.basic() {
    return const LMFeedCommentCountStyle(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
    );
  }

  LMFeedCommentCountStyle copyWith({
    BoxDecoration? decoration,
    Clip? clipBehavior,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
    BorderRadiusGeometry? borderRadius,
  }) {
    return LMFeedCommentCountStyle(
      decoration: decoration ?? this.decoration,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
