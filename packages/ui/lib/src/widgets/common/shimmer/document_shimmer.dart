import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/theme.dart';
import 'package:shimmer/shimmer.dart';

class LMFeedDocumentShimmer extends StatelessWidget {
  const LMFeedDocumentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius:
              BorderRadius.circular(LikeMindsTheme.kBorderRadiusMedium)),
      padding: const EdgeInsets.all(LikeMindsTheme.kPaddingLarge),
      child: Shimmer.fromColors(
        baseColor: Colors.black26,
        highlightColor: Colors.black12,
        child: Row(children: <Widget>[
          Container(
            height: 40,
            width: 35,
            color: Colors.white,
          ),
          LikeMindsTheme.kHorizontalPaddingLarge,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8,
                width: 150,
                color: Colors.white,
              ),
              LikeMindsTheme.kVerticalPaddingMedium,
              Row(
                children: <Widget>[
                  Container(
                    height: 6,
                    width: 50,
                    color: Colors.white,
                  ),
                  LikeMindsTheme.kHorizontalPaddingXSmall,
                  const Text(
                    '·',
                    style: TextStyle(
                      fontSize: LikeMindsTheme.kFontSmall,
                      color: Colors.grey,
                    ),
                  ),
                  LikeMindsTheme.kHorizontalPaddingXSmall,
                  Container(
                    height: 6,
                    width: 50,
                    color: Colors.white,
                  ),
                ],
              )
            ],
          )
        ]),
      ),
    );
  }
}
