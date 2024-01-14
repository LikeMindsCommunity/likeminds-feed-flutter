import 'dart:io';

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
  final Widget? trailing;
  final Widget? title;

  final Function? backButtonCallback;

  final LMFeedAppBarStyle? style;

  @override
  Widget build(BuildContext context) {
    final inStyle = style ?? LMFeedAppBarStyle.basic();
    final theme = LMFeedTheme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: inStyle.margin ?? EdgeInsets.zero,
        child: Container(
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
          padding: inStyle.padding ??
              const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
          child: Row(
            mainAxisAlignment:
                inStyle.mainAxisAlignment ?? MainAxisAlignment.start,
            children: [
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
                      backButtonCallback?.call() ?? Navigator.of(context).pop();
                    },
                  ),
              const SizedBox.shrink(),
              title ?? const SizedBox(),
              Platform.isAndroid ? const Spacer() : const SizedBox.shrink(),
              trailing ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  LMFeedAppBar copyWith({
    Widget? leading,
    Widget? trailing,
    LMFeedText? title,
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
  final MainAxisAlignment? mainAxisAlignment;
  final List<BoxShadow>? shadow;

  const LMFeedAppBarStyle({
    this.backgroundColor,
    this.border,
    this.mainAxisAlignment,
    this.margin,
    this.padding,
    this.height,
    this.width,
    this.shadow,
  });

  LMFeedAppBarStyle copyWith({
    Color? backgroundColor,
    double? height,
    double? width,
    Border? border,
    EdgeInsets? padding,
    EdgeInsets? margin,
    MainAxisAlignment? mainAxisAlignment,
    List<BoxShadow>? shadow,
  }) {
    return LMFeedAppBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  factory LMFeedAppBarStyle.basic() {
    return const LMFeedAppBarStyle(
      backgroundColor: Colors.transparent,
      height: 72,
      width: double.infinity,
      padding: EdgeInsets.all(12),
      mainAxisAlignment: MainAxisAlignment.start,
      shadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 2.0,
          offset: Offset(0.0, 1.0), // shadow direction: bottom right
        )
      ],
    );
  }
}
