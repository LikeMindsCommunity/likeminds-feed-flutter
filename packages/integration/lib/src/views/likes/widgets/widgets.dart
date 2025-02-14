import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

Widget noItemLikesView() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 12),
          Text(
            "No likes yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Be the first one to like",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: LMFeedTheme.instance.theme.textSecondary,
            ),
          ),
          SizedBox(height: 28),
        ],
      ),
    );

Widget newPageProgressLikesView() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: LMFeedLoader(),
    );
