import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/topic/topic_level_bottom_sheet.dart';

class LMFeedTopicSelectBottomSheet extends StatefulWidget {
  final LMFeedBottomSheetStyle? style;

  const LMFeedTopicSelectBottomSheet({
    super.key,
    this.style,
  });

  @override
  State<LMFeedTopicSelectBottomSheet> createState() =>
      _LMFeedTopicSelectBottomSheetState();
}

class _LMFeedTopicSelectBottomSheetState
    extends State<LMFeedTopicSelectBottomSheet> {
  Map<String, LMTopicViewData> levels = {};
  Map<String, List<LMTopicViewData>> topicsPerLevel = {};
  Map<String, List<LMTopicViewData>> selectedTopicsPerLevel = {};

  final List<String> popularCountries = const [
    "India",
    "USA",
    "UAE",
    "Vietnam",
    "Russia",
    "Thailand",
  ];

  final List<String> topics = const [
    "Tax",
    "Insurance",
    "Education",
    "Fintips",
    "Visa",
    "Loan",
  ];

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return LMFeedBottomSheet(
      style: widget.style,
      title: LMFeedText(
        text: "Select Tags",
        style: LMFeedTextStyle(
            textStyle: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w600,
        )),
      ),
      children: [
        const SizedBox(
          height: 20,
        ),
        LMFeedText(
          text: "Popular Countries",
          style: LMFeedTextStyle(
              textStyle: TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          )),
        ),
        const SizedBox(
          height: 15,
        ),
        Wrap(
          children: popularCountries
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: LMFeedBottomSheet(
                              children: <Widget>[
                                Container(
                                  width: 300,
                                  height: 300,
                                  color: Colors.white,
                                )
                              ],
                              style: widget.style ?? feedTheme.bottomSheetStyle,
                            ),
                          );
                        });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: feedTheme.disabledColor,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    margin: EdgeInsets.only(right: 10, bottom: 10.0),
                    child: LMFeedText(
                      text: e,
                      style: LMFeedTextStyle(
                          textStyle: TextStyle(
                        fontSize: 12,
                        height: 1.75,
                        fontWeight: FontWeight.w400,
                      )),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(
          height: 20,
        ),
        LMFeedText(
          text: "Topics",
          style: LMFeedTextStyle(
              textStyle: TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          )),
        ),
        const SizedBox(
          height: 15,
        ),
        Wrap(
          children: topics
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: LMFeedTopicLevelBottomSheet(
                              style: widget.style,
                            ),
                          );
                        });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: feedTheme.disabledColor,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    margin: EdgeInsets.only(right: 10, bottom: 10.0),
                    child: LMFeedText(
                      text: e,
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 12,
                          height: 1.75,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(
          height: 20,
        ),
        LMFeedButton(
          onTap: () {},
          style: LMFeedButtonStyle(
              padding: EdgeInsets.all(15.0),
              backgroundColor: Colors.black87,
              borderRadius: 50.0),
          text: LMFeedText(
            text: "Done",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
