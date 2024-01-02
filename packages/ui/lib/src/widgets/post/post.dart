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
    required this.onPostTap,
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
  final LMOnPostTap onPostTap;
  final Function(String) onTagTap;

  final Function(bool isLiked)? onLikeTap;
  final Function(bool isPinned)? onPinTap;
  final Function(bool isSaved)? onSaveTap;

  @override
  State<LMPostWidget> createState() => _LMPostWidgetState();
}

class _LMPostWidgetState extends State<LMPostWidget> {
  int postLikes = 0;
  int comments = 0;
  bool? isLiked;
  bool? isPinned;
  ValueNotifier<bool> rebuildLikeWidget = ValueNotifier(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  LMPostMetaData? postMetaData;

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
        onTap: () => widget.onPostTap(context, widget.post),
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
                  ? widget.headerBuilder!(context, widget.post)
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: LMPostHeader(
                        user: widget.user,
                        isFeed: widget.isFeed,
                      ),
                    ),
              widget.contentBuilder != null
                  ? widget.contentBuilder!(context, postMetaData!)
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: LMPostContent(
                        onTagTap: widget.onTagTap,
                      ),
                    ),
              widget.post.attachments != null &&
                      widget.post.attachments!.isNotEmpty
                  ? widget.mediaBuilder == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: LMPostMedia(
                              attachments: widget.post.attachments!),
                        )
                      : widget.mediaBuilder!(context, postMetaData!)
                  : const SizedBox(),
              const SizedBox(height: 18),
              widget.footerBuilder != null
                  ? widget.footerBuilder!(context, postMetaData!)
                  : const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: LMPostFooter()),
            ],
          ),
        ),
      ),
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
