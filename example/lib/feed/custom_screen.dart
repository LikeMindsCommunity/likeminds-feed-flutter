import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class ClientCustomScreen extends LMFeedPostDetailScreen {
  const ClientCustomScreen({
    super.key,
    required super.postId,
  });

  // @override
  // final String postId;

  // ClientCustomScreen({
  //   super.key,
  //   required this.postId,
  // }) : super(
  //         postId: postId,
  //         appBarBuilder: appBarBuilder,
  //       ); // : super(
  // //       postId: postId,
  // //       appBarBuilder: (c, p) {
  // //         return this.appBar(c, p);
  // //       });

  // @override
  // final LMFeedPostAppBarBuilder? appBarBuilder =
  //     (context, post) => appBar(context, post);
}

PreferredSizeWidget appBar(BuildContext context, LMPostViewData post) {
  return const LMFeedAppBar(
    title: LMFeedText(text: "Custom APPBAR"),
  );
}
