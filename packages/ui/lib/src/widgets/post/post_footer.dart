import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/buttons/button.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/icon/icon.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/common/text/text_view.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/post/style/post_footer_style.dart';

class LMPostFooter extends StatelessWidget {
  LMPostFooter({super.key, this.postFooterStyle});

  final LMPostFooterStyle? postFooterStyle;

  final _footerChildren = <Widget>[];

  @override
  Widget build(BuildContext context) {
    _populateButtonList();
    return Row(
      mainAxisAlignment: postFooterStyle?.alignment ?? MainAxisAlignment.start,
      children: _footerChildren,
    );
  }

  void _populateButtonList() {
    if (postFooterStyle == null) return;

    if (postFooterStyle?.showCommentButton ?? true) {
      LMButton commentButton = LMButton(
        text: (postFooterStyle?.commentButtonStyle?.showText ?? true)
            ? LMTextView(
                text: postFooterStyle?.commentButtonStyle?.inactiveText ??
                    "Comment")
            : null,
        activeText: (postFooterStyle?.commentButtonStyle?.showText ?? true)
            ? LMTextView(
                text: postFooterStyle?.commentButtonStyle?.activeText ??
                    "Comment")
            : null,
        onTap: () {},
        icon: postFooterStyle?.commentButtonStyle?.inactiveIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.message_outlined,
              color: postFooterStyle?.inactiveColor,
              size: 28,
            ),
        activeIcon: postFooterStyle?.commentButtonStyle?.activeIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.message_outlined,
              size: 28,
              color: postFooterStyle?.activeColor,
            ),
      );
      _footerChildren.add(commentButton);
    }

    if (postFooterStyle?.showLikeButton ?? true) {
      LMButton likeButton = LMButton(
        text: (postFooterStyle?.likeButtonStyle?.showText ?? true)
            ? LMTextView(
                text: postFooterStyle?.likeButtonStyle?.inactiveText ?? "Like")
            : null,
        onTap: () {},
        icon: postFooterStyle?.likeButtonStyle?.inactiveIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.favorite_outline,
              size: 28,
              color: postFooterStyle?.inactiveColor,
            ),
        activeIcon: postFooterStyle?.likeButtonStyle?.activeIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.favorite,
              size: 28,
              color: postFooterStyle?.activeColor,
            ),
      );
      _footerChildren.add(likeButton);
    }

    if (postFooterStyle?.showSaveButton ?? true) {
      LMButton saveButton = LMButton(
        icon: postFooterStyle?.saveButtonStyle?.inactiveIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.bookmark_border_outlined,
              size: 28,
              color: postFooterStyle?.inactiveColor,
            ),
        activeIcon: postFooterStyle?.saveButtonStyle?.activeIcon ??
            LMIcon(
              type: LMIconType.icon,
              icon: Icons.bookmark_border_outlined,
              size: 28,
              color: postFooterStyle?.activeColor,
            ),
        onTap: () {},
        text: postFooterStyle?.saveButtonStyle?.showText ?? true
            ? LMTextView(
                text: postFooterStyle?.saveButtonStyle?.inactiveText ?? "Save")
            : null,
        activeText: postFooterStyle?.saveButtonStyle?.showText ?? true
            ? LMTextView(
                text: postFooterStyle?.saveButtonStyle?.activeText ?? "Save")
            : null,
      );
      _footerChildren.add(saveButton);
    }

    if (postFooterStyle?.showShareButton ?? true) {
      LMButton shareButton = LMButton(
        icon: postFooterStyle?.shareButtonStyle?.activeIcon ??
            const LMIcon(
              type: LMIconType.icon,
              icon: Icons.share_outlined,
              size: 28,
            ),
        activeIcon: postFooterStyle?.shareButtonStyle?.activeIcon ??
            const LMIcon(
              type: LMIconType.icon,
              icon: Icons.share_outlined,
              size: 28,
            ),
        text: postFooterStyle?.shareButtonStyle?.showText ?? true
            ? LMTextView(
                text:
                    postFooterStyle?.shareButtonStyle?.inactiveText ?? "Share")
            : null,
        activeText: postFooterStyle?.shareButtonStyle?.showText ?? true
            ? LMTextView(
                text: postFooterStyle?.shareButtonStyle?.activeText ?? "Share")
            : null,
        onTap: () {},
      );
      _footerChildren.add(shareButton);
    }
  }
}

// class LMLikeButton extends LMTextView {
//   LMLikeButton({
//     super.key,
//     ValueNotifier<bool>? rebuildLikeButton,
//   })  : _rebuildLikeButton = rebuildLikeButton,
//         super(text: "Like");

//   final ValueNotifier<bool>? _rebuildLikeButton;

//   @override
//   Widget build(BuildContext context) {
//     return LMTextView(
//       text: "Like",
//       valueNotifier: _rebuildLikeButton,
//       leadingIcon: const LMIcon(
//         inactiveIcon: Icon(
//           Icons.favorite_outline,
//         ),
//         activeIcon: Icon(
//           Icons.favorite,
//           color: kPrimaryColor,
//         ),
//       ),
//       activeTextStyle:
//        Theme.of(context).textTheme.bodyLarge!.copyWith(color: kPrimaryColor),
//       inactiveTextStyle: Theme.of(context).textTheme.bodyLarge,
//     );
//   }
// }

// class LMCommentButton extends StatefulWidget {
//   LMCommentButton({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LMTextView(
//       text: "Comment",
//       textStyle:
//       Theme.of(context).textTheme.bodyLarge!.copyWith(color: kPrimaryColor),
//     );
//   }
// }

// class LMSaveButton extends LMTextView {
//   LMSaveButton({
//     super.key,
//     ValueNotifier<bool>? rebuildSaveButton,
//   })  : _rebuildSaveButton = rebuildSaveButton,
//         super(text: "Save");

//   final ValueNotifier<bool>? _rebuildSaveButton;

//   @override
//   Widget build(BuildContext context) {
//     return LMTextView(
//       text: "",
//       valueNotifier: _rebuildSaveButton,
//       leadingIcon: const LMIcon(
//         inactiveIcon: Icon(
//           Icons.bookmark_border,
//         ),
//         activeIcon: Icon(
//           Icons.bookmark,
//           color: kPrimaryColor,
//         ),
//       ),
//       activeTextStyle:
//       Theme.of(context).textTheme.bodyLarge!.copyWith(color: kPrimaryColor),
//       inactiveTextStyle: Theme.of(context).textTheme.bodyLarge,
//     );
//   }
// }

// class LMShareButton extends LMTextView {
//   LMShareButton({
//     super.key,
//     ValueNotifier<bool>? rebuildShareButton,
//   })  : _rebuildShareButton = rebuildShareButton,
//         super(text: "Save");

//   final ValueNotifier<bool>? _rebuildShareButton;

//   @override
//   Widget build(BuildContext context) {
//     return LMTextView(
//       text: "",
//       valueNotifier: _rebuildShareButton,
//       leadingIcon: const LMIcon(
//         inactiveIcon: Icon(
//           Icons.share_outlined,
//         ),
//         activeIcon: Icon(
//           Icons.share,
//           color: kPrimaryColor,
//         ),
//       ),
//       activeTextStyle:
//        Theme.of(context).textTheme.bodyLarge!.copyWith(color: kPrimaryColor),
//       inactiveTextStyle: Theme.of(context).textTheme.bodyLarge,
//     );
//   }
// }
