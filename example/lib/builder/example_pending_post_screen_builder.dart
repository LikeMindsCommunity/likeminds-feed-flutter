import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class ExamplePendingPostScreenBuilder
    extends LMFeedPendingPostScreenBuilderDelegate {
  @override
  Future<void> showPostApprovalDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              dialog.copyWith(
                title: "Approval ka title",
                description: "Description",
                headingTextStyles: dialog.headingTextStyles?.copyWith(
                    textStyle: dialog.headingTextStyles?.textStyle?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                cancelButtonStyles: const LMFeedButtonStyle(
                  backgroundColor: Colors.red,
                ),
                editPostButtonStyles: dialog
                    .getEditButton()
                    .style
                    ?.copyWith(backgroundColor: Colors.green),
                dialogStyle: const LMFeedDialogStyle(
                  elevation: 0,
                  shadowColor: Colors.white,
                ),
              ),
              TextButton(
                  onPressed: () {
                    dialog.onEditButtonClicked?.call();
                  },
                  child: const Text('Edit Button')),
              TextButton(
                  onPressed: () {
                    dialog.onCancelButtonClicked?.call();
                  },
                  child: const Text('cancel Button'))
            ],
          );
        });
  }

  @override
  Future<void> showPostRejectionDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        elevation: 0,
        builder: (context) {
          return Column(
            children: [
              dialog.copyWith(
                title: "rejection ka title",
                description: "Description",
                dialogMessageTextStyles: dialog.dialogMessageTextStyles
                    ?.copyWith(
                        textStyle: dialog.dialogMessageTextStyles?.textStyle
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightGreenAccent)),
                headingTextStyles: dialog.headingTextStyles?.copyWith(
                    textStyle: dialog.headingTextStyles?.textStyle?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                cancelButtonStyles: const LMFeedButtonStyle(
                  backgroundColor: Colors.red,
                ),
                editPostButtonStyles: dialog
                    .getEditButton()
                    .style
                    ?.copyWith(backgroundColor: Colors.green),
                dialogStyle: const LMFeedDialogStyle(
                  elevation: 0,
                  shadowColor: Colors.white,
                  backgroundColor: Colors.transparent,
                ),
              ),
              TextButton(
                  onPressed: () {
                    dialog.onEditButtonClicked?.call();
                  },
                  child: const Text('Edit Button')),
              TextButton(
                  onPressed: () {
                    dialog.onCancelButtonClicked?.call();
                  },
                  child: const Text('cancel Button'))
            ],
          );
        });
  }
}
