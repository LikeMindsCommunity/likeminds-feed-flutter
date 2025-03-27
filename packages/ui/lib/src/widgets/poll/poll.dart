import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

// ignore: must_be_immutable
class LMFeedPoll extends StatefulWidget {
  LMFeedPoll({
    super.key,
    required this.attachmentMeta,
    this.rebuildPollWidget,
    this.onCancel,
    this.onEdit,
    this.onEditVote,
    this.style = const LMFeedPollStyle(),
    this.onOptionSelect,
    this.showSubmitButton = false,
    this.showAddOptionButton = false,
    this.showEditVoteButton = false,
    this.isVoteEditing = false,
    this.showTick,
    this.timeLeft,
    this.onAddOptionSubmit,
    this.onVoteClick,
    this.selectedOption = const [],
    this.onSubmit,
    this.onSubtextTap,
    this.pollQuestionBuilder,
    this.pollOptionBuilder,
    this.pollSelectionTextBuilder,
    this.pollSelectionText,
    this.addOptionButtonBuilder,
    this.submitButtonBuilder,
    this.subTextBuilder,
    this.pollActionBuilder,
    this.onSameOptionAdded,
    this.isMultiChoicePoll,
  });

  /// [ValueNotifier] to rebuild the poll widget
  final ValueNotifier<bool>? rebuildPollWidget;

  /// [LMattachmentMetaViewData] to be displayed in the poll
  final LMAttachmentMetaViewData attachmentMeta;

  /// Callback when the cancel button is clicked
  final VoidCallback? onCancel;

  /// Callback when the edit button is clicked
  final Function(LMAttachmentMetaViewData)? onEdit;

  // Callback when the edit vote button is clicked
  final Function(LMAttachmentMetaViewData)? onEditVote;

  /// [LMFeedPollStyle] Style for the poll
  final LMFeedPollStyle style;

  /// Callback when an option is selected
  final void Function(LMPollOptionViewData)? onOptionSelect;

  /// [bool] to show the submit button
  final bool showSubmitButton;

  /// [bool] to show edit vote button
  final bool showEditVoteButton;

  /// [bool] to show the add option button
  final bool showAddOptionButton;

  /// [bool] to show is poll votes are being edited
  bool isVoteEditing;

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

  /// [Widget Function(BuildContext)] Builder for the poll selection text
  final Widget Function(BuildContext)? pollSelectionTextBuilder;

  /// [String] poll selection text
  final String? pollSelectionText;

  /// [Widget Function(BuildContext, LMFeedButton,  Function(String))] Builder for the add option button
  final Widget Function(BuildContext, LMFeedButton, Function(String))?
      addOptionButtonBuilder;

  /// [Widget Function(BuildContext)] Builder for the submit button
  final LMFeedButtonBuilder? submitButtonBuilder;

  /// [Widget Function(BuildContext)] Builder for the subtext
  final Widget Function(BuildContext)? subTextBuilder;

  /// [VoidCallback] error callback to be called when same option is added
  final VoidCallback? onSameOptionAdded;

  /// [bool] to show if the poll is multi choice
  final bool? isMultiChoicePoll;

  @override
  State<LMFeedPoll> createState() => _LMFeedPollState();

