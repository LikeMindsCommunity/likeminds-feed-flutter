import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/poll/poll_style.dart';

class LMFeedPoll extends StatefulWidget {
  const LMFeedPoll({
    super.key,
    required this.attachmentMeta,
    this.onCancel,
    this.onEdit,
    this.style = const LMFeedPollStyle(),
    this.onOptionSelect,
    this.showSubmitButton = false,
    this.showAddOptionButton = false,
    this.showTick,
  });
  final LMAttachmentMetaViewData attachmentMeta;
  final VoidCallback? onCancel;
  final Function(LMAttachmentMetaViewData)? onEdit;
  final LMFeedPollStyle style;
  final void Function(LMPostOptionViewData)? onOptionSelect;
  final bool showSubmitButton;
  final bool showAddOptionButton;
  final bool Function(LMPostOptionViewData optionViewData)? showTick;
  @override
  State<LMFeedPoll> createState() => _LMFeedPollState();
}

class _LMFeedPollState extends State<LMFeedPoll> {
  String pollQuestion = '';
  List<String> pollOptions = [];
  String expiryTime = '';
  int multiSelectNo = 0;
  PollMultiSelectState multiSelectState = PollMultiSelectState.exactly;
  late LMFeedPollStyle _lmFeedPollStyle;
  final theme = LMFeedTheme.instance.theme;

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
    _lmFeedPollStyle = widget.style;
    _setPollData();
  }

  @override
  void didUpdateWidget(covariant LMFeedPoll oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lmFeedPollStyle = widget.style;
    _setPollData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _lmFeedPollStyle.margin ??
          const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
      padding: const EdgeInsets.all(16),
      decoration: _lmFeedPollStyle.decoration ??
          BoxDecoration(
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
              if (_lmFeedPollStyle.isComposable && widget.onEdit != null)
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
              if (_lmFeedPollStyle.isComposable && widget.onCancel != null)
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
                "*Select ${multiSelectState.name} $multiSelectNo ${multiSelectNo == 1 ? "option" : "options"}.",
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
                return _defPollOption(index);
              }),
          const SizedBox(height: 8),
          //add and option button
          if (widget.showAddOptionButton)
            LMFeedButton(
              onTap: () {
                //add option bottom sheet
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 8,
                            decoration: ShapeDecoration(
                              color: theme.disabledColor..withAlpha(200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: LMFeedText(
                              text: 'Add new poll option',
                              style: LMFeedTextStyle(
                                textStyle: TextStyle(
                                  height: 1.33,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          LikeMindsTheme.kVerticalPaddingSmall,
                          const LMFeedText(
                            text:
                                'Enter an option that you think is missing in this poll. This can not be undone.',
                            style: LMFeedTextStyle(
                                overflow: TextOverflow.visible,
                                textStyle: TextStyle(
                                  height: 1.33,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: TextField(
                              onChanged: (value) {
                                pollOptions.add(value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Type new option',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                          LMFeedButton(
                            onTap: () {},
                            text: const LMFeedText(
                              text: 'SUBMIT',
                              style: LMFeedTextStyle(
                                textStyle: TextStyle(
                                  height: 1.33,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: LMFeedButtonStyle(
                              backgroundColor: theme.primaryColor,
                              borderRadius: 100,
                              width: 150,
                              height: 44,
                            ),
                          ),
                          LikeMindsTheme.kVerticalPaddingMedium,
                        ],
                      ),
                    ),
                  ),
                );
              },
              text: const LMFeedText(
                text: '+ Add an option',
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    height: 1.33,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              style: LMFeedButtonStyle(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                borderRadius: 8,
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
            ),

          LikeMindsTheme.kVerticalPaddingMedium,
          if (widget.showSubmitButton)
            LMFeedButton(
                onTap: () {},
                text: const LMFeedText(
                  text: 'Submit Vote',
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      height: 1.33,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: LMFeedButtonStyle(
                  backgroundColor: theme.primaryColor,
                  borderRadius: 8,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                )),

          LMFeedText(
            text: 'Expires on $expiryTime',
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                height: 1.33,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          LMFeedText(
              text: widget.attachmentMeta.pollAnswerText ?? '',
              style: const LMFeedTextStyle(
                textStyle: TextStyle(
                  height: 1.33,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              )),
        ],
      ),
    );
  }

  Widget _defPollOption(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            //TODO: handle null check on options
            widget.onOptionSelect?.call(widget.attachmentMeta.options![index]);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 300,
                  child: LMFeedText(
                      text: pollOptions[index],
                      style: const LMFeedTextStyle(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          height: 1.25,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ),
                if (widget.showTick != null &&
                    widget.showTick!(widget.attachmentMeta.options![index]))
                  LMFeedIcon(
                    type: LMFeedIconType.icon,
                    icon: Icons.check_circle,
                    style: LMFeedIconStyle(color: theme.primaryColor),
                  ),
              ],
            ),
          ),
        ),
        if (widget.attachmentMeta.toShowResult != null &&
            widget.attachmentMeta.toShowResult!)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: LMFeedText(
              text: voteText(widget.attachmentMeta.options![index].voteCount),
              style: const LMFeedTextStyle(
                textStyle: TextStyle(
                  height: 1.33,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        LikeMindsTheme.kVerticalPaddingMedium,
      ],
    );
  }
}

String voteText(int voteCount) {
  if (voteCount == 1) {
    return '1 vote';
  } else {
    return '$voteCount votes';
  }
}
