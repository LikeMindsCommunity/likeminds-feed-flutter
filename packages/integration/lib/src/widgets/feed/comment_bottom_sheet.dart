import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_comment_bottom_sheet}
/// A widget that displays the comments of a post in a bottom sheet.
/// It handles the display of comments and the input of new comments.
/// customize the appearance of the [LMFeedCommentBottomSheet] using the [LMFeedCommentBottomSheetStyle].
/// and provided builders
/// {@endtemplate}
class LMFeedCommentBottomSheet extends StatefulWidget {
  const LMFeedCommentBottomSheet({
    super.key,
    required this.postId,
    this.style,
    this.titleBuilder,
    this.bottomTextFieldBuilder,
    this.commentListBuilder,
  });

  /// The id of the post for which the comments are to be displayed.
  final String postId;

  /// style of the [LMFeedCommentBottomSheet].
  final LMFeedCommentBottomSheetStyle? style;

  final LMFeedTextBuilder? titleBuilder;
  final Widget Function(
    BuildContext,
    LMFeedBottomTextField,
    TextEditingController,
    FocusNode,
  )? bottomTextFieldBuilder;
  final LMFeedCommentListBuilder? commentListBuilder;

  /// Creates a copy of this [LMFeedCommentBottomSheet] but with the given fields
  /// replaced with the new values.
  ///
  /// This method allows you to create a new instance of [LMFeedCommentBottomSheet]
  /// with some properties modified while keeping the rest unchanged.
  LMFeedCommentBottomSheet copyWith({
    String? postId,
    LMFeedCommentBottomSheetStyle? style,
    LMFeedTextBuilder? titleBuilder,
    Widget Function(
      BuildContext context,
      LMFeedBottomTextField bottomTextField,
      TextEditingController controller,
      FocusNode focusNode,
    )? bottomTextFieldBuilder,
    LMFeedCommentListBuilder? commentListBuilder,
  }) {
    return LMFeedCommentBottomSheet(
      postId: postId ?? this.postId,
      style: style ?? this.style,
      titleBuilder: titleBuilder ?? this.titleBuilder,
      bottomTextFieldBuilder:
          bottomTextFieldBuilder ?? this.bottomTextFieldBuilder,
      commentListBuilder: commentListBuilder ?? this.commentListBuilder,
    );
  }

  @override
  State<LMFeedCommentBottomSheet> createState() =>
      _LMFeedCommentBottomSheetState();
}

class _LMFeedCommentBottomSheetState extends State<LMFeedCommentBottomSheet>
    with TickerProviderStateMixin {
  LMFeedThemeData _theme = LMFeedTheme.instance.theme;
  final _commentText = LMFeedPostUtils.getCommentTitle(
    LMFeedPluralizeWordAction.firstLetterCapitalPlural,
  );
  final FocusNode _commentFocusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: widget.style?.enableDrag ?? true,
      showDragHandle: widget.style?.showDragHandle,
      dragHandleColor: widget.style?.dragHandleColor,
      dragHandleSize: widget.style?.dragHandleSize,
      backgroundColor: widget.style?.backgroundColor,
      shadowColor: widget.style?.shadowColor,
      elevation: widget.style?.elevation,
      shape: widget.style?.shape,
      clipBehavior: widget.style?.clipBehavior,
      constraints: widget.style?.constraints,
      animationController: BottomSheet.createAnimationController(this),
      onClosing: () {},
      builder: (context) => Padding(
        padding: widget.style?.padding ??
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: widget.titleBuilder?.call(
                    context,
                    _defTitle(),
                  ) ??
                  _defTitle(),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.40,
              child: CustomScrollView(
                slivers: [
                  widget.commentListBuilder?.call(
                        context,
                        LMFeedCommentList(
                          postId: widget.postId,
                        ),
                      ) ??
                      LMFeedCommentList(
                        postId: widget.postId,
                      ),
                ],
              ),
            ),
            widget.bottomTextFieldBuilder?.call(
                  context,
                  _defBottomTextField(),
                  _commentController,
                  _commentFocusNode,
                ) ??
                _defBottomTextField(),
          ],
        ),
      ),
    );
  }

  LMFeedBottomTextField _defBottomTextField() {
    return LMFeedBottomTextField(
      postId: widget.postId,
      focusNode: _commentFocusNode,
      controller: _commentController,
      style: LMFeedBottomTextFieldStyle(
        maxLines: 3,
      ),
    );
  }

  LMFeedText _defTitle() {
    return LMFeedText(
      text: _commentText,
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _theme.onContainer,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template lm_feed_comment_bottom_sheet_style}
/// A style class for customizing the appearance of the [LMFeedCommentBottomSheet].
/// use this class to customize the appearance of the [LMFeedCommentBottomSheet].
/// {@endtemplate}
class LMFeedCommentBottomSheetStyle {
  bool? enableDrag;
  bool? showDragHandle;
  Color? dragHandleColor;
  Size? dragHandleSize;
  Color? backgroundColor;
  Color? shadowColor;
  double? elevation;
  ShapeBorder? shape;
  Clip? clipBehavior;
  BoxConstraints? constraints;
  EdgeInsetsGeometry? padding;

  LMFeedCommentBottomSheetStyle({
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

  /// copyWith() method to create a new instance of [LMFeedCommentBottomSheetStyle] with the same properties
  /// of the current instance and replace the provided values.
  LMFeedCommentBottomSheetStyle copyWith({
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
    return LMFeedCommentBottomSheetStyle(
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
