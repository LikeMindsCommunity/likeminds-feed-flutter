import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

/// {@template post_widget}
/// A widget that displays a post on the feed.
/// Provide a header, footer, menu, media
/// and content instance to customize the post.
/// {@endtemplate}
class LMPostWidget extends StatefulWidget {
  ///{@macro post_widget}
  const LMPostWidget({
    super.key,
    required this.post,
    required this.user,
    this.onPostTap,
    required this.isFeed,
    required this.onTagTap,
    this.headerBuilder,
    this.footerBuilder,
    this.menuBuilder,
    this.mediaBuilder,
    this.contentBuilder,
    this.boxShadow,
    this.borderRadius,
    this.onLikeTap,
    this.onPinTap,
    this.onSaveTap,
    required this.topics,
    this.topicBuilder,
    this.padding,
    this.margin,
    this.childrenSpacing,
  });

  final LMPostHeaderBuilder? headerBuilder;
  final LMPostFooterBuilder? footerBuilder;
  final LMPostTopicBuilder? topicBuilder;
  final LMPostMenuBuilder? menuBuilder;
  final LMPostMediaBuilder? mediaBuilder;
  final LMPostContentBuilder? contentBuilder;

  // Styling variables
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // Required variables
  final LMPostViewData post;
  final LMUserViewData user;
  final Map<String, LMTopicViewData> topics;
  final bool isFeed;
  final LMOnPostTap? onPostTap;
  final Function(String) onTagTap;
  final double? childrenSpacing;

  final Function(bool isLiked)? onLikeTap;
  final Function(bool isPinned)? onPinTap;
  final Function(bool isSaved)? onSaveTap;

  @override
  State<LMPostWidget> createState() => _LMPostWidgetState();

  LMPostWidget copyWith({
    LMPostHeaderBuilder? headerBuilder,
    LMPostFooterBuilder? footerBuilder,
    LMPostTopicBuilder? topicBuilder,
    LMPostMenuBuilder? menuBuilder,
    LMPostMediaBuilder? mediaBuilder,
    LMPostContentBuilder? contentBuilder,
    List<BoxShadow>? boxShadow,
    BorderRadiusGeometry? borderRadius,
    LMPostViewData? post,
    LMUserViewData? user,
    Map<String, LMTopicViewData>? topics,
    bool? isFeed,
    LMOnPostTap? onPostTap,
    Function(String)? onTagTap,
    Function(bool isLiked)? onLikeTap,
    Function(bool isPinned)? onPinTap,
    Function(bool isSaved)? onSaveTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? childrenSpacing,
  }) {
    return LMPostWidget(
      headerBuilder: headerBuilder ?? this.headerBuilder,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      topicBuilder: topicBuilder ?? this.topicBuilder,
      menuBuilder: menuBuilder ?? this.menuBuilder,
      mediaBuilder: mediaBuilder ?? this.mediaBuilder,
      contentBuilder: contentBuilder ?? this.contentBuilder,
      boxShadow: boxShadow ?? this.boxShadow,
      borderRadius: borderRadius ?? this.borderRadius,
      post: post ?? this.post,
      user: user ?? this.user,
      topics: topics ?? this.topics,
      isFeed: isFeed ?? this.isFeed,
      onPostTap: onPostTap ?? this.onPostTap,
      onTagTap: onTagTap ?? this.onTagTap,
      onLikeTap: onLikeTap ?? this.onLikeTap,
      onPinTap: onPinTap ?? this.onPinTap,
      onSaveTap: onSaveTap ?? this.onSaveTap,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      childrenSpacing: childrenSpacing ?? childrenSpacing,
    );
  }
}

class _LMPostWidgetState extends State<LMPostWidget> {
  int postLikes = 0;
  int comments = 0;
  bool? isLiked;
  bool? isPinned;
  ValueNotifier<bool> rebuildLikeWidget = ValueNotifier(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);

  onPostTap() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LMPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {}
  }

  @override
  Widget build(BuildContext context) {
    return InheritedPostProvider(
      post: widget.post,
      child: GestureDetector(
        onTap: () {
          widget.onPostTap?.call(context, widget.post);
          onPostTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.borderRadius,
            boxShadow: widget.boxShadow,
          ),
          padding: widget.padding,
          margin: widget.margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.headerBuilder?.call(context, _defPostHeader()) ??
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.childrenSpacing ?? 0,
                    ),
                    child: _defPostHeader(),
                  ),
              widget.contentBuilder?.call(context, _defContentWidget()) ??
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.childrenSpacing ?? 0,
                    ),
                    child: _defContentWidget(),
                  ),
              widget.post.attachments != null &&
                      widget.post.attachments!.isNotEmpty
                  ? widget.mediaBuilder?.call(context, _defPostMedia()) ??
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.childrenSpacing ?? 0,
                        ),
                        child: _defPostMedia(),
                      )
                  : const SizedBox(),
              const SizedBox(height: 18),
              widget.footerBuilder?.call(context, _defFooterWidget()) ??
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: widget.childrenSpacing ?? 0,
                    ),
                    child: _defFooterWidget(),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  LMPostContent _defContentWidget() {
    return LMPostContent(
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
    );
  }

  LMPostMedia _defPostMedia() {
    return LMPostMedia(
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
