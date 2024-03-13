import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedEmptyCommentWidget extends StatelessWidget {
  const LMFeedEmptyCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 60,
        ),
        Text(
          'No comments found!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: feedTheme.onContainer,
            fontSize: 16,
          ),
        ),
        Text(
          'Be the first one to comment',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: feedTheme.onContainer,
            fontSize: 14,
          ),
        ),
        SizedBox(
          height: 60,
        ),
      ],
    );
  }
}
