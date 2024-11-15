import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedTopResponseWidget extends StatefulWidget {
  /// The comment data to be displayed.
  final LMCommentViewData comment;

  /// The post data to be displayed.
  final LMPostViewData postViewData;

  /// The builder for the header text.
  final LMFeedTextBuilder? headerTextBuilder;

  /// The builder for the title text.
  final LMFeedTextBuilder? titleTextBuilder;

  /// The builder for the subtitle text.
  final LMFeedTextBuilder? subTitleTextBuilder;

  /// The builder for the profile picture.
  final LMFeedProfilePictureBuilder? profilePictureBuilder;

  /// The builder for the comment text.
  final Widget Function(
    BuildContext context,
    LMFeedExpandableText text,
  )? commentTextBuilder;

  /// style for the widget
  final LMFeedTopResponseWidgetStyle? style;

  const LMFeedTopResponseWidget({
    super.key,
    required this.postViewData,
    required this.comment,
    this.headerTextBuilder,
    this.titleTextBuilder,
    this.subTitleTextBuilder,
    this.commentTextBuilder,
    this.profilePictureBuilder,
    this.style,
  });

  /// copyWith method for updating the style with provided values.
  LMFeedTopResponseWidget copyWith({
    LMCommentViewData? comment,
    LMPostViewData? postViewData,
    LMFeedTextBuilder? headerTextBuilder,
    LMFeedTextBuilder? titleTextBuilder,
    LMFeedTextBuilder? subTitleTextBuilder,
    LMFeedProfilePictureBuilder? profilePictureBuilder,
    Widget Function(
      BuildContext context,
      LMFeedExpandableText text,
    )? commentTextBuilder,
    LMFeedTopResponseWidgetStyle? style,
  }) {
    return LMFeedTopResponseWidget(
      comment: comment ?? this.comment,
      postViewData: postViewData ?? this.postViewData,
      headerTextBuilder: headerTextBuilder ?? this.headerTextBuilder,
      titleTextBuilder: titleTextBuilder ?? this.titleTextBuilder,
      subTitleTextBuilder: subTitleTextBuilder ?? this.subTitleTextBuilder,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      commentTextBuilder: commentTextBuilder ?? this.commentTextBuilder,
      style: style ?? this.style,
    );
  }

  @override
  State<LMFeedTopResponseWidget> createState() =>
      _LMFeedTopResponseWidgetState();
}

class _LMFeedTopResponseWidgetState extends State<LMFeedTopResponseWidget> {
  LMCommentViewData? commentViewData;
  LMPostViewData? postViewData;
  LMUserViewData? commentCreator;

  String commentTitle = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  @override
  void initState() {
    super.initState();
    commentViewData = widget.comment;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
  }

  @override
  void didUpdateWidget(covariant LMFeedTopResponseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    commentViewData = widget.comment;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.style?.decoration,
      margin: widget.style?.margin,
      padding:
          widget.style?.padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.headerTextBuilder?.call(context, _defHeaderText()) ??
              _defHeaderText(),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.profilePictureBuilder?.call(
                    context,
                    _defProfilePicture(context),
                  ) ??
                  _defProfilePicture(context),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Container(
                  margin: widget.style?.containerMargin,
                  padding: widget.style?.containerPadding ??
                      const EdgeInsets.all(10.0),
                  decoration: widget.style?.containerDecoration ??
                      BoxDecoration(
                        color: LikeMindsTheme.unSelectedColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          LMFeedProfileBloc.instance.add(
                            LMFeedRouteToUserProfileEvent(
                              uuid: widget.comment.user.uuid,
                              context: context,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.titleTextBuilder
                                    ?.call(context, _defUserNameText()) ??
                                _defUserNameText(),
                            widget.subTitleTextBuilder
                                    ?.call(context, _defTimeStamp()) ??
                                _defTimeStamp(),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      widget.commentTextBuilder?.call(
                            context,
                            _defCommentText(context),
                          ) ??
                          _defCommentText(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  LMFeedExpandableText _defCommentText(BuildContext context) {
    return LMFeedExpandableText(
     widget.comment.text,
      expandText: "Read More",
      prefixStyle: const TextStyle(
        // color: textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.66,
      ),
      expandOnTextTap: true,
      onTagTap: (String uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        // color: textSecondary,
        height: 1.66,
      ),
      maxLines: 4,
    );
  }

  LMFeedText _defTimeStamp() {
    return LMFeedText(
      text: "${LMFeedTimeAgo.instance.format(postViewData!.createdAt)}",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          color: LMFeedCore.theme.inActiveColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  LMFeedText _defUserNameText() {
    return LMFeedText(
      text: widget.comment.user.name,
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          // color: textSecondary,
        ),
      ),
    );
  }

  LMFeedProfilePicture _defProfilePicture(BuildContext context) {
    return LMFeedProfilePicture(
      fallbackText: widget.comment.user.name,
      imageUrl: widget.comment.user.imageUrl ?? "",
      style: LMFeedProfilePictureStyle(
        size: 35,
        fallbackTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      onTap: () {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: widget.comment.user.uuid,
            context: context,
          ),
        );
      },
    );
  }

  LMFeedText _defHeaderText() {
    return LMFeedText(
      text: "Top Response",
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          // color: textTertiary,
        ),
      ),
    );
  }
}

class LMFeedTopResponseWidgetStyle {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final EdgeInsets? containerPadding;
  final EdgeInsets? containerMargin;
  final BoxDecoration? containerDecoration;

  const LMFeedTopResponseWidgetStyle({
    this.margin,
    this.padding,
    this.decoration,
    this.containerPadding,
    this.containerMargin,
    this.containerDecoration,
  });

  LMFeedTopResponseWidgetStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxDecoration? decoration,
    EdgeInsets? containerPadding,
    EdgeInsets? containerMargin,
    BoxDecoration? containerDecoration,
  }) {
    return LMFeedTopResponseWidgetStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      containerPadding: containerPadding ?? this.containerPadding,
      containerMargin: containerMargin ?? this.containerMargin,
      containerDecoration: containerDecoration ?? this.containerDecoration,
    );
  }

  /// default style for the widget
  factory LMFeedTopResponseWidgetStyle.basic() {
    return LMFeedTopResponseWidgetStyle(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      containerPadding: const EdgeInsets.all(10.0),
      containerDecoration: BoxDecoration(
        color: LikeMindsTheme.unSelectedColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
