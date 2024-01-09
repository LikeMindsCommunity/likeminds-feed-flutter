import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/enums.dart';

class LMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LMAppBar({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.backButtonCallback,
    this.backgroundColor,
    this.border,
    this.mainAxisAlignment,
    this.margin,
    this.padding,
    this.height,
    this.width,
  });

  final Widget? leading;
  final Widget? trailing;
  final LMFeedText? title;

  final Function? backButtonCallback;

  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Size get preferredSize => Size(width ?? 0, height ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = LMFeedTheme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size(width ?? screenSize.width, height ?? 64),
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? kWhiteColor,
            border: border ??
                const Border(
                  bottom: BorderSide(
                    width: 0.1,
                    color: kGrey1Color,
                  ),
                ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
          child: Row(
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
            children: [
              leading ??
                  LMFeedButton(
                    icon: LMFeedIcon(
                      type: LMIconType.icon,
                      icon: Icons.chevron_left,
                      style: LMFeedIconStyle(
                        color: theme.colorScheme.primary,
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

  LMAppBar copyWith(LMAppBar appBar) {
    return LMAppBar(
      leading: appBar.leading ?? leading,
      trailing: appBar.trailing ?? trailing,
      title: appBar.title ?? title,
      backButtonCallback: appBar.backButtonCallback ?? backButtonCallback,
      backgroundColor: appBar.backgroundColor ?? backgroundColor,
      border: appBar.border ?? border,
      mainAxisAlignment: appBar.mainAxisAlignment ?? mainAxisAlignment,
      margin: appBar.margin ?? margin,
      padding: appBar.padding ?? padding,
      height: appBar.height ?? height,
      width: appBar.width ?? width,
    );
  }
}
