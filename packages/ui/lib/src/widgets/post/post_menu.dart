import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

/// {@template lm_feed_menu}
/// `LMFeedMenu` is a stateless widget that represents a menu in the feed.
/// It includes a list of menu items, a map of child widgets for each menu item,
/// a set of menu item IDs to be removed, an action to be performed when a menu
/// item is selected,
/// a style for the menu, and callbacks for when the menu is tapped and opened.
///   /// Example usage:
/// ```dart
/// LMFeedMenu(
///   menuItems: [
///     LMPopUpMenuItemViewData(
///       id: 1,
///       title: 'Menu Item 1',
///       icon: Icons.menu,
///     ),
///     LMPopUpMenuItemViewData(
///       id: 2,
///       title: 'Menu Item 2',
///       icon: Icons.menu,
///     ),
///   ],
///   removeItemIds: {2},
///   onMenuTap: () {
///     print('Menu tapped');
///   },
///   onMenuOpen: () {
///     print('Menu opened');
///   },
/// );
/// ```
/// {@endtemplate}
class LMFeedMenu extends StatelessWidget {
  /// Constructor for `LMFeedMenu`.
  /// {@macro lm_feed_menu}
  const LMFeedMenu({
    super.key,
    required this.menuItems,
    this.removeItemIds = const {4, 7},
    this.action,
    this.style,
    this.onMenuTap,
    this.onMenuOpen,
    this.menuItemBuilderForDialog,
    this.menuItemBuilderForBottomSheet,
  });

  /// A list of menu items.
  final List<LMPopUpMenuItemViewData> menuItems;

  /// A set of menu item IDs to be removed from the menu.
  final Set<int> removeItemIds;

  /// The action to be performed when a menu item is selected.
  final LMFeedMenuAction? action;

  /// The style for the menu.
  final LMFeedMenuStyle? style;

  /// A callback that is called when the menu is tapped.
  final VoidCallback? onMenuTap;

  /// A callback that is called when the menu is opened.
  final VoidCallback? onMenuOpen;

  /// A builder that returns a widget to build the menu item when the menu type
  /// is displayed as a dialog.
  final Widget Function(BuildContext context, LMFeedText menuItem,
      LMPopUpMenuItemViewData menuItemViewData)? menuItemBuilderForDialog;

  /// A builder that returns a widget to build the menu item when the menu type
  /// is a bottom sheet.
  final Widget Function(BuildContext context, LMFeedTile menuItem,
      LMPopUpMenuItemViewData menuItemViewData)? menuItemBuilderForBottomSheet;

