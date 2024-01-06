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

  // Required variables
  final LMPostViewData post;
  final LMUserViewData user;
  final Map<String, LMTopicViewData> topics;
  final bool isFeed;
  final LMOnPostTap? onPostTap;
  final Function(String) onTagTap;

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
  LMPostMetaData? postMetaData;

  onPostTap() {}

  @override
  void initState() {
    super.initState();
    postMetaData = (LMPostMetaDataBuilder()
          ..postViewData(widget.post)
          ..users({widget.post.userId: widget.user})
          ..topics(widget.topics))
        .build();
  }

  @override
  void didUpdateWidget(covariant LMPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      postMetaData = (LMPostMetaDataBuilder()
            ..postViewData(widget.post)
            ..users({widget.post.userId: widget.user})
            ..topics(widget.topics))
          .build();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedPostProvider(
      post: widget.post,
      child: GestureDetector(
        onTap: () {
          widget.onPostTap?.call(context, postMetaData!);
          onPostTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: widget.borderRadius,
            boxShadow: widget.boxShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.headerBuilder != null
                  ? widget.headerBuilder!(context, defPostHeader())
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: defPostHeader(),
                    ),
              widget.contentBuilder != null
                  ? widget.contentBuilder!(context, defContentWidget())
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: defContentWidget(),
                    ),
              widget.post.attachments != null &&
                      widget.post.attachments!.isNotEmpty
                  ? widget.mediaBuilder == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: defPostMedia(),
                        )
                      : widget.mediaBuilder!(context, defPostMedia())
                  : const SizedBox(),
              const SizedBox(height: 18),
              widget.footerBuilder != null
                  ? widget.footerBuilder!(context, defFooterWidget())
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: defFooterWidget(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  LMPostContent defContentWidget() {
    return LMPostContent(
      onTagTap: widget.onTagTap,
    );
  }

  LMPostFooter defFooterWidget() {
    return LMPostFooter();
  }

  LMPostHeader defPostHeader() {
    return LMPostHeader(
      user: widget.user,
      isFeed: widget.isFeed,
    );
  }

  LMPostMedia defPostMedia() {
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
