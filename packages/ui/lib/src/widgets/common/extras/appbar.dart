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
  final LMFeedText? title;

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
          ),
          padding: inStyle.padding ??
              const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
          child: Row(
            mainAxisAlignment:
                inStyle.mainAxisAlignment ?? MainAxisAlignment.center,
            children: [
              leading ??
                  LMFeedButton(
                    style: LMFeedButtonStyle(
                      icon: LMFeedIcon(
                        type: LMFeedIconType.icon,
                        icon: Icons.chevron_left,
                        style: LMFeedIconStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      backButtonCallback?.call() ?? Navigator.of(context).pop();
                    },
                  ),
              const Spacer(),
              title ?? const SizedBox(),
              const Spacer(),
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
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(92);
}

class LMFeedAppBarStyle {
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final MainAxisAlignment? mainAxisAlignment;

  const LMFeedAppBarStyle({
    this.backgroundColor,
    this.border,
    this.mainAxisAlignment,
    this.margin,
    this.padding,
    this.height,
    this.width,
  });

  LMFeedAppBarStyle copyWith({
    Color? backgroundColor,
    double? height,
    double? width,
    Border? border,
    EdgeInsets? padding,
    EdgeInsets? margin,
    MainAxisAlignment? mainAxisAlignment,
  }) {
    return LMFeedAppBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      border: border ?? this.border,
    );
  }

  factory LMFeedAppBarStyle.basic() {
    return const LMFeedAppBarStyle(
      backgroundColor: Colors.transparent,
      height: 72,
      width: double.infinity,
      padding: EdgeInsets.all(12),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}
