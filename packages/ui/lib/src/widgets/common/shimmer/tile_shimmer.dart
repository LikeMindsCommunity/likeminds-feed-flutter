import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

class LMFeedTileShimmer extends StatelessWidget {
  const LMFeedTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 16.0,
        bottom: 4.0,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.black26,
        highlightColor: Colors.black12,
        child: Row(
          children: [
            // const SizedBox(
            //   height: 50,
            //   width: 50,
            //   child: CircleAvatar(
            //     backgroundColor: Colors.white,
            //   ),
            // ),
            LikeMindsTheme.kHorizontalPaddingXLarge,
            Container(
              height: 24,
              width: 180,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
