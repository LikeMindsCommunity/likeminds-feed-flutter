import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostApprovalDialog extends StatelessWidget {
  LMFeedPostApprovalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final LMFeedThemeData theme = LMFeedCore.theme;
    return LMFeedDialog(
      child: Container(),
      dialogStyle: theme.dialogStyle,
    );
  }
}