  void removeReportIntegration() {
    menuItems.removeWhere((element) {
      return removeItemIds.contains(element.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    removeReportIntegration();
    LMFeedThemeData theme = LMFeedTheme.instance.theme;
    LMFeedMenuStyle? style = this.style ?? theme.headerStyle.menuStyle;
    return menuItems.isEmpty
        ? Container() // Return an empty container if there are no menu items
        : InkWell(
            onTap: () {
              if (onMenuTap != null) {
                onMenuTap?.call();
                onMenuOpen?.call();
              }
            },
            splashFactory: InkRipple.splashFactory,
            child: AbsorbPointer(
              absorbing: onMenuTap != null,
              child: (style?.menuType ?? LMFeedPostMenuType.popUp) ==
                      LMFeedPostMenuType.popUp
                  ? SizedBox(
                      child: PopupMenuButton<int>(
                        padding: EdgeInsets.zero,
                        onSelected: _handleMenuTap,
                        itemBuilder: (context) => menuItems
                            .map(
                              (element) => PopupMenuItem(
                                padding: style?.padding ??
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                textStyle: style?.menuTitleStyle
                                    ?.call(element.id, null)
                                    ?.textStyle,
                                value: element.id,
                                child: menuItemBuilderForDialog?.call(
                                      context,
                                      _defMenuItemForDialog(
                                          element, style, theme),
                                      element,
                                    ) ??
                                    _defMenuItemForDialog(
                                        element, style, theme),
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
                        onOpened: () {
                          onMenuOpen?.call();
                        },
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            backgroundColor:
                                style?.backgroundColor ?? theme.container,
                            showDragHandle: true,
                            useRootNavigator: true,
                            useSafeArea: true,
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: style?.borderRadius ??
                                  BorderRadius.circular(0.0),
                            ),
                            builder: (context) {
                              return LMFeedBottomSheet(
                                style: LMFeedBottomSheetStyle(
                                  dragBar: const SizedBox(),
                                  backgroundColor:
                                      style?.backgroundColor ?? theme.container,
                                  borderRadius: style?.borderRadius,
                                  boxShadow: style?.boxShadow,
                                  margin: style?.margin,
                                  padding: style?.padding ??
                                      const EdgeInsets.symmetric(
                                          horizontal: 20.0),
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
                                children: [
                                  for (final menuItem in menuItems)
                                    menuItemBuilderForBottomSheet?.call(
                                          context,
                                          _defMenuItemInBottomSheet(
                                              menuItem, style, theme, context),
                                          menuItem,
                                        ) ??
                                        _defMenuItemInBottomSheet(
                                            menuItem, style, theme, context),
                                ],
                              );
                            });
                        // Called when the post menu is opened
                        onMenuOpen?.call();
                      },
                      splashFactory: InkRipple.splashFactory,
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
                    ),
            ),
          );
  }

  LMFeedText _defMenuItemForDialog(LMPopUpMenuItemViewData element,
      LMFeedMenuStyle? style, LMFeedThemeData theme) {
    return LMFeedText(
      text: element.title,
      style: style?.menuTitleStyle?.call(
            element.id,
            LMFeedTextStyle(
              textStyle: TextStyle(
                color: theme.onContainer,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ) ??
          LMFeedTextStyle(
            textStyle: TextStyle(
              color: theme.onContainer,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  LMFeedTile _defMenuItemInBottomSheet(LMPopUpMenuItemViewData e,
      LMFeedMenuStyle? style, LMFeedThemeData theme, BuildContext context) {
    return LMFeedTile(
      leading: const SizedBox(),
      style: LMFeedTileStyle.basic().copyWith(
        width: 1000,
      ),
      title: LMFeedText(
        text: e.title,
        style: style?.menuTitleStyle?.call(
              e.id,
              LMFeedTextStyle(
                textStyle: TextStyle(
                  color: theme.onContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ) ??
            LMFeedTextStyle(
              textStyle: TextStyle(
                color: theme.onContainer,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        _handleMenuTap(e.id);
      },
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
      case LMFeedMenuAction.pendingPostDeleteId:
        action?.onPendingPostDelete?.call();
        break;
      case LMFeedMenuAction.pendingPostEditId:
        action?.onPendingPostEdit?.call();
        break;
      default:
        break;
    }
  }

  /// {@template lm_feed_menu_copywith}
  /// Creates a copy of this `LMFeedMenu` but with the given fields replaced
  /// with the new values.
  /// If a field is not provided, the value from the current `LMFeedMenu`
  /// instance will be used.
  ///
  /// - `children`: A map of child widgets for each menu item. The key is the
  /// menu item ID.
  /// - `menuIcon`: The icon for the menu.
  /// - `menuItems`: A list of menu items.
  /// - `removeItemIds`: A set of menu item IDs to be removed from the menu.
  /// - `action`: The action to be performed when a menu item is selected.
  /// - `style`: The style for the menu.
  /// - `onMenuTap`: A callback that is called when the menu is tapped.
  /// - `onMenuOpen`: A callback that is called when the menu is opened.
  /// {@endtemplate}
  ///
  LMFeedMenu copyWith({
    List<LMPopUpMenuItemViewData>? menuItems,
    Set<int>? removeItemIds,
    LMFeedMenuAction? action,
    LMFeedMenuStyle? style,
    VoidCallback? onMenuTap,
    VoidCallback? onMenuOpen,
    Widget Function(BuildContext context, LMFeedText menuItem,
            LMPopUpMenuItemViewData menuItemViewData)?
        menuItemBuilderForDialog,
    Widget Function(BuildContext context, LMFeedTile menuItem,
            LMPopUpMenuItemViewData menuItemViewData)?
        menuItemBuilderForBottomSheet,
  }) {
    return LMFeedMenu(
      menuItems: menuItems ?? this.menuItems,
      removeItemIds: removeItemIds ?? this.removeItemIds,
      action: action ?? this.action,
      style: style ?? this.style,
      onMenuTap: onMenuTap ?? this.onMenuTap,
      onMenuOpen: onMenuOpen ?? this.onMenuOpen,
      menuItemBuilderForDialog:
          menuItemBuilderForDialog ?? this.menuItemBuilderForDialog,
      menuItemBuilderForBottomSheet:
          menuItemBuilderForBottomSheet ?? this.menuItemBuilderForBottomSheet,
    );
  }
}

class LMFeedMenuAction {
  static const int postDeleteId = 1;
  static const int postPinId = 2;
  static const int postUnpinId = 3;
  static const int postReportId = 4;
  static const int postEditId = 5;
  static const int pendingPostDeleteId = 10;
  static const int pendingPostEditId = 9;

// Comment & Reply Id
  static const int commentDeleteId = 6;
  static const int commentReportId = 7;
  static const int commentEditId = 8;

  VoidCallback? onPostDelete;
  VoidCallback? onPostPin;
  VoidCallback? onPostUnpin;
  VoidCallback? onPostReport;
  VoidCallback? onPostEdit;
  VoidCallback? onPendingPostDelete;
  VoidCallback? onPendingPostEdit;

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
    this.onPendingPostDelete,
    this.onPendingPostEdit,
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
    VoidCallback? onPendingPostDelete,
    VoidCallback? onPendingPostEdit,
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
      onPendingPostDelete: onPendingPostDelete ?? this.onPendingPostDelete,
      onPendingPostEdit: onPendingPostEdit ?? this.onPendingPostEdit,
    );
  }
}

class LMFeedMenuStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final LMFeedIcon? menuIcon;
  final LMFeedPostMenuType menuType;
  final LMFeedTextStyle? headingStyle;
  final LMFeedTextStyle? Function(int id, LMFeedTextStyle? style)?
      menuTitleStyle;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool? showBottomSheetTitle;
  final Map<int, LMFeedMenuItemStyle>? menuItemStyle;

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
    this.menuItemStyle,
  });

  LMFeedMenuStyle copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? iconColor,
    double? iconSize,
    LMFeedPostMenuType? menuType,
    LMFeedIcon? menuIcon,
    LMFeedTextStyle? headingStyle,
    LMFeedTextStyle Function(int id, LMFeedTextStyle? style)? menuTitleStyle,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    Border? border,
    bool? showBottomSheetTitle,
    Map<int, LMFeedMenuItemStyle>? menuItemStyle,
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
      menuItemStyle: menuItemStyle ?? this.menuItemStyle,
    );
  }
}

class LMFeedMenuItemStyle {
  LMFeedIcon icon;
  LMFeedTextStyle titleStyle;

  LMFeedMenuItemStyle({
    required this.icon,
    required this.titleStyle,
  });

  LMFeedMenuItemStyle copyWith({
    LMFeedIcon? icon,
    LMFeedTextStyle? titleStyle,
  }) {
    return LMFeedMenuItemStyle(
      icon: icon ?? this.icon,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }
}
