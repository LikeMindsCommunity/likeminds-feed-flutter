import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedPoll extends StatefulWidget {
  const LMFeedPoll({
    super.key,
    required this.attachmentMeta,
    this.onCancel,
    this.onEdit,
    this.isComposable = false,
  });
  final LMAttachmentMetaViewData attachmentMeta;
  final VoidCallback? onCancel;
  final Function(LMAttachmentMetaViewData)? onEdit;
  final bool isComposable;

  @override
  State<LMFeedPoll> createState() => _LMFeedPollState();
}

class _LMFeedPollState extends State<LMFeedPoll> {
  String pollQuestion = '';
  List<String> pollOptions = [];
  String expiryTime = '';
  int multiSelectNo = 0;
  PollMultiSelectState multiSelectState = PollMultiSelectState.exactly;

  void _setPollData() {
    pollQuestion = widget.attachmentMeta.pollQuestion ?? '';
    pollOptions = widget.attachmentMeta.options?.map((e) => e.text).toList() ??
        widget.attachmentMeta.pollOptions ??
        [];
    expiryTime = DateTime.fromMillisecondsSinceEpoch(
            widget.attachmentMeta.expiryTime ?? 0)
        .toString();
    multiSelectNo = widget.attachmentMeta.multiSelectNo ?? 0;
    multiSelectState =
        widget.attachmentMeta.multiSelectState ?? PollMultiSelectState.exactly;
  }

  @override
  void initState() {
    super.initState();
    _setPollData();
  }

  @override
  void didUpdateWidget(covariant LMFeedPoll oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setPollData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
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
                  text: pollQuestion,
                  style: const LMFeedTextStyle(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if(widget.isComposable && widget.onEdit != null)
              LMFeedButton(
                onTap: () {
                  widget.onEdit?.call(widget.attachmentMeta);
                },
                style: const LMFeedButtonStyle(
                    icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.edit,
                )),
              ),
               if(widget.isComposable && widget.onCancel != null)
              LMFeedButton(
                onTap: widget.onCancel ?? () {},
                style: const LMFeedButtonStyle(
                    icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.cancel_outlined,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LMFeedText(
            text:
                "*Select ${multiSelectState.name} ${multiSelectNo} ${multiSelectNo == 1 ? "option" : "options"}.",
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                height: 1.33,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pollOptions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: LMFeedText(
                      text: pollOptions[index],
                      style: const LMFeedTextStyle(
                        textStyle: TextStyle(
                          height: 1.25,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                );
              }),
          LMFeedText(
            text: 'Expires on ${expiryTime}',
            style: const LMFeedTextStyle(
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
