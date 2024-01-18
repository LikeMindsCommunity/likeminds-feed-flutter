import 'package:flutter/material.dart';

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
    );
  }
}
