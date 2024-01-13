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
    this.style = const LMFeedPostContentStyle(),
  });

  final String? text;

  final Function(String)? onTagTap;
  final bool expanded;

  final LMFeedPostContentStyle style;

  @override
  Widget build(BuildContext context) {
    final postDetails = InheritedPostProvider.of(context)?.post;
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Container(
      width: style.width,
      height: style.height,
      padding: style.padding,
      margin: style.margin,
      child: ExpandableText(
        text ?? postDetails!.text,
        onTagTap: (String userId) {
          onTagTap?.call(userId);
        },
        expandText: style.expandText ?? "see more",
        animation: style.animation ?? true,
        maxLines: style.visibleLines ?? 4,
        expanded: expanded,
        hashtagStyle: style.linkStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: feedTheme.primaryColor),
        prefixStyle: style.expandTextStyle,
        linkStyle: style.linkStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: feedTheme.primaryColor),
        textAlign: style.textAlign ?? TextAlign.left,
        style: style.textStyle ?? Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  LMFeedPostContent copyWith(LMFeedPostContent content) {
    return LMFeedPostContent(
      text: content.text ?? text,
      onTagTap: content.onTagTap,
      expanded: content.expanded,
      style: style.copyWith(content.style),
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
