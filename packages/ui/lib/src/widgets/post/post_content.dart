import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';

class LMFeedPostContent extends StatelessWidget {
  const LMFeedPostContent({
    super.key,
    this.text,
    this.onTagTap,
    this.onHeadingTap,
    this.expanded = false,
    this.style,
    this.heading,
    this.headingBuilder,
  });

  final String? text;
  final String? heading;
  final VoidCallback? onHeadingTap;

  /// A builder that returns a widget to build heading
  final Widget Function(BuildContext context, LMFeedExpandableText heading,
      String headingText)? headingBuilder;

  final LMFeedOnTagTap? onTagTap;
  final bool expanded;

  final LMFeedPostContentStyle? style;

  @override
  Widget build(BuildContext context) {
    final LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;
    final LMFeedPostContentStyle contentStyle = style ?? feedTheme.contentStyle;
    return ((heading?.isEmpty ?? true) && (text?.isEmpty ?? true))
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
                  headingBuilder?.call(
                        context,
                        _defHeading(
                          heading: heading,
                          contentStyle: contentStyle,
                          expanded: expanded,
                          feedTheme: feedTheme,
                          onTagTap: onTagTap,
                          context: context,
                        ),
                        heading!,
                      ) ??
                      _defHeading(
                        heading: heading,
                        contentStyle: contentStyle,
                        expanded: expanded,
                        feedTheme: feedTheme,
                        onTagTap: onTagTap,
                        context: context,
                      ),
                if ((heading != null && heading!.isNotEmpty) &&
                    (text != null && text!.isNotEmpty))
                  contentStyle.headingSeparator,
                if (text != null && text!.isNotEmpty)
                  LMFeedExpandableText(
                    text!,
                    onTagTap: (String uuid) {
                      onTagTap?.call(uuid);
                    },
                    onTextTap: onHeadingTap,
                    expandText: contentStyle.expandText ?? "see more",
                    collapseText: contentStyle.collapseText ?? "view less",
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
    Widget Function(BuildContext context, LMFeedExpandableText heading,
            String headingText)?
        headingBuilder,
  }) {
    return LMFeedPostContent(
      text: text ?? this.text,
      onTagTap: onTagTap ?? this.onTagTap,
      expanded: expanded ?? this.expanded,
      style: style ?? this.style,
      headingBuilder: headingBuilder ?? this.headingBuilder,
    );
  }

  LMFeedExpandableText _defHeading({
    required String? heading,
    required LMFeedPostContentStyle contentStyle,
    required bool expanded,
    required LMFeedThemeData feedTheme,
    required LMFeedOnTagTap? onTagTap,
    required BuildContext context,
  }) {
    return LMFeedExpandableText(
      heading!,
      expandText: contentStyle.expandText ?? "see more",
      expanded: expanded,
      maxLines: contentStyle.headingVisibleLines ?? 3,
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
      onTextTap: onHeadingTap,
      style: contentStyle.headingStyle,
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
  final String? collapseText;
  final bool? animation;
  final int? headingVisibleLines;
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
    this.collapseText,
    this.animation,
    this.visibleLines,
    this.textAlign,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.headingVisibleLines,
    this.headingSeparator = const SizedBox.shrink(),
  });

  LMFeedPostContentStyle copyWith({
    TextStyle? textStyle,
    TextStyle? headingStyle,
    TextStyle? linkStyle,
    TextStyle? expandTextStyle,
    TextAlign? textAlign,
    String? expandText,
    String? collapseText,
    bool? animation,
    int? visibleLines,
    int? headingVisibleLines,
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
      collapseText: collapseText ?? this.collapseText,
      animation: animation ?? this.animation,
      visibleLines: visibleLines ?? this.visibleLines,
      textAlign: textAlign ?? this.textAlign,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      headingSeparator: headingSeparator ?? this.headingSeparator,
      headingVisibleLines: headingVisibleLines ?? this.headingVisibleLines,
    );
  }

  factory LMFeedPostContentStyle.basic({Color? onContainer}) =>
      LMFeedPostContentStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        headingSeparator: const SizedBox(height: 0.0),
        headingStyle: TextStyle(
          color: onContainer ?? LikeMindsTheme.headingColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textStyle: TextStyle(
          color: onContainer ?? LikeMindsTheme.greyColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      );
}
