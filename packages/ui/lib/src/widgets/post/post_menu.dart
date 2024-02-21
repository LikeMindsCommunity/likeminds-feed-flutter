import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedMenu extends StatelessWidget {
  const LMFeedMenu({
    super.key,
    this.children,
    required this.menuItems,
    this.removeItemIds = const {4, 7},
    this.action,
    this.style,
  });

  final Map<int, Widget>? children;
  final List<LMPopUpMenuItemViewData> menuItems;
  final Set<int> removeItemIds;
  final LMFeedMenuAction? action;
  final LMFeedMenuStyle? style;

  void removeReportIntegration() {
    menuItems.removeWhere((element) {
      return removeItemIds.contains(element.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    removeReportIntegration();
    LMFeedThemeData theme = LMFeedTheme.of(context);
    LMFeedMenuStyle? style = this.style ?? theme.headerStyle.menuStyle;
    return menuItems.isEmpty
        ? Container()
        : (theme.headerStyle.menuStyle?.menuType ?? LMFeedPostMenuType.popUp) ==
                LMFeedPostMenuType.popUp
            ? SizedBox(
                child: PopupMenuButton<int>(
                  onSelected: _handleMenuTap,
                  itemBuilder: (context) => menuItems
                      .map(
                        (element) => PopupMenuItem(
                          padding: style?.padding ??
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                          textStyle: style?.menuTitleStyle?.textStyle,
                          value: element.id,
                          child: children?[element.id] ??
                              LMFeedText(
                                text: element.title,
                                style: style?.menuTitleStyle ??
                                    LMFeedTextStyle(
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
                  child: style?.menuIcon ??
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
              )
            : GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor:
                          style?.backgroundColor ?? theme.container,
                      enableDrag: true,
                      useRootNavigator: true,
                      useSafeArea: true,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            style?.borderRadius ?? BorderRadius.circular(0.0),
                      ),
                      builder: (context) {
                        return LMFeedBottomSheet(
                            style: LMFeedBottomSheetStyle(
                              dragBarColor: theme.disabledColor,
                              backgroundColor:
                                  style?.backgroundColor ?? theme.container,
                              borderRadius: style?.borderRadius,
                              boxShadow: style?.boxShadow,
                              margin: style?.margin,
                              padding: style?.padding ??
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            title: (style?.showBottomSheetTitle ?? true)
                                ? LMFeedText(
                                    text: "Options",
                                    style: style?.headingStyle ??
                                        LMFeedTextStyle(
                                          textAlign: TextAlign.left,
                                          textStyle: TextStyle(
                                            color: theme.onContainer,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  )
                                : null,
                            children: menuItems
                                .map(
                                  (e) =>
                                      children?[e.id] ??
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: LMFeedText(
                                          text: e.title,
                                          style: style?.menuTitleStyle ??
                                              LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  color: theme.onContainer,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _handleMenuTap(e.id);
                                          },
                                        ),
                                      ),
                                )
                                .toList());
                      });
                },
                child: Container(
                  color: Colors.transparent,
                  child: style?.menuIcon ??
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
      default:
        break;
    }
  }

  LMFeedMenu copyWith({
    Map<int, Widget>? children,
    LMFeedIcon? menuIcon,
    List<LMPopUpMenuItemViewData>? menuItems,
    Set<int>? removeItemIds,
    LMFeedMenuAction? action,
    LMFeedMenuStyle? style,
  }) {
    return LMFeedMenu(
      children: children ?? this.children,
      menuItems: menuItems ?? this.menuItems,
      removeItemIds: removeItemIds ?? this.removeItemIds,
      action: action ?? this.action,
      style: style ?? this.style,
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

  LMFeedMenuAction copyWith(LMFeedMenuAction action) {
    return LMFeedMenuAction(
      onPostDelete: action.onPostDelete ?? onPostDelete,
      onPostPin: action.onPostPin ?? onPostPin,
      onPostUnpin: action.onPostUnpin ?? onPostUnpin,
      onPostReport: action.onPostReport ?? onPostReport,
      onPostEdit: action.onPostEdit ?? onPostEdit,
      onCommentDelete: action.onCommentDelete ?? onCommentDelete,
      onCommentReport: action.onCommentReport ?? onCommentReport,
      onCommentEdit: action.onCommentEdit ?? onCommentEdit,
    );
  }
}

class LMFeedMenuStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final LMFeedIcon? menuIcon;
  final LMFeedPostMenuType menuType;
  final LMFeedTextStyle? headingStyle;
  final LMFeedTextStyle? menuTitleStyle;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool? showBottomSheetTitle;

  const LMFeedMenuStyle({
    this.padding,
    this.margin,
    this.menuIcon,
    this.menuType = LMFeedPostMenuType.popUp,
    this.headingStyle,
    this.menuTitleStyle,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.border,
    this.showBottomSheetTitle = true,
  });

  LMFeedMenuStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? iconColor,
    double? iconSize,
    LMFeedPostMenuType? menuType,
    LMFeedIcon? menuIcon,
    LMFeedTextStyle? headingStyle,
    LMFeedTextStyle? menuTitleStyle,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    Border? border,
    bool? showBottomSheetTitle,
  }) {
    return LMFeedMenuStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      menuIcon: menuIcon ?? this.menuIcon,
      menuType: menuType ?? this.menuType,
      headingStyle: headingStyle ?? this.headingStyle,
      menuTitleStyle: menuTitleStyle ?? this.menuTitleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      boxShadow: boxShadow ?? this.boxShadow,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      showBottomSheetTitle: showBottomSheetTitle ?? this.showBottomSheetTitle,
    );
  }
}
