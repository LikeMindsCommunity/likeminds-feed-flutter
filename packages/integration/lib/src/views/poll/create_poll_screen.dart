import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCreatePollScreen extends StatefulWidget {
  const LMFeedCreatePollScreen({
    super.key,
    this.attachmentMeta,
    this.appBarBuilder,
    this.pollQuestionStyle,
    this.optionStyle,
    this.advancedButtonBuilder,
    this.postButtonBuilder,
    this.addOptionButtonBuilder,
  });

  /// [LMAttachmentMetaViewData] to prefill the poll data
  final LMAttachmentMetaViewData? attachmentMeta;

  /// [LMFeedPostAppBarBuilder] Builder for app bar
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// [LMFeedTextFieldStyle] for poll question
  final LMFeedTextFieldStyle? pollQuestionStyle;

  /// [LMFeedTextFieldStyle] for poll options
  final LMFeedTextFieldStyle? optionStyle;

  /// [LMFeedButtonBuilder] Builder for advanced settings button
  final LMFeedButtonBuilder? advancedButtonBuilder;

  /// [LMFeedButtonBuilder] Builder for post button
  final LMFeedButtonBuilder? postButtonBuilder;

  /// [LMFeedButtonBuilder] Builder for add option button
  final LMFeedButtonBuilder? addOptionButtonBuilder;

  @override
  State<LMFeedCreatePollScreen> createState() => _LMFeedCreatePollScreenState();
}

