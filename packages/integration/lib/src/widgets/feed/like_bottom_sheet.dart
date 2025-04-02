import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedLikeListBottomSheet extends StatefulWidget {
  const LMFeedLikeListBottomSheet({
    super.key,
    required this.postViewData,
    this.style,
    required this.widgetSource,
    this.titleBuilder,
    this.likeListBuilder,
  });

  final LMPostViewData postViewData;
  final LMFeedWidgetSource widgetSource;
  final LMFeedLikeListBottomSheetStyle? style;
  final LMFeedTextBuilder? titleBuilder;
  final Widget Function(BuildContext context, LMFeedLikeListView likeListView)?
      likeListBuilder;

  /// Creates a copy of this [LMFeedLikeListBottomSheet] but with the given fields
  /// replaced with the new values.
  LMFeedLikeListBottomSheet copyWith({
    LMPostViewData? postViewData,
    LMFeedWidgetSource? widgetSource,
    LMFeedLikeListBottomSheetStyle? style,
    LMFeedTextBuilder? titleBuilder,
    Widget Function(BuildContext context, LMFeedLikeListView likeListView)?
        likeListBuilder,
  }) {
    return LMFeedLikeListBottomSheet(
      postViewData: postViewData ?? this.postViewData,
      widgetSource: widgetSource ?? this.widgetSource,
      style: style ?? this.style,
      titleBuilder: titleBuilder ?? this.titleBuilder,
      likeListBuilder: likeListBuilder ?? this.likeListBuilder,
    );
  }

  @override
  State<LMFeedLikeListBottomSheet> createState() =>
      _LMFeedLikeListBottomSheetState();
}

class _LMFeedLikeListBottomSheetState extends State<LMFeedLikeListBottomSheet>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        enableDrag: widget.style?.enableDrag ?? true,
        showDragHandle: widget.style?.showDragHandle ?? true,
        dragHandleColor: widget.style?.dragHandleColor,
        dragHandleSize: widget.style?.dragHandleSize,
        backgroundColor: widget.style?.backgroundColor ??
            LMFeedTheme.instance.theme.container,
        shadowColor: widget.style?.shadowColor,
        elevation: widget.style?.elevation ?? 0,
        shape: widget.style?.shape,
        clipBehavior: widget.style?.clipBehavior ?? Clip.antiAlias,
        animationController: BottomSheet.createAnimationController(this),
        constraints: widget.style?.constraints ??
            BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
        onClosing: () {},
        builder: (context) {
          return Padding(
            padding: widget.style?.padding ?? const EdgeInsets.all(8.0),
            child: Column(
              children: [
                widget.titleBuilder?.call(
                      context,
                      _defTitle(),
                    ) ??
                    _defTitle(),
                Expanded(
                  child: widget.likeListBuilder?.call(
                        context,
                        LMFeedLikeListView(
                          postId: widget.postViewData.id,
                          widgetSource: widget.widgetSource,
                        ),
                      ) ??
                      LMFeedLikeListView(
                        postId: widget.postViewData.id,
                        widgetSource: widget.widgetSource,
                      ),
                ),
              ],
            ),
          );
        });
  }

  LMFeedText _defTitle() {
    return LMFeedText(
      text: "Liked",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// {@template lm_feed_like_list_bottom_sheet_style}
/// A style class for customizing the appearance of the [LMFeedLikeListBottomSheet].
/// Use this class to customize the appearance of the [LMFeedLikeListBottomSheet].
/// {@endtemplate}
class LMFeedLikeListBottomSheetStyle {
  final bool? enableDrag;
  final bool? showDragHandle;
  final Color? dragHandleColor;
  final Size? dragHandleSize;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;

  LMFeedLikeListBottomSheetStyle({
    this.enableDrag,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleSize,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.padding,
  });

  /// copyWith() method to create a new instance of [LMFeedLikeListBottomSheetStyle] with the same properties
  /// of the current instance and replace the provided values.
  LMFeedLikeListBottomSheetStyle copyWith({
    bool? enableDrag,
    bool? showDragHandle,
    Color? dragHandleColor,
    Size? dragHandleSize,
    Color? backgroundColor,
    Color? shadowColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  }) {
    return LMFeedLikeListBottomSheetStyle(
      enableDrag: enableDrag ?? this.enableDrag,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      dragHandleSize: dragHandleSize ?? this.dragHandleSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      constraints: constraints ?? this.constraints,
      padding: padding ?? this.padding,
    );
  }
}
