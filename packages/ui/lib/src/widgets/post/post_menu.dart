import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedMenu extends StatelessWidget {
  const LMFeedMenu({
    super.key,
    this.children,
    required this.menuItems,
    required this.isFeed,
    this.menuIcon,
    this.removeItemIds = const {4, 7},
    this.action,
  });

  final Map<int, LMFeedText>? children;
  final LMFeedIcon? menuIcon;
  final List<LMPopUpMenuItemViewData> menuItems;
  final bool isFeed;
  final Set<int> removeItemIds;
  final LMFeedMenuAction? action;

  void removeReportIntegration() {
    menuItems.removeWhere((element) {
      return removeItemIds.contains(element.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    removeReportIntegration();
    LMFeedThemeData theme = LMFeedTheme.of(context);
    return menuItems.isEmpty
        ? Container()
        : SizedBox(
            child: PopupMenuButton<int>(
              onSelected: _handleMenuTap,
              itemBuilder: (context) => menuItems
                  .map(
                    (element) => PopupMenuItem(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      value: element.id,
                      child: children?[element.id] ??
                          LMFeedText(
                            text: element.title,
                            style: LMFeedTextStyle(
                              textStyle: TextStyle(
                                color: theme.onContainer,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                    ),
                  )
                  .toList(),
              color: theme.container,
              surfaceTintColor: Colors.transparent,
              child: menuIcon ??
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
            ),
          );
  }

  void _handleMenuTap(int itemId) {
    switch (itemId) {
      case LMFeedMenuAction.postDeleteId:
        action?.onPostDelete?.call();
        break;
      case LMFeedMenuAction.postPinId:
        action?.onPostPin?.call();
        break;
      case LMFeedMenuAction.postUnpinId:
        action?.onPostUnpin?.call();
        break;
      case LMFeedMenuAction.postReportId:
        action?.onPostReport?.call();
        break;
      case LMFeedMenuAction.postEditId:
        action?.onPostEdit?.call();
        break;
      case LMFeedMenuAction.commentDeleteId:
        action?.onCommentDelete?.call();
        break;
      case LMFeedMenuAction.commentReportId:
        action?.onCommentReport?.call();
        break;
      case LMFeedMenuAction.commentEditId:
        action?.onCommentEdit?.call();
        break;
    }
  }

  LMFeedMenu copyWith({
    Map<int, LMFeedText>? children,
    LMFeedIcon? menuIcon,
    List<LMPopUpMenuItemViewData>? menuItems,
    bool? isFeed,
    Set<int>? removeItemIds,
    LMFeedMenuAction? action,
  }) {
    return LMFeedMenu(
      children: children ?? this.children,
      menuIcon: menuIcon ?? this.menuIcon,
      menuItems: menuItems ?? this.menuItems,
      isFeed: isFeed ?? this.isFeed,
      removeItemIds: removeItemIds ?? this.removeItemIds,
      action: action ?? this.action,
    );
  }
}

class LMFeedMenuAction {
  static const int postDeleteId = 1;
  static const int postPinId = 2;
  static const int postUnpinId = 3;
  static const int postReportId = 4;
  static const int postEditId = 5;

// Comment & Reply Id
  static const int commentDeleteId = 6;
  static const int commentReportId = 7;
  static const int commentEditId = 8;

  VoidCallback? onPostDelete;
  VoidCallback? onPostPin;
  VoidCallback? onPostUnpin;
  VoidCallback? onPostReport;
  VoidCallback? onPostEdit;

  VoidCallback? onCommentDelete;
  VoidCallback? onCommentReport;
  VoidCallback? onCommentEdit;

  LMFeedMenuAction({
    this.onPostDelete,
    this.onPostPin,
    this.onPostUnpin,
    this.onPostReport,
    this.onPostEdit,
    this.onCommentDelete,
    this.onCommentReport,
    this.onCommentEdit,
  });

  LMFeedMenuAction copyWith({
    VoidCallback? onPostDelete,
    VoidCallback? onPostPin,
    VoidCallback? onPostUnpin,
    VoidCallback? onPostReport,
    VoidCallback? onPostEdit,
    VoidCallback? onCommentDelete,
    VoidCallback? onCommentReport,
    VoidCallback? onCommentEdit,
  }) {
    return LMFeedMenuAction(
      onPostDelete: onPostDelete ?? this.onPostDelete,
      onPostPin: onPostPin ?? this.onPostPin,
      onPostUnpin: onPostUnpin ?? this.onPostUnpin,
      onPostReport: onPostReport ?? this.onPostReport,
      onPostEdit: onPostEdit ?? this.onPostEdit,
      onCommentDelete: onCommentDelete ?? this.onCommentDelete,
      onCommentReport: onCommentReport ?? this.onCommentReport,
      onCommentEdit: onCommentEdit ?? this.onCommentEdit,
    );
  }
}
