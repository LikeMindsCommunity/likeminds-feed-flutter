import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/ui_constants.dart';

class LMFeedEmptyCommentWidget extends StatelessWidget {
  const LMFeedEmptyCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(
          height: 60,
        ),
        Text(
          'No comment found',
          style: TextStyle(
            fontSize: LMThemeData.kFontMedium,
          ),
        ),
        Text(
          'Be the first one to comment',
          style: TextStyle(
            fontSize: LMThemeData.kFontSmall,
          ),
        ),
      ],
    );
  }
}
