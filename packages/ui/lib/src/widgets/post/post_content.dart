import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/post/post.dart';

class LMFeedPostContent extends StatelessWidget {
  const LMFeedPostContent({
    super.key,
    this.text,
    this.onTagTap,
    this.expanded = false,
    this.style,
  });

  final String? text;

  final Function(String)? onTagTap;
  final bool expanded;

  final LMFeedPostContentStyle? style;

  @override
  Widget build(BuildContext context) {
    final postDetails = InheritedPostProvider.of(context)?.post;
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    final LMFeedPostContentStyle contentStyle =
        style ?? feedTheme.postStyle.contentStyle;
    return Container(
      width: contentStyle.width,
      height: contentStyle.height,
      padding: contentStyle.padding,
      margin: contentStyle.margin,
      child: ExpandableText(
        text ?? postDetails!.text,
        onTagTap: (String userId) {
          onTagTap?.call(userId);
        },
        expandText: contentStyle.expandText ?? "see more",
        animation: contentStyle.animation ?? true,
        maxLines: contentStyle.visibleLines ?? 4,
        expanded: expanded,
        hashtagStyle: contentStyle.linkStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: feedTheme.primaryColor),
        prefixStyle: contentStyle.expandTextStyle,
        linkStyle: contentStyle.linkStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: feedTheme.primaryColor),
        textAlign: contentStyle.textAlign ?? TextAlign.left,
        style: contentStyle.textStyle ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  LMFeedPostContent copyWith({
    String? text,
    Function(String)? onTagTap,
    bool? expanded,
    LMFeedPostContentStyle? style,
  }) {
    return LMFeedPostContent(
      text: text ?? this.text,
      onTagTap: onTagTap ?? this.onTagTap,
      expanded: expanded ?? this.expanded,
      style: style ?? this.style,
    );
  }
}

class LMFeedPostContentStyle {
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final TextStyle? expandTextStyle;
  final TextAlign? textAlign;
  final String? expandText;
  final bool? animation;
  final int? visibleLines;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const LMFeedPostContentStyle({
    this.textStyle,
    this.linkStyle,
    this.expandTextStyle,
    this.expandText,
    this.animation,
    this.visibleLines,
    this.textAlign,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  LMFeedPostContentStyle copyWith(LMFeedPostContentStyle style) {
    return LMFeedPostContentStyle(
      textStyle: style.textStyle ?? textStyle,
      linkStyle: style.linkStyle ?? linkStyle,
      expandTextStyle: style.expandTextStyle ?? expandTextStyle,
      expandText: style.expandText ?? expandText,
      animation: style.animation ?? animation,
      visibleLines: style.visibleLines ?? visibleLines,
      textAlign: style.textAlign ?? textAlign,
      width: style.width ?? width,
      height: style.height ?? height,
      padding: style.padding ?? padding,
      margin: style.margin ?? margin,
    );
  }
}
