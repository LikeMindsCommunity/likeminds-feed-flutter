import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedDialog extends StatelessWidget {
  final Widget child;
  final LMFeedDialogStyle? dialogStyle;

  const LMFeedDialog({
    super.key,
    required this.child,
    this.dialogStyle,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedDialogStyle insetDialogStyle =
        dialogStyle ?? LMFeedTheme.instance.theme.dialogStyle;

    return Dialog(
      alignment: insetDialogStyle.alignment,
      backgroundColor: insetDialogStyle.backgroundColor,
      clipBehavior: insetDialogStyle.clipBehavior,
      elevation: insetDialogStyle.elevation,
      insetAnimationCurve: insetDialogStyle.insetAnimationCurve,
      insetAnimationDuration: insetDialogStyle.insetAnimationDuration,
      insetPadding: insetDialogStyle.insetPadding,
      shadowColor: insetDialogStyle.shadowColor,
      shape: insetDialogStyle.shape,
      surfaceTintColor: insetDialogStyle.surfaceTintColor,
      child: Padding(
        padding: insetDialogStyle.padding,
        child: child,
      ),
    );
  }
}
