import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

/// {@template post_widget}
/// A widget that displays a post on the feed.
/// Provide a header, footer, menu, media
/// and content instance to customize the post.
/// {@endtemplate}
///

class LMFeedPostWidget extends StatefulWidget {
  ///{@macro post_widget}
  const LMFeedPostWidget({
    super.key,
    required this.post,
    required this.user,
    this.onPostTap,
    required this.isFeed,
    this.onTagTap,
    required this.topics,
    this.childrenSpacing,
    this.header,
    this.footer,
    this.menu,
    this.content,
    this.media,
    this.topicWidget,
    this.headerBuilder,
    this.contentBuilder,
    this.topicBuilder,
    this.menuBuilder,
    this.mediaBuilder,
    this.footerBuilder,
    this.style,
    this.onMediaTap,
    this.activityHeader,
    this.disposeVideoPlayerOnInActive,
  });

  final LMFeedPostStyle? style;

  final LMFeedPostHeaderBuilder? headerBuilder;
  final LMFeedPostContentBuilder? contentBuilder;
  final LMFeedPostTopicBuilder? topicBuilder;
  final LMFeedPostMenuBuilder? menuBuilder;
  final LMFeedPostMediaBuilder? mediaBuilder;
  final LMFeedPostFooterBuilder? footerBuilder;

  final LMFeedPostHeader? header;
  final LMFeedPostFooter? footer;
  final LMFeedMenu? menu;
  final LMFeedPostMedia? media;
  final LMFeedPostContent? content;
  final LMFeedPostTopic? topicWidget;
  final Widget? activityHeader;

  // Required variables
  final LMPostViewData post;
  final LMUserViewData user;
  final List<LMTopicViewData> topics;
  final bool isFeed;
  final LMFeedOnPostTap? onPostTap;
  final Function(String)? onTagTap;
  final double? childrenSpacing;
  final VoidCallback? onMediaTap;

  final VoidCallback? disposeVideoPlayerOnInActive;

  @override
  State<LMFeedPostWidget> createState() => _LMPostWidgetState();

  LMFeedPostWidget copyWith({
    LMFeedPostHeaderBuilder? headerBuilder,
    LMFeedPostFooterBuilder? footerBuilder,
    LMFeedPostTopicBuilder? topicBuilder,
    LMFeedPostMenuBuilder? menuBuilder,
    LMFeedPostMediaBuilder? mediaBuilder,
    LMFeedPostContentBuilder? contentBuilder,
    List<BoxShadow>? boxShadow,
    BorderRadiusGeometry? borderRadius,
    LMPostViewData? post,
    LMUserViewData? user,
    List<LMTopicViewData>? topics,
    bool? isFeed,
    LMFeedOnPostTap? onPostTap,
    Function(String)? onTagTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? childrenSpacing,
    LMFeedPostContent? content,
    LMFeedPostFooter? footer,
    LMFeedPostHeader? header,
    LMFeedPostMedia? media,
    LMFeedMenu? menu,
    LMFeedPostTopic? topicWidget,
    LMFeedPostStyle? style,
    VoidCallback? onMediaTap,
    Widget? activityHeader,
  }) {
    return LMFeedPostWidget(
      post: post ?? this.post,
      user: user ?? this.user,
      topics: topics ?? this.topics,
      isFeed: isFeed ?? this.isFeed,
      onPostTap: onPostTap ?? this.onPostTap,
      onTagTap: onTagTap ?? this.onTagTap,
      childrenSpacing: childrenSpacing ?? this.childrenSpacing,
      content: content ?? this.content,
      footer: footer ?? this.footer,
      header: header ?? this.header,
      media: media ?? this.media,
      menu: menu ?? this.menu,
      topicWidget: topicWidget ?? this.topicWidget,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      contentBuilder: contentBuilder ?? this.contentBuilder,
      topicBuilder: topicBuilder ?? this.topicBuilder,
      menuBuilder: menuBuilder ?? this.menuBuilder,
      mediaBuilder: mediaBuilder ?? this.mediaBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      style: style ?? this.style,
      onMediaTap: onMediaTap ?? this.onMediaTap,
      activityHeader: activityHeader ?? this.activityHeader,
    );
  }
}

