import 'dart:math';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LMFeedAppBar({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.style,
    this.backButtonCallback,
  });

  final Widget? leading;
  final List<Widget>? trailing;
  final Widget? title;

  final Function? backButtonCallback;

  final LMFeedAppBarStyle? style;

  @override
  Widget build(BuildContext context) {
    final inStyle = style ?? LMFeedAppBarStyle.basic();
    final theme = LMFeedTheme.instance.theme;

    return Container(
      width: min(inStyle.width ?? 600, MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
        color: inStyle.backgroundColor ?? Colors.white,
        border: inStyle.border ??
            const Border(
              bottom: BorderSide(
                width: 0.1,
                color: Colors.grey,
              ),
            ),
        boxShadow: inStyle.shadow,
      ),
      child: SafeArea(
        child: Container(
          height: inStyle.height,
          width: inStyle.width ?? double.infinity,
          margin: inStyle.margin ?? EdgeInsets.zero,
          padding: inStyle.padding ??
              const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
          child: Row(
            children: (style?.centerTitle ?? false)
                ? [
                    Expanded(
                      child: Row(
                        children: [
                          leading ??
                              LMFeedButton(
                                style: LMFeedButtonStyle(
                                  icon: LMFeedIcon(
                                    type: LMFeedIconType.icon,
                                    icon: Icons.arrow_back,
                                    style: LMFeedIconStyle(
                                      color: theme.onContainer,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  backButtonCallback?.call() ??
                                      Navigator.of(context).pop();
                                },
                              ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [title ?? const SizedBox.shrink()],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: trailing != null
                            ? trailing!
                            : [const SizedBox.shrink()],
                      ),
                    )
                  ]
                : [
                    leading ??
                        LMFeedButton(
                          style: LMFeedButtonStyle(
                            icon: LMFeedIcon(
                              type: LMFeedIconType.icon,
                              icon: Icons.chevron_left,
                              style: LMFeedIconStyle(
                                color: theme.onContainer,
                                size: 24,
                              ),
                            ),
                          ),
                          onTap: () {
                            backButtonCallback?.call() ??
                                Navigator.of(context).pop();
                          },
                        ),
                    title ?? const SizedBox.shrink(),
                    const Spacer(),
                    if (trailing != null) ...trailing!
                  ],
          ),
        ),
      ),
    );
  }

  LMFeedAppBar copyWith({
    Widget? leading,
    List<Widget>? trailing,
    Widget? title,
    Function? backButtonCallback,
    LMFeedAppBarStyle? style,
  }) {
    return LMFeedAppBar(
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      title: title ?? this.title,
      backButtonCallback: backButtonCallback ?? this.backButtonCallback,
      style: style ?? this.style,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(style?.height ?? 48);
}

class LMFeedAppBarStyle {
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? shadow;
  final bool centerTitle;

  const LMFeedAppBarStyle({
    this.backgroundColor,
    this.border,
    this.margin,
    this.padding,
    this.height,
    this.width,
    this.shadow,
    this.centerTitle = false,
  });

  LMFeedAppBarStyle copyWith({
    Color? backgroundColor,
    double? height,
    double? width,
    Border? border,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? shadow,
    bool? centerTitle,
  }) {
    return LMFeedAppBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      centerTitle: centerTitle ?? this.centerTitle,
    );
  }

  factory LMFeedAppBarStyle.basic() {
    return const LMFeedAppBarStyle(
      backgroundColor: Colors.transparent,
      width: double.infinity,
    );
  }
}
