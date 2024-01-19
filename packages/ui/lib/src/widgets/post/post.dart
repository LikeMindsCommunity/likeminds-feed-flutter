import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    this.onLikeTap,
    this.onPinTap,
    this.onSaveTap,
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

  // Required variables
  final LMPostViewData post;
  final LMUserViewData user;
  final Map<String, LMTopicViewData> topics;
  final bool isFeed;
  final LMFeedOnPostTap? onPostTap;
  final Function(String)? onTagTap;
  final double? childrenSpacing;

  final Function(bool isLiked)? onLikeTap;
  final Function(bool isPinned)? onPinTap;
  final Function(bool isSaved)? onSaveTap;

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
    Map<String, LMTopicViewData>? topics,
    bool? isFeed,
    LMFeedOnPostTap? onPostTap,
    Function(String)? onTagTap,
    Function(bool isLiked)? onLikeTap,
    Function(bool isPinned)? onPinTap,
    Function(bool isSaved)? onSaveTap,
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
  }) {
    return LMFeedPostWidget(
      post: post ?? this.post,
      user: user ?? this.user,
      topics: topics ?? this.topics,
      isFeed: isFeed ?? this.isFeed,
      onPostTap: onPostTap ?? this.onPostTap,
      onTagTap: onTagTap ?? this.onTagTap,
      onLikeTap: onLikeTap ?? this.onLikeTap,
      onPinTap: onPinTap ?? this.onPinTap,
      onSaveTap: onSaveTap ?? this.onSaveTap,
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

  LMFeedPostStyle? style;
  LMFeedPostHeader? _postHeader;
  LMFeedPostFooter? _postFooter;
  LMFeedPostContent? _postContent;
  LMFeedPostMedia? _postMedia;
  LMFeedPostTopic? _postTopic;
  LMFeedMenu? _postMenu;

  @override
  void initState() {
    super.initState();
    style = widget.style ?? LMFeedTheme.of(context).postStyle;
    _postHeader = widget.header ?? _defPostHeader();
    _postFooter = widget.footer ?? _defFooterWidget();
    _postContent = widget.content ?? _defContentWidget();
    _postMedia = widget.media ?? _defPostMedia();
    _postTopic = widget.topicWidget ?? _defTopicWidget();
    _postMenu = widget.menu;
  }

  @override
  void didUpdateWidget(covariant LMFeedPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _postHeader = widget.header ?? _defPostHeader();
    _postFooter = widget.footer ?? _defFooterWidget();
    _postContent = widget.content ?? _defContentWidget();
    _postMedia = widget.media ?? _defPostMedia();
    _postTopic = widget.topicWidget ?? _defTopicWidget();
    _postMenu = widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', LMFeedCustomMessages());
    return InheritedPostProvider(
      post: widget.post,
      child: GestureDetector(
        onTap: () {
          widget.onPostTap?.call(context, widget.post);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              widget.headerBuilder?.call(context, _postHeader!, widget.post) ??
                  _postHeader!,
              widget.post.topics.isEmpty
                  ? const SizedBox.shrink()
                  : widget.topicBuilder
                          ?.call(context, _postTopic!, widget.post) ??
                      _postTopic!,
              widget.post.text.isEmpty
                  ? const SizedBox.shrink()
                  : widget.contentBuilder
                          ?.call(context, _postContent!, widget.post) ??
                      _postContent!,
              widget.post.attachments != null &&
                      widget.post.attachments!.isNotEmpty
                  ? widget.mediaBuilder
                          ?.call(context, _postMedia!, widget.post) ??
                      _postMedia!
                  : const SizedBox.shrink(),
              widget.footerBuilder?.call(context, _postFooter!, widget.post) ??
                  _postFooter!,
            ],
          ),
        ),
      ),
    );
  }

  LMFeedPostTopic _defTopicWidget() {
    return LMFeedPostTopic(
      topics: widget.topics,
      post: widget.post,
    );
  }

  LMFeedPostContent _defContentWidget() {
    return LMFeedPostContent(
      onTagTap: widget.onTagTap,
    );
  }

  LMFeedPostFooter _defFooterWidget() {
    return LMFeedPostFooter();
  }

  LMFeedPostHeader _defPostHeader() {
    return LMFeedPostHeader(
      user: widget.user,
      isFeed: widget.isFeed,
      postViewData: widget.post,
    );
  }

  LMFeedPostMedia _defPostMedia() {
    return LMFeedPostMedia(
      attachments: widget.post.attachments!,
    );
  }
}

class InheritedPostProvider extends InheritedWidget {
  const InheritedPostProvider({
    super.key,
    required this.child,
    required this.post,
  }) : super(child: child);

  @override
  final Widget child;
  final LMPostViewData post;

  static InheritedPostProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedPostProvider>();
  }

  @override
  bool updateShouldNotify(InheritedPostProvider oldWidget) {
    return true;
  }
}

class LMFeedPostStyle {
  // Styling variables
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final BoxBorder? border;

  LMFeedPostStyle({
    this.boxShadow,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
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
  }) {
    return LMFeedPostStyle(
      boxShadow: boxShadow ?? this.boxShadow,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      border: border ?? this.border,
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