class _LMPostWidgetState extends State<LMFeedPostWidget> {
  int postLikes = 0;
  int comments = 0;
  bool? isLiked;
  bool? isPinned;
  ValueNotifier<bool> rebuildLikeWidget = ValueNotifier(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  LMFeedThemeData lmFeedThemeData = LMFeedTheme.instance.theme;

  LMFeedPostStyle? style;

  @override
  void dispose() {
    widget.disposeVideoPlayerOnInActive?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    style = widget.style ?? LMFeedTheme.instance.theme.postStyle;
    return GestureDetector(
      onTap: () {
        widget.onPostTap?.call(context, widget.post);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          color: style?.backgroundColor ?? lmFeedThemeData.container,
          borderRadius: style?.borderRadius,
          boxShadow: style?.boxShadow,
          border: style?.border,
        ),
        padding: style?.padding,
        margin: style?.margin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.activityHeader != null) widget.activityHeader!,
            widget.headerBuilder
                    ?.call(context, _defPostHeader(), widget.post) ??
                _defPostHeader(),
            widget.post.topics.isEmpty
                ? const SizedBox.shrink()
                : widget.topicBuilder
                        ?.call(context, _defTopicWidget(), widget.post) ??
                    _defTopicWidget(),
            widget.contentBuilder
                    ?.call(context, _defContentWidget(), widget.post) ??
                _defContentWidget(),
            widget.post.attachments != null &&
                    widget.post.attachments!.isNotEmpty
                ? widget.mediaBuilder
                        ?.call(context, _defPostMedia(), widget.post) ??
                    _defPostMedia()
                : const SizedBox.shrink(),
            widget.footerBuilder
                    ?.call(context, _defFooterWidget(), widget.post) ??
                _defFooterWidget(),
          ],
        ),
      ),
    );
  }

  LMFeedPostTopic _defTopicWidget() {
    return widget.topicWidget ??
        LMFeedPostTopic(
          topics: widget.topics,
          post: widget.post,
        );
  }

  LMFeedPostContent _defContentWidget() {
    return widget.content ??
        LMFeedPostContent(
          onTagTap: widget.onTagTap,
          text: widget.post.text,
          heading: widget.post.heading,
        );
  }

  LMFeedPostFooter _defFooterWidget() {
    return widget.footer ?? LMFeedPostFooter();
  }

  LMFeedPostHeader _defPostHeader() {
    return widget.header ??
        LMFeedPostHeader(
          user: widget.user,
          isFeed: widget.isFeed,
          postViewData: widget.post,
          menu: widget.menu,
        );
  }

  LMFeedPostMedia _defPostMedia() {
    return widget.media ??
        LMFeedPostMedia(
          postId: widget.post.id,
          attachments: widget.post.attachments!,
          onMediaTap: widget.onMediaTap,
        );
  }
}

class LMFeedPostStyle {
  // Styling variables
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Color? backgroundColor;

  LMFeedPostStyle({
    this.boxShadow,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.backgroundColor,
  });

  LMFeedPostStyle copyWith({
    List<BoxShadow>? boxShadow,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    LMFeedPostContentStyle? contentStyle,
    LMFeedPostHeaderStyle? headerStyle,
    LMFeedPostFooterStyle? footerStyle,
    LMFeedPostTopicStyle? topicStyle,
    LMFeedPostMediaStyle? mediaStyle,
    BoxBorder? border,
    Color? backgroundColor,
    LMFeedPostLikesListViewType? likesListType,
    LMFeedPostDeleteViewType? deleteSheetType,
  }) {
    return LMFeedPostStyle(
      boxShadow: boxShadow ?? this.boxShadow,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      border: border ?? this.border,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  factory LMFeedPostStyle.basic() => LMFeedPostStyle(
        boxShadow: [
          const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
        ],
        margin: const EdgeInsets.only(bottom: 12.0),
      );
}
