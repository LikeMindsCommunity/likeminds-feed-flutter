import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostSomething extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? primaryColor;
  final LMFeedPostSomethingStyle? style;
  final Widget Function(LMFeedProfilePicture profilePicture)?
      profilePictureBuilder;
  final Widget Function(LMFeedText text)? textBuilder;

  const LMFeedPostSomething({
    super.key,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.primaryColor,
    this.style,
    this.profilePictureBuilder,
    this.textBuilder,
  });

  LMFeedPostSomething copyWith({
    VoidCallback? onTap,
    Color? borderColor,
    Color? backgroundColor,
    Color? primaryColor,
    LMFeedPostSomethingStyle? style,
    Widget Function(LMFeedProfilePicture profilePicture)? profilePictureBuilder,
    Widget Function(LMFeedText text)? textBuilder,
  }) {
    return LMFeedPostSomething(
      onTap: onTap ?? this.onTap,
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      style: style ?? this.style,
      profilePictureBuilder:
          profilePictureBuilder ?? this.profilePictureBuilder,
      textBuilder: textBuilder ?? this.textBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    LMUserViewData user = LMFeedLocalPreference.instance.fetchUserData()!;
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: screenSize.width,
        child: Container(
          margin: style?.margin,
          height: style?.height,
          padding: style?.padding,
          decoration: style?.decoration,
          child: Row(
            children: <Widget>[
              profilePictureBuilder
                      ?.call(_defProfilePicture(user, feedTheme)) ??
                  _defProfilePicture(user, feedTheme),
              LikeMindsTheme.kHorizontalPaddingMedium,
              textBuilder?.call(const LMFeedText(text: "Post something...")) ??
                  const LMFeedText(text: "Post something...")
            ],
          ),
        ),
      ),
    );
  }

  LMFeedProfilePicture _defProfilePicture(
      LMUserViewData user, LMFeedThemeData feedTheme) {
    return LMFeedProfilePicture(
      fallbackText: user.name,
      style: LMFeedProfilePictureStyle(
        boxShape: BoxShape.circle,
        backgroundColor: feedTheme.primaryColor,
        size: 36,
      ),
      imageUrl: user.imageUrl,
      onTap: () {
        LMFeedCore.client.routeToProfile(user.sdkClientInfo.uuid);
      },
    );
  }
}

class LMFeedPostSomethingStyle {
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? primaryColor;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const LMFeedPostSomethingStyle({
    this.borderColor,
    this.backgroundColor,
    this.primaryColor,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.decoration,
  });

  LMFeedPostSomethingStyle copyWith({
    Color? borderColor,
    Color? backgroundColor,
    Color? primaryColor,
    double? height,
    double? width,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return LMFeedPostSomethingStyle(
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      height: height ?? this.height,
      width: width ?? this.width,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
    );
  }

  factory LMFeedPostSomethingStyle.basic({LMFeedThemeData? theme}) {
    return LMFeedPostSomethingStyle(
      borderColor: theme?.disabledColor,
      backgroundColor: theme?.container,
      primaryColor: theme?.primaryColor,
      height: 60,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: theme?.container,
        border: Border.all(
          width: 1,
          color: theme?.disabledColor ?? Colors.grey,
        ),
      ),
    );
  }
}
