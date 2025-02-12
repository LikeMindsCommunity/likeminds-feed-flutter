import 'package:example_video_feed/app.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

Future<void> main() async {
  // insure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the LikeMinds Feed SDK
  await LMFeedCore.instance.initialize(
    // config: LMFeedConfig(
    //   createShortVideoConfig: LMFeedCreateShortVideoConfig(
    //     builder: ExampleBuilder(),
    //   ),
    //   videoFeedScreenConfig: LMFeedVideoFeedScreenConfig(
    //     builder: FeedScreenBuilder(),
    //   ),
    // ),
  );
  // run the app
  runApp(const LMVideoFeedSampleApp());
}

class FeedScreenBuilder extends LMFeedVideoFeedScreenBuilderDelegate {
  @override
  Widget postViewBuilder(BuildContext context,
      LMFeedVerticalVideoPost postWidget, LMPostViewData postViewData) {
    return postWidget.copyWith(postHeaderBuilder: (context, header, _) {
      return header.copyWith(
        profilePictureBuilder: (context, profile) {
          return profile.copyWith(
            style: profile.style!.copyWith(
              size: 50,
              backgroundColor: Colors.red,
            ),
          );
        },
        // createdAtBuilder: (context, create) {
        //   return create.copyWith(
        //     style: create.style!.copyWith(
        //       textStyle: create.style!.textStyle!.copyWith(
        //         color: Colors.red,
        //       ),
        //     ),
        //   );
        // }
      );
    }, postContentBuilder: (context, content, _) {
      return content.copyWith();
    });
  }
}

class ExampleBuilder extends LMFeedCreateShortVideoBuilderDelegate {
  @override
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
    VoidCallback onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  ) {
    return appBar.copyWith(
      style: appBar.style!.copyWith(
        backgroundColor: Colors.red,
      ),
    );
  }

  // @override
  // Widget videoPreviewContainerBuilder(BuildContext context,
  //     Container videoPreviewContainer, Widget videoPreviewWidget) {
  //   return videoPreviewContainer.copyWith(
  //     // color: Colors.red,
  //     decoration: BoxDecoration(
  //       color: Colors.red,
  //     ),
  //     width: 8000,
  //   );
  // }
}
