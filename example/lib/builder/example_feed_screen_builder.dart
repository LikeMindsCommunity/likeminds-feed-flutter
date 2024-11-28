import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class ExampleLMFeedScreenBuilderDelegate
    implements LMFeedSocialScreenBuilderDelegate {
  @override
  Widget pendingPostBannerBuilder(BuildContext context, int pendingPostCount,
      LMFeedPendingPostBanner pendingPostBanner) {
    return pendingPostBanner.copyWith(onPendingPostBannerPressed: () {
      showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          builder: (context) {
            return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: TextButton(
                          onPressed: () {
                            pendingPostBanner.onPendingPostBannerPressed
                                ?.call();
                          },
                          child: const Text('Pending Post Banner Pressed')),
                    ),
                  );
                });
          });
    });
  }
}