class _LMFeedCreatePollScreenState extends State<LMFeedCreatePollScreen> {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  List<String> options = ["", ""];
  final ValueNotifier<bool> _optionBuilder = ValueNotifier(false);
  String exactlyDialogKey = 'exactly';
  int exactlyValue = 1;
  ValueNotifier<bool> _advancedBuilder = ValueNotifier(false);
  final TextEditingController _questionController = TextEditingController();
  ValueNotifier<DateTime?> _expiryDateBuilder = ValueNotifier(null);
  ValueNotifier<PollMultiSelectState> _multiSelectStateBuilder =
      ValueNotifier(PollMultiSelectState.exactly);
  ValueNotifier<bool> _rebuildMultiSelectStateBuilder = ValueNotifier(false);
  ValueNotifier<int> _multiSelectNoBuilder = ValueNotifier(1);
  ValueNotifier<bool> _pollTypeBuilder = ValueNotifier(false);
  ValueNotifier<bool> _isAnonymousBuilder = ValueNotifier(false);
  ValueNotifier<bool> _allowAddOptionBuilder = ValueNotifier(false);

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= DateTime.now();
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: 'Start date',
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: theme.primaryColor,
                  onPrimary: theme.onPrimary,
                ),
              ),
              child: child!);
        });

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: theme.primaryColor,
                onPrimary: theme.onPrimary,
              ),
            ),
            child: child!);
      },
    );
    if (selectedTime == null) return null;
    DateTime selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (selectedDateTime.isBefore(DateTime.now())) {
      showSnackBar('Expiry date cannot be in the past');
      return null;
    }

    return selectedDateTime;
  }

  String getFormattedDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    return '$day-$month-${date.year} $hour:$minute';
  }

  void showSnackBar(String message) {
    LMFeedCore.showSnackBar(
      context,
      message,
      LMFeedWidgetSource.createPostScreen,
    );
  }

  bool checkForUniqueOptions() {
    Set<String> uniqueOptions = options.toSet();
    if (uniqueOptions.length != options.length) {
      showSnackBar('Options should be unique');
      return false;
    }
    return true;
  }

  bool validatePoll() {
    // check if question is empty
    if (_questionController.text.trim().isEmpty) {
      showSnackBar('Question cannot be empty');
      return false;
    }

    // trim options and check if options are empty
    for (int i = 0; i < options.length; i++) {
      options[i] = options[i].trim();
      if (options[i].isEmpty) {
        showSnackBar('Option ${i + 1} cannot be empty');
        return false;
      }
    }

    // check if options are unique
    if (!checkForUniqueOptions()) {
      return false;
    }

    // check if expiry date is empty and in future
    if (_expiryDateBuilder.value == null) {
      showSnackBar('Expiry date cannot be empty');
      return false;
    } else if (_expiryDateBuilder.value!.isBefore(DateTime.now())) {
      showSnackBar('Expiry date cannot be in the past');
      return false;
    }

    return true;
  }

  void loadInitialData() {
    if (widget.attachmentMeta != null) {
      LMAttachmentMetaViewData attachmentMeta = widget.attachmentMeta!;
      _questionController.text = attachmentMeta.pollQuestion ?? '';
      options = attachmentMeta.pollOptions ?? [];
      _expiryDateBuilder.value = attachmentMeta.expiryTime != null
          ? DateTime.fromMillisecondsSinceEpoch(attachmentMeta.expiryTime!)
          : null;
      _multiSelectStateBuilder.value =
          attachmentMeta.multiSelectState ?? PollMultiSelectState.exactly;
      _multiSelectNoBuilder.value = attachmentMeta.multiSelectNo ?? 1;
      _pollTypeBuilder.value = attachmentMeta.pollType == PollType.deferred;
      _isAnonymousBuilder.value = attachmentMeta.isAnonymous ?? false;
      _allowAddOptionBuilder.value = attachmentMeta.allowAddOption ?? false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return _widgetsBuilder.scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: widget.appBarBuilder?.call(context, _defAppBar()) ?? _defAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: theme.container,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LMFeedTile(
                    leading: LMFeedProfilePicture(
                        fallbackText: user?.name ?? '',
                        imageUrl: user?.imageUrl,
                        style: LMFeedProfilePictureStyle(
                          size: 40,
                        )),
                    title: LMFeedText(
                      text: user?.name ?? '',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.33,
                        ),
                      ),
                    ),
                    style: LMFeedTileStyle(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                  ),
                  LMFeedText(
                    text: 'Poll question',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.primaryColor),
                    ),
                  ),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: widget.pollQuestionStyle?.decoration ??
                        InputDecoration(
                          hintText: 'Ask a question',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: theme.container,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: LMFeedText(
                      text: 'Answer Options',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: theme.primaryColor),
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _optionBuilder,
                      builder: (context, _, __) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              return OptionTile(
                                index: index,
                                isRemovable: options.length > 2,
                                option: options[index],
                                onDelete: () {
                                  if (options.length > 2) {
                                    options.removeAt(index);
                                    _optionBuilder.value =
                                        !_optionBuilder.value;
                                    _rebuildMultiSelectStateBuilder.value =
                                        !_rebuildMultiSelectStateBuilder.value;
                                    if (_multiSelectNoBuilder.value >
                                        options.length) {
                                      _multiSelectNoBuilder.value = 1;
                                    }
                                  }
                                },
                                onChanged: (value) {
                                  options[index] = value;
                                },
                              );
                            });
                      }),
                  LMFeedTile(
                    onTap: () {
                      if (options.length < 10) {
                        options.add('');
                        _optionBuilder.value = !_optionBuilder.value;
                        _rebuildMultiSelectStateBuilder.value =
                            !_rebuildMultiSelectStateBuilder.value;
                        debugPrint('Add option');
                      } else {
                        showSnackBar('You can add at max 10 options');
                      }
                    },
                    style: LMFeedTileStyle(
                        padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    )),
                    leading: LMFeedIcon(
                      type: LMFeedIconType.icon,
                      icon: Icons.add_circle_outline,
                      style: LMFeedIconStyle(
                        size: 24,
                        color: theme.primaryColor,
                      ),
                    ),
                    title: LMFeedText(
                      text: 'Add an option...',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: theme.container,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LMFeedText(
                    text: 'Poll expires on',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.primaryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDateTimePicker(
                          context: context,
                          initialDate: _expiryDateBuilder.value,
                        );
                        if (selectedDate != null) {
                          _expiryDateBuilder.value = selectedDate;
                        }
                      },
                      child: SizedBox(
                          width: double.infinity,
                          child: ValueListenableBuilder(
                              valueListenable: _expiryDateBuilder,
                              builder: (context, value, child) {
                                return LMFeedText(
                                  text: value == null
                                      ? 'DD-MM-YYYY hh:mm'
                                      : getFormattedDate(value),
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: theme.inActiveColor,
                                    ),
                                  ),
                                );
                              })),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            // Advanced settings
            ValueListenableBuilder(
                valueListenable: _advancedBuilder,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: value
                            ? Container(
                                color: theme.container,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable: _allowAddOptionBuilder,
                                        builder: (context, value, child) {
                                          return SwitchListTile(
                                            value: value,
                                            onChanged: (value) {
                                              _allowAddOptionBuilder.value =
                                                  value;
                                            },
                                            activeColor: theme.primaryColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 18,
                                            ),
                                            title: LMFeedText(
                                              text:
                                                  'Allow voters to add options',
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: theme.onContainer,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    Divider(
                                      color: theme.inActiveColor,
                                      height: 0,
                                    ),
                                    ValueListenableBuilder(
                                        valueListenable: _isAnonymousBuilder,
                                        builder: (context, value, child) {
                                          return SwitchListTile(
                                            value: value,
                                            onChanged: (value) {
                                              _isAnonymousBuilder.value = value;
                                            },
                                            activeColor: theme.primaryColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 18,
                                            ),
                                            title: LMFeedText(
                                              text: 'Anonymous poll',
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: theme.onContainer,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    Divider(
                                      color: theme.inActiveColor,
                                      height: 0,
                                    ),
                                    ValueListenableBuilder(
                                        valueListenable: _pollTypeBuilder,
                                        builder: (context, value, child) {
                                          return SwitchListTile(
                                            value: value,
                                            onChanged: (value) {
                                              _pollTypeBuilder.value = value;
                                            },
                                            activeColor: theme.primaryColor,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 18,
                                            ),
                                            title: LMFeedText(
                                              text: 'Don\'t show live results',
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: theme.onContainer,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    Divider(
                                      color: theme.inActiveColor,
                                      height: 0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LMFeedText(
                                            text: 'User can vote for',
                                            style: LMFeedTextStyle(
                                              textStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: theme.inActiveColor,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      _multiSelectStateBuilder,
                                                  builder:
                                                      (context, value, child) {
                                                    return DropdownButton<
                                                        PollMultiSelectState>(
                                                      value: value,
                                                      onChanged: (value) {
                                                        if (value != null)
                                                          _multiSelectStateBuilder
                                                              .value = value;
                                                      },
                                                      items: [
                                                        DropdownMenuItem(
                                                          child: LMFeedText(
                                                            text: "Exactly",
                                                          ),
                                                          value:
                                                              PollMultiSelectState
                                                                  .exactly,
                                                        ),
                                                        DropdownMenuItem(
                                                          child: LMFeedText(
                                                            text: "At least",
                                                          ),
                                                          value:
                                                              PollMultiSelectState
                                                                  .atLeast,
                                                        ),
                                                        DropdownMenuItem(
                                                          child: LMFeedText(
                                                            text: "At max",
                                                          ),
                                                          value:
                                                              PollMultiSelectState
                                                                  .atMax,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                              LMFeedText(
                                                text: '=',
                                                style: LMFeedTextStyle(
                                                  textStyle: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w400,
                                                    color: theme.inActiveColor,
                                                  ),
                                                ),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      _rebuildMultiSelectStateBuilder,
                                                  builder: (context, _, __) {
                                                    return ValueListenableBuilder(
                                                        valueListenable:
                                                            _multiSelectNoBuilder,
                                                        builder: (context,
                                                            value, child) {
                                                          return DropdownButton<
                                                              int>(
                                                            value: value,
                                                            items: [
                                                              // create dropdown items based on current options length min 1 and max options.length
                                                              for (int i = 1;
                                                                  i <=
                                                                      options
                                                                          .length;
                                                                  i++)
                                                                DropdownMenuItem(
                                                                  child:
                                                                      LMFeedText(
                                                                    text:
                                                                        '$i ${i == 1 ? 'option' : 'options'}',
                                                                  ),
                                                                  value: i,
                                                                ),
                                                            ],
                                                            onChanged: (value) {
                                                              if (value != null)
                                                                _multiSelectNoBuilder
                                                                        .value =
                                                                    value;
                                                            },
                                                          );
                                                        });
                                                  })
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: 24),
                      widget.addOptionButtonBuilder
                              ?.call(_defAdvancedButton(value)) ??
                          _defAdvancedButton(value),
                    ],
                  );
                }),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  LMFeedButton _defAdvancedButton(bool value) {
    return LMFeedButton(
      onTap: () {
        _advancedBuilder.value = !_advancedBuilder.value;
      },
      text: LMFeedText(text: 'ADVANCED'),
      isActive: value,
      style: LMFeedButtonStyle(
        placement: LMFeedIconButtonPlacement.end,
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.expand_less,
        ),
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.expand_more,
        ),
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
        style: LMFeedAppBarStyle(
          height: 60,
          padding: EdgeInsets.only(
            right: 16,
          ),
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        leading: BackButton(),
        title: LMFeedText(
          text: 'New Poll',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: [
          widget.postButtonBuilder?.call(_defPostButton()) ?? _defPostButton(),
        ]);
  }

  LMFeedButton _defPostButton() {
    return LMFeedButton(
      onTap: onPollSubmit,
      text: LMFeedText(
        text: 'DONE',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  onPollSubmit() {
    if (validatePoll()) {
      LMAttachmentMetaViewDataBuilder attachmentMetaViewDataBuilder =
          LMAttachmentMetaViewDataBuilder()
            ..pollQuestion(_questionController.text)
            ..expiryTime(_expiryDateBuilder.value?.millisecondsSinceEpoch)
            ..pollOptions(options)
            ..multiSelectState(_multiSelectStateBuilder.value)
            ..pollType(
                _pollTypeBuilder.value ? PollType.deferred : PollType.instant)
            ..multiSelectNo(_multiSelectNoBuilder.value)
            ..isAnonymous(_isAnonymousBuilder.value)
            ..allowAddOption(_allowAddOptionBuilder.value);

      debugPrint(attachmentMetaViewDataBuilder.build().toString());
      LMFeedComposeBloc.instance.add(LMFeedComposeAddPollEvent(
        attachmentMetaViewData: attachmentMetaViewDataBuilder.build(),
      ));
      Navigator.pop(context);
    }
  }
}

class OptionTile extends StatefulWidget {
  const OptionTile({
    super.key,
    required this.index,
    this.option,
    this.onDelete,
    this.onChanged,
    this.isRemovable = true,
    this.optionStyle,
  });
  final int index;
  final String? option;
  final VoidCallback? onDelete;
  final Function(String)? onChanged;
  final bool isRemovable;
  final LMFeedTextFieldStyle? optionStyle;

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  final TextEditingController _controller = TextEditingController();
  final LMFeedThemeData theme = LMFeedCore.theme;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.option ?? '';
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.option ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: widget.optionStyle?.decoration ??
                InputDecoration(
                  hintText: 'Option',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIconColor: theme.inActiveColor,
                  suffixIcon: widget.isRemovable
                      ? IconButton(
                          isSelected: true,
                          icon: Icon(Icons.close),
                          onPressed: widget.onDelete,
                        )
                      : null,
                ),
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 0,
        ),
      ],
    );
  }
}
