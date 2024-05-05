import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

// ignore: must_be_immutable
class LMFeedPoll extends StatefulWidget {
  LMFeedPoll({
    super.key,
    required this.attachmentMeta,
    this.onCancel,
    this.onEdit,
    this.style = const LMFeedPollStyle(),
    this.onOptionSelect,
    this.showSubmitButton = false,
    this.showAddOptionButton = false,
    this.showTick,
    this.timeLeft,
    this.onAddOptionSubmit,
    this.onVoteClick,
    this.selectedOption = const [],
    this.onSubmit,
    this.onSubtextTap,
    this.pollQuestionBuilder,
    this.pollOptionBuilder,
    this.pollSubtitleBuilder,
    this.addOptionButtonBuilder,
    this.submitButtonBuilder,
    this.subTextBuilder,
    this.pollActionBuilder,
  });

  /// [LMattachmentMetaViewData] to be displayed in the poll
  final LMAttachmentMetaViewData attachmentMeta;

  /// Callback when the cancel button is clicked
  final VoidCallback? onCancel;

  /// Callback when the edit button is clicked
  final Function(LMAttachmentMetaViewData)? onEdit;

  /// [LMFeedPollStyle] Style for the poll
  final LMFeedPollStyle style;

  /// Callback when an option is selected
  final void Function(LMPollOptionViewData)? onOptionSelect;

  /// [bool] to show the submit button
  final bool showSubmitButton;

  /// [bool] to show the add option button
  final bool showAddOptionButton;

  /// [bool Function(LMPollOptionViewData optionViewData)] to show the tick
  final bool Function(LMPollOptionViewData optionViewData)? showTick;

  /// [String] time left for the poll to end
  final String? timeLeft;

  /// Callback when the add option is submitted
  final void Function(String option)? onAddOptionSubmit;

  /// Callback when the vote is clicked
  final Function(LMPollOptionViewData)? onVoteClick;

  /// [List<String>] selected options
  List<String> selectedOption;

  /// Callback when the submit button is clicked
  final Function(List<String> selectedOption)? onSubmit;

  /// Callback when the subtext is clicked
  final VoidCallback? onSubtextTap;

  /// [Widget Function(BuildContext)] Builder for the poll question
  final Widget Function(BuildContext)? pollQuestionBuilder;

  /// [Widget Function(BuildContext)] Builder for the poll action
  final Widget Function(BuildContext)? pollActionBuilder;

  /// [Widget Function(BuildContext)] Builder for the poll option
  final Widget Function(BuildContext)? pollOptionBuilder;

  /// [Widget Function(BuildContext)] Builder for the poll subtitle
  final Widget Function(BuildContext)? pollSubtitleBuilder;

  /// [Widget Function(BuildContext)] Builder for the add option button
  final LMFeedButtonBuilder? addOptionButtonBuilder;

  /// [Widget Function(BuildContext)] Builder for the submit button
  final LMFeedButtonBuilder? submitButtonBuilder;

