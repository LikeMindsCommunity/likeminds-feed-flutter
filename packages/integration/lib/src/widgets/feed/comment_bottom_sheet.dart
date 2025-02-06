import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCommentBottomSheet extends StatefulWidget {
  const LMFeedCommentBottomSheet({
    super.key,
    required this.postId,
  });
  final String postId;

  @override
  State<LMFeedCommentBottomSheet> createState() =>
      _LMFeedCommentBottomSheetState();
}

class _LMFeedCommentBottomSheetState extends State<LMFeedCommentBottomSheet>
    with TickerProviderStateMixin {
  LMFeedThemeData _theme = LMFeedTheme.instance.theme;
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      animationController: BottomSheet.createAnimationController(this),
      onClosing: () {},
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: LMFeedText(
                text: 'Comments',
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
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.45,
              child: CustomScrollView(
                slivers: [
                  LMFeedCommentList(postId: widget.postId),
                ],
              ),
            ),
            LMFeedBottomTextField(
              postId: widget.postId,
            ),
          ],
        ),
      ),
    );
  }
}
