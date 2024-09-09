import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';

import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

/// {@template post_widget}
/// A widget that displays a feed post in the LM app.
///
/// The `LMFeedPostWidget` class is responsible for rendering a single feed post
/// in the LM app. It takes in a `FeedPost` object as input and displays the
/// post's content, author information, and any associated media (e.g., images,
/// videos).
///
/// Example usage:
///
/// ```dart
/// LMFeedPostWidget(
///   post: feedPost,
/// )
/// ```
/// {@endtemplate}
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
    this.reviewBanner,
    this.reviewBannerBuilder,
  });

  /// {@macro post_style}
  final LMFeedPostStyle? style;

  /// {@macro post_review_banner_builder}
  final LMFeedPostReviewBannerBuilder? reviewBannerBuilder;

  /// {@macro post_header_builder}
  final LMFeedPostHeaderBuilder? headerBuilder;

  /// {@macro post_content_builder}
  final LMFeedPostContentBuilder? contentBuilder;

  /// {@macro post_topic_builder}
  final LMFeedPostTopicBuilder? topicBuilder;

  /// {@macro post_menu_builder}
  final LMFeedPostMenuBuilder? menuBuilder;

  /// {@macro post_media_builder}
  final LMFeedPostMediaBuilder? mediaBuilder;

  /// {@macro post_footer_builder}
  final LMFeedPostFooterBuilder? footerBuilder;

  final LMFeedPostReviewBanner? reviewBanner;
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
  final Function(int)? onMediaTap;

  final VoidCallback? disposeVideoPlayerOnInActive;

  @override
  State<LMFeedPostWidget> createState() => _LMPostWidgetState();

  /// {@template post_widget_copywith}
  /// Creates a copy of this [LMFeedPostWidget] with the specified
  /// properties overridden.
  ///
  /// The returned [LMFeedPostWidget] will have the same values
  /// for all properties except for the ones specified in the method arguments.
  ///
  /// Example usage:
  /// ```dart
  /// LMFeedPostWidget updatedWidget = originalWidget.copyWith(
  ///   title: 'Updated Title',
  ///   content: 'Updated Content',
  /// );
  /// ```
  ///
  /// Note: This method is commonly used in Flutter to create a
  /// new instance of a widget with updated properties, while keeping the rest
  /// of the properties unchanged.
  /// Returns a new [LMFeedPostWidget] instance with the specified properties
  /// overridden.
  /// {@endtemplate}
  LMFeedPostWidget copyWith({
    LMFeedPostHeaderBuilder? headerBuilder,
    LMFeedPostFooterBuilder? footerBuilder,
    LMFeedPostTopicBuilder? topicBuilder,
    LMFeedPostMenuBuilder? menuBuilder,
    LMFeedPostMediaBuilder? mediaBuilder,
    LMFeedPostContentBuilder? contentBuilder,
    LMFeedPostReviewBannerBuilder? reviewBannerBuilder,
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
    Function(int)? onMediaTap,
    Widget? activityHeader,
    void Function()? disposeVideoPlayerOnInActive,
    LMFeedPostReviewBanner? reviewBanner,
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
      disposeVideoPlayerOnInActive:
          disposeVideoPlayerOnInActive ?? this.disposeVideoPlayerOnInActive,
      reviewBanner: reviewBanner ?? this.reviewBanner,
      reviewBannerBuilder: reviewBannerBuilder ?? this.reviewBannerBuilder,
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
        clipBehavior: Clip.hardEdge,
        padding: style?.padding,
        margin: style?.margin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.isPendingPost)
              widget.reviewBannerBuilder
                      ?.call(context, _defPostReviewBanner(), widget.post) ??
                  _defPostReviewBanner(),
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

  LMFeedPostReviewBanner _defPostReviewBanner() {
    return widget.reviewBanner ??
        LMFeedPostReviewBanner(
          postReviewStatus: widget.post.postStatus,
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

/// {@template post_style}
/// Represents the style of a feed post in the LM app.
///
/// The `LMFeedPostStyle` class defines the visual appearance and layout
/// properties for a feed post in the LM app. It provides a set of style
/// options that can be customized to achieve different visual effects.
///
/// Example usage:
/// ```dart
/// LMFeedPostStyle style = LMFeedPostStyle(
///   backgroundColor: Colors.white,
///   titleTextStyle: TextStyle(
///     fontSize: 16,
///     fontWeight: FontWeight.bold,
///   ),
///   // Add more style properties here...
/// );
/// ```
/// {@endtemplate}
class LMFeedPostStyle {
  // Styling variables
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Color? backgroundColor;

  /// {@macro post_style}
  LMFeedPostStyle({
    this.boxShadow,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.backgroundColor,
  });

  /// {@template post_style_copywith}
  /// Creates a copy of this [LMFeedPostStyle] with the specified
  /// properties overridden.
  /// The returned [LMFeedPostStyle] object will have the same values
  /// for all properties
  /// as this object, except for the ones specified in the named parameters.
  ///
  /// Example usage:
  /// ```dart
  /// LMFeedPostStyle newStyle = oldStyle.copyWith(
  ///   backgroundColor: Colors.red,
  ///   textColor: Colors.white,
  /// );
  /// ```
  ///
  /// Returns a new [LMFeedPostStyle] object with the specified
  /// properties overridden.
  /// {@endtemplate}
  LMFeedPostStyle copyWith({
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
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

  /// {@template post_style_basic}
  /// Creates LikeMinds default [LMFeedPostStyle].
  ///
  /// The [LMFeedPostStyle.basic] factory constructor creates LikeMinds default
  /// [LMFeedPostStyle] object
  /// with default settings. This style is suitable for displaying a
  /// post in the feed with LikeMinds Post design.
  ///
  /// Example usage:
  /// ```dart
  /// LMFeedPostStyle style = LMFeedPostStyle.basic();
  /// ```
  /// {@endtemplate}
  factory LMFeedPostStyle.basic() => LMFeedPostStyle(
        boxShadow: [
          const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
        ],
        margin: const EdgeInsets.only(bottom: 12.0),
      );
}
