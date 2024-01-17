import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedEmptyCommentWidget extends StatelessWidget {
  const LMFeedEmptyCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedTheme.of(context);
    return Container(
      color: theme.backgroundColor,
      child: const Column(
        children: <Widget>[
          SizedBox(
            height: 60,
          ),
          Text(
            'No comment found',
            style: TextStyle(),
          ),
          Text(
            'Be the first one to comment',
            style: TextStyle(),
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
