import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedQnAAddResponse extends StatelessWidget {
  final void Function()? onTap;
  final LMFeedProfilePictureBuilder? profilePictureBuilder;
  final LMFeedTextBuilder? textBuilder;
  final LMFeedQnAAddResponseStyle? style;

  const LMFeedQnAAddResponse({
    super.key,
    this.onTap,
    this.profilePictureBuilder,
    this.textBuilder,
    this.style,
  });

  /// copyWith method for updating the style with provided values.
  LMFeedQnAAddResponse copyWith({
    void Function()? onTap,
    LMFeedProfilePictureBuilder? profilePictureBuilder,
    LMFeedTextBuilder? textBuilder,
    LMFeedQnAAddResponseStyle? style,
  }) {
    return LMFeedQnAAddResponse(
      onTap: onTap ?? this.onTap,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      textBuilder: textBuilder ?? this.textBuilder,
      style: style ?? this.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedCore.theme;
    String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;
    return Container(
      decoration: style?.decoration,
      margin: style?.margin,
      padding: style?.padding,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              profilePictureBuilder?.call(
                    context,
                    _defProfilePicture(currentUser, theme),
                  ) ??
                  _defProfilePicture(currentUser, theme),
              const SizedBox(width: 7),
              Expanded(
                child: textBuilder?.call(
                      context,
                      _defText(commentTitleSmallCapSingular),
                    ) ??
                    _defText(commentTitleSmallCapSingular),
              )
            ],
          ),
        ),
      ),
    );
  }

  LMFeedText _defText(String commentTitleSmallCapSingular) {
    return LMFeedText(
      text: "Be the first one to $commentTitleSmallCapSingular",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: LikeMindsTheme.greyColor,
        ),
      ),
    );
  }

  LMFeedProfilePicture _defProfilePicture(
      LMUserViewData currentUser, LMFeedThemeData theme) {
    return LMFeedProfilePicture(
      fallbackText: currentUser.name,
      imageUrl: currentUser.imageUrl,
      onTap: () {},
      style: LMFeedProfilePictureStyle(
        size: 35,
        fallbackTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class LMFeedQnAAddResponseStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxDecoration decoration;

  const LMFeedQnAAddResponseStyle({
    required this.margin,
    required this.padding,
    required this.decoration,
  });

  /// copyWith method for updating the style with provided values.
  LMFeedQnAAddResponseStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return LMFeedQnAAddResponseStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
    );
  }
}