  LMFeedPoll copyWith({
    ValueNotifier<bool>? rebuildPollWidget,
    LMAttachmentMetaViewData? attachmentMeta,
    VoidCallback? onCancel,
    Function(LMAttachmentMetaViewData)? onEdit,
    Function(LMAttachmentMetaViewData)? onEditVote,
    LMFeedPollStyle? style,
    void Function(LMPollOptionViewData)? onOptionSelect,
    bool? showSubmitButton,
    bool? showAddOptionButton,
    bool? showEditVoteButton,
    bool? isVoteEditing,
    bool Function(LMPollOptionViewData)? showTick,
    String? timeLeft,
    void Function(String option)? onAddOptionSubmit,
    Function(LMPollOptionViewData)? onVoteClick,
    List<String>? selectedOption,
    Function(List<String> selectedOption)? onSubmit,
    VoidCallback? onSubtextTap,
    Widget Function(BuildContext)? pollQuestionBuilder,
    Widget Function(BuildContext)? pollOptionBuilder,
    Widget Function(BuildContext)? pollSelectionTextBuilder,
    String? pollSelectionText,
    Widget Function(BuildContext, LMFeedButton, Function(String))?
        addOptionButtonBuilder,
    LMFeedButtonBuilder? submitButtonBuilder,
    Widget Function(BuildContext)? subTextBuilder,
    VoidCallback? onSameOptionAdded,
    bool? isMultiChoicePoll,
  }) {
    return LMFeedPoll(
      rebuildPollWidget: rebuildPollWidget ?? this.rebuildPollWidget,
      attachmentMeta: attachmentMeta ?? this.attachmentMeta,
      onCancel: onCancel ?? this.onCancel,
      onEdit: onEdit ?? this.onEdit,
      onEditVote: onEditVote ?? this.onEditVote,
      style: style ?? this.style,
      onOptionSelect: onOptionSelect ?? this.onOptionSelect,
      showSubmitButton: showSubmitButton ?? this.showSubmitButton,
      showAddOptionButton: showAddOptionButton ?? this.showAddOptionButton,
      showEditVoteButton: showEditVoteButton ?? this.showEditVoteButton,
      isVoteEditing: isVoteEditing ?? this.isVoteEditing,
      showTick: showTick ?? this.showTick,
      timeLeft: timeLeft ?? this.timeLeft,
      onAddOptionSubmit: onAddOptionSubmit ?? this.onAddOptionSubmit,
      onVoteClick: onVoteClick ?? this.onVoteClick,
      selectedOption: selectedOption ?? this.selectedOption,
      onSubmit: onSubmit ?? this.onSubmit,
      onSubtextTap: onSubtextTap ?? this.onSubtextTap,
      pollQuestionBuilder: pollQuestionBuilder ?? this.pollQuestionBuilder,
      pollOptionBuilder: pollOptionBuilder ?? this.pollOptionBuilder,
      pollSelectionTextBuilder:
          pollSelectionTextBuilder ?? this.pollSelectionTextBuilder,
      pollSelectionText: pollSelectionText ?? this.pollSelectionText,
      addOptionButtonBuilder:
          addOptionButtonBuilder ?? this.addOptionButtonBuilder,
      submitButtonBuilder: submitButtonBuilder ?? this.submitButtonBuilder,
      subTextBuilder: subTextBuilder ?? this.subTextBuilder,
      onSameOptionAdded: onSameOptionAdded ?? this.onSameOptionAdded,
      isMultiChoicePoll: isMultiChoicePoll ?? this.isMultiChoicePoll,
    );
  }
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
  late ValueNotifier<bool> _rebuildPollWidget;
  bool _isVoteEditing = false;

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
    _isVoteEditing = widget.isVoteEditing;
  }

  @override
  void initState() {
    super.initState();
    _lmFeedPollStyle = widget.style;
    _rebuildPollWidget = widget.rebuildPollWidget ?? ValueNotifier(false);
    _setPollData();
  }

  @override
  void didUpdateWidget(covariant LMFeedPoll oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lmFeedPollStyle = widget.style;
    _rebuildPollWidget = widget.rebuildPollWidget ?? ValueNotifier(false);
    _setPollData();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _rebuildPollWidget,
        builder: (context, value, __) {
          return Container(
            margin: _lmFeedPollStyle.margin ??
                const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
            padding: _lmFeedPollStyle.padding ?? const EdgeInsets.all(16),
            decoration: _lmFeedPollStyle.decoration?.copyWith(
                  color: _lmFeedPollStyle.backgroundColor ?? theme.container,
                ) ??
                BoxDecoration(
                  color: _lmFeedPollStyle.backgroundColor ?? theme.container,
                  borderRadius: _lmFeedPollStyle.isComposable
                      ? BorderRadius.circular(8)
                      : null,
                  border: _lmFeedPollStyle.isComposable
                      ? Border.all(
                          color: theme.inActiveColor,
                        )
                      : null,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    widget.pollQuestionBuilder?.call(context) ??
                        _defPollQuestion(),
                    if (_lmFeedPollStyle.isComposable)
                      widget.pollActionBuilder?.call(context) ??
                          _defPollAction(),
                  ],
                ),
                LikeMindsTheme.kVerticalPaddingMedium,
                widget.pollSelectionTextBuilder?.call(context) ??
                    _defPollSubtitle(),
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
                    child: widget.addOptionButtonBuilder?.call(context,
                            _defAddOptionButton(context), _onAddOptionSubmit) ??
                        _defAddOptionButton(context),
                  ),

                if (widget.showSubmitButton ||
                    (_isVoteEditing && (widget.isMultiChoicePoll ?? false)))
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
        });
  }

  Row _defSubText() {
    return Row(
      children: [
        LMFeedText(
            text: widget.attachmentMeta.pollAnswerText ?? '',
            onTap: widget.onSubtextTap,
            style: _lmFeedPollStyle.pollAnswerStyle ??
                LMFeedTextStyle(
                  textStyle: TextStyle(
                    height: 1.33,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.primaryColor,
                  ),
                )),
        LikeMindsTheme.kHorizontalPaddingSmall,
        LMFeedText(
          text: '●',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: LikeMindsTheme.kFontSmall,
              color: theme.inActiveColor,
            ),
          ),
        ),
        LikeMindsTheme.kHorizontalPaddingSmall,
        LMFeedText(
          text: widget.timeLeft ?? '',
          style: _lmFeedPollStyle.timeStampStyle ??
              LMFeedTextStyle(
                textStyle: TextStyle(
                  height: 1.33,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: theme.inActiveColor,
                ),
              ),
        ),
        if (widget.showEditVoteButton && !_isVoteEditing)
          Row(
            children: [
              LikeMindsTheme.kHorizontalPaddingSmall,
              LMFeedText(
                text: '●',
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: LikeMindsTheme.kFontSmall,
                    color: theme.inActiveColor,
                  ),
                ),
              ),
              LikeMindsTheme.kHorizontalPaddingSmall,
              LMFeedText(
                text: 'Edit Vote',
                onTap: () {
                  widget.onEditVote?.call(widget.attachmentMeta);
                  _isVoteEditing = true;
                  _rebuildPollWidget.value = !_rebuildPollWidget.value;
                },
                style: _lmFeedPollStyle.editPollOptionsStyles ??
                    LMFeedTextStyle(
                      textStyle: TextStyle(
                        height: 1.33,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.primaryColor,
                      ),
                    ),
              ),
            ],
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
                  LMFeedText(
                    text:
                        'Enter an option that you think is missing in this poll. This can not be undone.',
                    style: LMFeedTextStyle(
                        overflow: TextOverflow.visible,
                        textStyle: TextStyle(
                          height: 1.33,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: theme.inActiveColor,
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
                      _onAddOptionSubmit(_addOptionController.text);
                    },
                    text: LMFeedText(
                      text: 'SUBMIT',
                      style: _lmFeedPollStyle.submitPollTextStyle ??
                          LMFeedTextStyle(
                            textStyle: TextStyle(
                              height: 1.33,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: theme.container,
                            ),
                          ),
                    ),
                    style: _lmFeedPollStyle.submitPollButtonStyle ??
                        LMFeedButtonStyle(
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
        gap: 8,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        borderRadius: 8,
        border: Border.all(
          color: theme.inActiveColor,
        ),
      ),
    );
  }

  void _onAddOptionSubmit(String optionText) {
    if ((widget.attachmentMeta.options?.length ?? 0) > 10) {
      widget.onAddOptionSubmit?.call(optionText);
      Navigator.of(context).pop();
      return;
    }
    String text = optionText.trim();
    if (text.isEmpty) {
      _addOptionController.clear();
      return;
    }
    for (LMPollOptionViewData option in widget.attachmentMeta.options ?? []) {
      if (option.text == text) {
        Navigator.of(context).pop();
        _addOptionController.clear();
        widget.onSameOptionAdded?.call();
        return;
      }
    }
    setState(() {
      final LMPollOptionViewData newOption = (LMPostOptionViewDataBuilder()
            ..text(text)
            ..percentage(0)
            ..votes(0)
            ..isSelected(false))
          .build();
      widget.attachmentMeta.options?.add(newOption);
      _setPollData();
    });
    widget.onAddOptionSubmit?.call(optionText);
    Navigator.of(context).pop();
    _addOptionController.clear();
  }

  Widget _defPollSubtitle() {
    return widget.pollSelectionText == null
        ? const SizedBox.shrink()
        : LMFeedText(
            text: widget.pollSelectionText!,
            style: _lmFeedPollStyle.pollInfoStyles ??
                const LMFeedTextStyle(
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

  LMFeedExpandableText _defPollQuestion() {
    return LMFeedExpandableText(
      pollQuestion,
      expandText: _lmFeedPollStyle.pollQuestionExpandedText ?? "see more",
      collapseText: _lmFeedPollStyle.pollQuestionCollapsedText ?? "view less",
      onTagTap: (value) {},
      style: _lmFeedPollStyle.pollQuestionStyle ??
          TextStyle(
            color: theme.onContainer,
            fontSize: 16,
            fontWeight: FontWeight.w500,
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
                  !_isVoteEditing &&
                  !_lmFeedPollStyle.isComposable)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      //Here you pass the percentage
                      value: widget.attachmentMeta.options![index].percentage /
                          100,
                      color: widget.attachmentMeta.options![index].isSelected
                          ? _lmFeedPollStyle
                              .pollOptionStyle?.pollOptionSelectedColor
                          : _lmFeedPollStyle
                              .pollOptionStyle?.pollOptionOtherColor,
                      backgroundColor: theme.container,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: _lmFeedPollStyle
                        .pollOptionStyle?.pollOptionDecoration ??
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (!_lmFeedPollStyle.isComposable &&
                                    widget.attachmentMeta.toShowResult !=
                                        null &&
                                    !_isVoteEditing &&
                                    widget.attachmentMeta.toShowResult! &&
                                    widget.attachmentMeta.options![index]
                                        .isSelected) ||
                                _isSelectedByUser(
                                    widget.attachmentMeta.options?[index]) ||
                                (widget.showTick != null &&
                                    widget.showTick!(
                                        widget.attachmentMeta.options![index]))
                            ? _lmFeedPollStyle.pollOptionStyle
                                    ?.pollOptionSelectedBorderColor ??
                                theme.primaryColor
                            : theme.inActiveColor,
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
                            style: _lmFeedPollStyle
                                    .pollOptionStyle?.pollOptionTextStyle ??
                                LMFeedTextStyle(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    color: _isSelectedByUser(widget
                                                .attachmentMeta
                                                .options?[index]) ||
                                            (widget.showTick != null &&
                                                widget.showTick!(widget
                                                    .attachmentMeta
                                                    .options![index]))
                                        ? _lmFeedPollStyle.pollOptionStyle
                                                ?.pollOptionSelectedTextColor ??
                                            theme.primaryColor
                                        : theme.onContainer,
                                    height: 1.25,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )),
                        if (widget.attachmentMeta.allowAddOption ?? false)
                          LMFeedText(
                              text: _defAddedByMember(widget
                                  .attachmentMeta.options?[index].userViewData),
                              style: LMFeedTextStyle(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  height: 1.25,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: _isSelectedByUser(widget.attachmentMeta
                                              .options?[index]) ||
                                          (widget.showTick != null &&
                                              widget.showTick!(widget
                                                  .attachmentMeta
                                                  .options![index]))
                                      ? _lmFeedPollStyle.pollOptionStyle
                                              ?.pollOptionSelectedTextColor ??
                                          theme.primaryColor
                                      : _lmFeedPollStyle.pollOptionStyle
                                              ?.pollOptionOtherTextColor ??
                                          theme.inActiveColor,
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
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: LMFeedIcon(
                            type: LMFeedIconType.icon,
                            icon: Icons.check_circle,
                            style: LMFeedIconStyle(
                              boxSize: 20,
                              size: 20,
                              color: _lmFeedPollStyle.pollOptionStyle
                                      ?.pollOptionSelectedTickColor ??
                                  theme.primaryColor,
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
            !_isVoteEditing &&
            widget.attachmentMeta.toShowResult!)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: LMFeedText(
              text: voteText(widget.attachmentMeta.options![index].voteCount),
              onTap: () {
                widget.onVoteClick?.call(widget.attachmentMeta.options![index]);
              },
              style: _lmFeedPollStyle.pollOptionStyle?.votesCountStyles ??
                  LMFeedTextStyle(
                    textStyle: TextStyle(
                      height: 1.33,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.inActiveColor,
                    ),
                  ),
            ),
          ),
        LikeMindsTheme.kVerticalPaddingMedium,
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
        text: LMFeedText(
          text: 'Submit Vote',
          style: _lmFeedPollStyle.submitPollTextStyle ??
              LMFeedTextStyle(
                textStyle: TextStyle(
                  height: 1.33,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.container,
                ),
              ),
        ),
        style: _lmFeedPollStyle.submitPollButtonStyle ??
            LMFeedButtonStyle(
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
