import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';

class LMEmptyCommentWidget extends StatelessWidget {
  const LMEmptyCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(height: 42),
        Text(
          'No comment found',
          style: TextStyle(
            fontSize: LMThemeData.kFontMedium,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Be the first one to comment',
          style: TextStyle(
            fontSize: LMThemeData.kFontSmall,
          ),
        ),
        SizedBox(height: 180),
      ],
    );
  }
}
