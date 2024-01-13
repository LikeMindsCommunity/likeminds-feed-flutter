import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';

class LMFeedLoader extends StatelessWidget {
  final bool isPrimary;
  final Color? color;

  const LMFeedLoader({super.key, this.isPrimary = true, this.color});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ??
            (isPrimary ? LMFeedTheme.of(context).primaryColor : Colors.white),
      ),
    );
  }
}