  /// [Widget Function(BuildContext)] Builder for the subtext
  final Widget Function(BuildContext)? subTextBuilder;

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
  final TextEditingController _addOptionController = TextEditingController();

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
            color: theme.container,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              widget.pollQuestionBuilder?.call(context) ?? _defPollQuestion(),
              if (_lmFeedPollStyle.isComposable)
                widget.pollActionBuilder?.call(context) ?? _defPollAction(),
            ],
          ),
          LikeMindsTheme.kVerticalPaddingMedium,
          widget.pollSubtitleBuilder?.call(context) ?? _defPollSubtitle(),
          const SizedBox(height: 8),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pollOptions.length,
              itemBuilder: (context, index) {
                return widget.pollOptionBuilder?.call(
                      context,
                    ) ??
                    _defPollOption(index);
              }),
          //add and option button
          if (widget.showAddOptionButton)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: widget.addOptionButtonBuilder
                      ?.call(_defAddOptionButton(context)) ??
                  _defAddOptionButton(context),
            ),

          if (widget.showSubmitButton)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: widget.submitButtonBuilder?.call(
                    _defSubmitButton(),
                  ) ??
                  _defSubmitButton(),
            ),
          widget.subTextBuilder?.call(context) ?? _defSubText(),
        ],
      ),
    );
  }

  Row _defSubText() {
    return Row(
      children: [
        LMFeedText(
            text: widget.attachmentMeta.pollAnswerText ?? '',
            onTap: widget.onSubtextTap,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                height: 1.33,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.primaryColor,
              ),
            )),
        LikeMindsTheme.kHorizontalPaddingSmall,
        const LMFeedText(
          text: '●',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: LikeMindsTheme.kFontSmall,
              color: Color.fromRGBO(217, 217, 217, 1),
            ),
          ),
        ),
        LikeMindsTheme.kHorizontalPaddingSmall,
        LMFeedText(
          text: widget.timeLeft ?? '',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              height: 1.33,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.inActiveColor,
            ),
          ),
        ),
      ],
    );
  }

  LMFeedButton _defAddOptionButton(BuildContext context) {
    return LMFeedButton(
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
                      controller: _addOptionController,
                      decoration: const InputDecoration(
                        hintText: 'Type new option',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  LMFeedButton(
                    onTap: () {
                      setState(() {
                        final LMPollOptionViewData newOption =
                            (LMPostOptionViewDataBuilder()
                                  ..text(_addOptionController.text)
                                  ..percentage(0)
                                  ..votes(0)
                                  ..isSelected(false))
                                .build();
                        widget.attachmentMeta.options?.add(newOption);
                        _setPollData();
                      });
                      widget.onAddOptionSubmit?.call(_addOptionController.text);
                      Navigator.of(context).pop();
                      _addOptionController.clear();
                    },
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
        margin: 8,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 8,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
    );
  }

  LMFeedText _defPollSubtitle() {
    return LMFeedText(
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
    );
  }

  Row _defPollAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onEdit != null)
          LMFeedButton(
            onTap: () {
              widget.onEdit?.call(widget.attachmentMeta);
            },
            style: LMFeedButtonStyle(
                backgroundColor: theme.container,
                icon: const LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.edit,
                )),
          ),
        LikeMindsTheme.kHorizontalPaddingSmall,
        if (widget.onCancel != null)
          LMFeedButton(
            onTap: widget.onCancel ?? () {},
            style: LMFeedButtonStyle(
                backgroundColor: theme.container,
                icon: const LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.cancel_outlined,
                )),
          ),
      ],
    );
  }

  LMFeedText _defPollQuestion() {
    return LMFeedText(
      text: pollQuestion,
      style: const LMFeedTextStyle(
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _defPollOption(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            widget.onOptionSelect?.call(widget.attachmentMeta.options![index]);
          },
          child: Stack(
            children: [
              if (widget.attachmentMeta.toShowResult != null &&
                  widget.attachmentMeta.toShowResult! &&
                  !_lmFeedPollStyle.isComposable)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      //Here you pass the percentage
                      value: widget.attachmentMeta.options![index].percentage /
                          100,
                      color: widget.attachmentMeta.options![index].isSelected
                          ? const Color.fromRGBO(80, 70, 229, 0.2)
                          : const Color.fromRGBO(230, 235, 245, 1),
                      backgroundColor: theme.container,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (!_lmFeedPollStyle.isComposable &&
                                widget.attachmentMeta.toShowResult != null &&
                                widget.attachmentMeta.toShowResult! &&
                                widget.attachmentMeta.options![index]
                                    .isSelected) ||
                            _isSelectedByUser(
                                widget.attachmentMeta.options?[index])
                        ? theme.primaryColor
                        : Colors.grey,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LMFeedText(
                            text: pollOptions[index],
                            style: LMFeedTextStyle(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: TextStyle(
                                color: _isSelectedByUser(widget
                                            .attachmentMeta.options?[index]) ||
                                        (widget.showTick != null &&
                                            widget.showTick!(widget
                                                .attachmentMeta
                                                .options![index]))
                                    ? theme.primaryColor
                                    : Colors.black,
                                height: 1.25,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                        if (widget.attachmentMeta.allowAddOption ?? false)
                          LMFeedText(
                              text: _defAddedByMember(widget
                                  .attachmentMeta.options?[index].userViewData),
                              style: const LMFeedTextStyle(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  height: 1.25,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              )),
                      ],
                    ),
                    if (_isSelectedByUser(
                            widget.attachmentMeta.options?[index]) ||
                        (widget.showTick != null &&
                            widget.showTick!(
                                widget.attachmentMeta.options![index])))
                      Padding(
                        padding: widget.attachmentMeta.allowAddOption ?? false
                            ? const EdgeInsets.only(
                                top: 5,
                              )
                            : EdgeInsets.zero,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: LMFeedIcon(
                            type: LMFeedIconType.svg,
                            assetPath: lmTickSvg,
                            style: LMFeedIconStyle(
                              boxSize: 20,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!_lmFeedPollStyle.isComposable &&
            widget.attachmentMeta.toShowResult != null &&
            widget.attachmentMeta.toShowResult!)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: LMFeedText(
              text: voteText(widget.attachmentMeta.options![index].voteCount),
              onTap: () {
                widget.onVoteClick?.call(widget.attachmentMeta.options![index]);
              },
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
        LikeMindsTheme.kVerticalPaddingSmall,
      ],
    );
  }

  bool _isSelectedByUser(LMPollOptionViewData? optionViewData) {
    if (optionViewData == null) {
      return false;
    }
    return widget.selectedOption.contains(optionViewData.id);
  }

  String _defAddedByMember(
    LMUserViewData? userViewData,
  ) {
    return "Added by ${userViewData?.name ?? ""}";
  }

  LMFeedButton _defSubmitButton() {
    return LMFeedButton(
        onTap: () {
          widget.onSubmit?.call(widget.selectedOption);
        },
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ));
  }
}

String voteText(int voteCount) {
  if (voteCount == 1) {
    return '1 vote';
  } else {
    return '$voteCount votes';
  }
}
