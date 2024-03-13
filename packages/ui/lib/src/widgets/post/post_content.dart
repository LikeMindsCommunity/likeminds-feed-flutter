import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';

class LMFeedPostContent extends StatelessWidget {
  const LMFeedPostContent({
    super.key,
    this.text,
    this.onTagTap,
    this.expanded = false,
    this.style,
    this.heading,
  });

  final String? text;
  final String? heading;

  final LMFeedOnTagTap? onTagTap;
  final bool expanded;

  final LMFeedPostContentStyle? style;

  @override
  Widget build(BuildContext context) {
    final LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    final LMFeedPostContentStyle contentStyle = style ?? feedTheme.contentStyle;
    return (text == null || text!.isEmpty) &&
            (heading == null || heading!.isEmpty)
        ? const SizedBox()
        : Container(
            width: contentStyle.width,
            height: contentStyle.height,
            padding: contentStyle.padding,
            margin: contentStyle.margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (heading != null && heading!.isNotEmpty)
                  LMFeedExpandableText(
                    heading!,
                    expandText: "",
                    expanded: true,
                    collapseText: "",
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
                    onTagTap: (String uuid) {
                      onTagTap?.call(uuid);
                    },
                    style: contentStyle.headingStyle,
                  ),
                if ((heading != null && heading!.isNotEmpty) &&
                    (text != null && text!.isNotEmpty))
                  contentStyle.headingSeparator,
                if (text != null && text!.isNotEmpty)
                  LMFeedExpandableText(
                    text!,
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
                    style: contentStyle.textStyle ??
                        Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
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
  final Widget headingSeparator;
  final TextStyle? textStyle;
  final TextStyle? headingStyle;
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
    this.headingStyle,
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
    this.headingSeparator = const SizedBox.shrink(),
  });

  LMFeedPostContentStyle copyWith({
    TextStyle? textStyle,
    TextStyle? headingStyle,
    TextStyle? linkStyle,
    TextStyle? expandTextStyle,
    TextAlign? textAlign,
    String? expandText,
    bool? animation,
    int? visibleLines,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Widget? headingSeparator,
  }) {
    return LMFeedPostContentStyle(
      textStyle: textStyle ?? this.textStyle,
      headingStyle: headingStyle ?? this.headingStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      expandTextStyle: expandTextStyle ?? this.expandTextStyle,
      expandText: expandText ?? this.expandText,
      animation: animation ?? this.animation,
      visibleLines: visibleLines ?? this.visibleLines,
      textAlign: textAlign ?? this.textAlign,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      headingSeparator: headingSeparator ?? this.headingSeparator,
    );
  }

  factory LMFeedPostContentStyle.basic({Color? onContainer}) =>
      LMFeedPostContentStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        headingSeparator: const SizedBox(height: 0.0),
        headingStyle: TextStyle(
          color: onContainer ?? LikeMindsTheme.greyColor,
          fontSize: 18,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
        textStyle: TextStyle(
          color: onContainer ?? LikeMindsTheme.greyColor,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      );
}
