import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/profile_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/profile_header_widget.dart';

class LMQnAProfileBottomSheet extends StatefulWidget {
  const LMQnAProfileBottomSheet({
    super.key,
    required this.uuid,
  });
  final String uuid;

  @override
  State<LMQnAProfileBottomSheet> createState() =>
      _LMQnAProfileBottomSheetState();
}

class _LMQnAProfileBottomSheetState extends State<LMQnAProfileBottomSheet>
    with TickerProviderStateMixin {
  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: feedThemeData.container,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LMQnAProfileHeaderWidget(
                  uuid: widget.uuid,
                  showEditButton: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: double.infinity,
                    child: LMFeedButton(
                      style: LMFeedButtonStyle(
                          borderRadius: 100,
                          border: Border.all(color: textPrimary),
                          padding: const EdgeInsets.all(15)),
                      text: const LMFeedText(
                        text: 'View full profile',
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LMQnAProfileScreen(
                                      uuid: widget.uuid,
                                    )));
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
