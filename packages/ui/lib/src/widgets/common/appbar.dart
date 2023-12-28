import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';

class LMAppBar extends StatelessWidget {
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
  });

  final Widget? leading;
  final Widget? trailing;
  final LMTextView? title;

  final Function? backButtonCallback;

  final double? height;
  final Color? backgroundColor;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = LMFeedTheme.of(context);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        height: height ?? 64,
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
                  LMIconButton(
                    icon: LMIcon(
                      type: LMIconType.icon,
                      icon: Icons.chevron_left,
                      color: theme.colorScheme.primary,
                    ),
                    onTap: (b) {
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
}
