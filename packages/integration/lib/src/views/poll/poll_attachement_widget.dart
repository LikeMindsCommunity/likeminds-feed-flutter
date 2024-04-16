import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class PollAttachment extends StatelessWidget {
  const PollAttachment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: LMFeedText(
                  text:
                      'Which Zoom features (1 or more) do you use most for your events/classes?',
                  style: LMFeedTextStyle(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              LMFeedButton(
                onTap: () {},
                style: LMFeedButtonStyle(
                    icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.edit,
                )),
              ),
              LMFeedButton(
                onTap: () {},
                style: LMFeedButtonStyle(
                    icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.cancel_outlined,
                )),
              ),
            ],
          ),
          SizedBox(height: 8),
          LMFeedText(
            text: "*Select at most 2 options.",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                height: 1.33,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          // SizedBox(height: 8),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: LMFeedText(
                      text: 'Spotlight',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          height: 1.25,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                );
              }),

          LMFeedText(
            text: 'Expires on 27 Jun 2023 12:00 PM',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                height: 1.33,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
