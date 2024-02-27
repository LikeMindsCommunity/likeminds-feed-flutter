import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedTopicLevelBottomSheet extends StatefulWidget {
  final LMTopicViewData? level;
  final LMFeedBottomSheetStyle? style;
  const LMFeedTopicLevelBottomSheet({super.key, this.level, this.style});

  @override
  State<LMFeedTopicLevelBottomSheet> createState() =>
      _LMFeedTopicLevelBottomSheetState();
}

class _LMFeedTopicLevelBottomSheetState
    extends State<LMFeedTopicLevelBottomSheet> {
  List<String> selectedTopics = [
    "India",
    "USA",
  ];

  Set<String> selectedTopicsSet = {
    "India",
    "USA",
  };

  List<String> popularCountries = const [
    "India",
    "USA",
    "UAE",
    "Vietnam",
    "Russia",
    "Thailand",
  ];

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return LMFeedBottomSheet(
      style: widget.style ??
          feedTheme.bottomSheetStyle.copyWith(padding: EdgeInsets.zero),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: LMFeedText(
            text: "Destination",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                height: 1.25,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: feedTheme.disabledColor,
              ),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Row(
              children: <Widget>[
                LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.search,
                  style: LMFeedIconStyle(
                    color: feedTheme.onContainer,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                      decoration: feedTheme.textFieldStyle.decoration
                          ?.copyWith(hintText: "Search Country")),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Divider(
          height: 5,
          thickness: 5,
          color: feedTheme.disabledColor,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: popularCountries.length,
          itemBuilder: (context, index) {
            String topic = popularCountries[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                if (selectedTopicsSet.contains(topic)) {
                  selectedTopicsSet.remove(topic);
                  selectedTopics.remove(topic);
                } else {
                  selectedTopicsSet.add(topic);
                  selectedTopics.add(topic);
                }
                setState(() {});
              },
              leading: Checkbox(
                value: selectedTopics.contains(topic),
                activeColor: feedTheme.primaryColor,
                onChanged: (value) {
                  if (selectedTopicsSet.contains(topic)) {
                    selectedTopicsSet.remove(topic);
                    selectedTopics.remove(topic);
                  } else {
                    selectedTopicsSet.add(topic);
                    selectedTopics.add(topic);
                  }
                  setState(() {});
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
              title: LMFeedText(
                text: topic,
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
