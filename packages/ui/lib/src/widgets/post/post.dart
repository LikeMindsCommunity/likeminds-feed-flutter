import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';

/// {@template post_widget}
/// A widget that displays a post on the feed.
/// Provide a header, footer, menu, media
/// and content instance to customize the post.
/// {@endtemplate}
class LMPostWidget extends StatelessWidget {
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
  });

  final LMPostHeaderBuilder? headerBuilder;
  final LMPostFooterBuilder? footerBuilder;
  final LMPostMenuBuilder? menuBuilder;
  final LMPostMediaBuilder? mediaBuilder;
  final LMPostContentBuilder? contentBuilder;

  // Required variables
  final PostViewData post;
  final UserViewData user;
  final bool isFeed;
  final OnPostTap onPostTap;
  final Function(String) onTagTap;

  @override
  Widget build(BuildContext context) {
    return InheritedPostProvider(
      post: post,
      child: GestureDetector(
        onTap: () => onPostTap(context, post),
        child: Container(
          color: kWhiteColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerBuilder != null
                    ? headerBuilder!(context, post)
                    : LMPostHeader(
                        user: user,
                        isFeed: isFeed,
                      ),
                contentBuilder != null
                    ? contentBuilder!(context, post)
                    : LMPostContent(
                        onTagTap: onTagTap,
                      ),
                mediaBuilder == null
                    ? post.attachments != null && post.attachments!.isNotEmpty
                        ? LMPostMedia(attachments: post.attachments!)
                        : const SizedBox()
                    : mediaBuilder!(context, post),
                const SizedBox(height: 18),
                footerBuilder != null
                    ? footerBuilder!(context, post)
                    : const LMPostFooter(),
              ],
            ),
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
  final PostViewData post;

  static InheritedPostProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedPostProvider>();
  }

  @override
  bool updateShouldNotify(InheritedPostProvider oldWidget) {
    return true;
  }
}
