import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/poll_attachement_widget.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  List<String> options = ["", ""];
  final ValueNotifier<bool> _optionBuilder = ValueNotifier(false);
  String exactlyDialogKey = 'exactly';
  int exactlyValue = 1;

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
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
      initialTime: TimeOfDay.fromDateTime(selectedDate),
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

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }

  @override
  Widget build(BuildContext context) {
    return _widgetsBuilder.scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: LMFeedAppBar(
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
            LMFeedButton(
              onTap: () {
                for(String option in options){
                  debugPrint(option);
                }
              },
              text: LMFeedText(
                text: 'POST',
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            )
          ]),
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
                    text: 'Polls question',
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.primaryColor),
                    ),
                  ),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
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
                                option: options[index],
                                onDelete: () {
                                  if (options.length > 2) {
                                    options.removeAt(index);
                                    _optionBuilder.value =
                                        !_optionBuilder.value;
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
                      options.add('');
                      _optionBuilder.value = !_optionBuilder.value;
                      debugPrint('Add option');
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
                        DateTime? dateTime =
                            await showDateTimePicker(context: context);
                        debugPrint(dateTime.toString());
                      },
                      child: SizedBox(
                          width: double.infinity,
                          child: LMFeedText(
                            text: 'DD-MM-YYYY hh:mm',
                            style: LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: theme.inActiveColor,
                              ),
                            ),
                          )),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: theme.container,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    value: false,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    title: LMFeedText(
                      text: 'Allow voters to add options',
                      style: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.onContainer,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: theme.inActiveColor,
                    height: 0,
                  ),
                  SwitchListTile(
                    value: false,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.symmetric(
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
                  ),
                  Divider(
                    color: theme.inActiveColor,
                    height: 0,
                  ),
                  SwitchListTile(
                    value: false,
                    onChanged: (value) {},
                    contentPadding: EdgeInsets.symmetric(
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
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: exactlyDialogKey,
                              onChanged: (value) => exactlyDialogKey = value!,
                              items: [
                                DropdownMenuItem(
                                  child: LMFeedText(
                                    text: 'Exactly',
                                  ),
                                  value: 'exactly',
                                ),
                                DropdownMenuItem(
                                  child: LMFeedText(
                                    text: 'At most',
                                  ),
                                  value: 'atMost',
                                ),
                                DropdownMenuItem(
                                  child: LMFeedText(
                                    text: 'At least',
                                  ),
                                  value: 'atLeast',
                                ),
                              ],
                            ),
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
                            DropdownButton<int>(
                              value: exactlyValue,
                              items: [
                                DropdownMenuItem(
                                  child: LMFeedText(text: '1 option'),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: LMFeedText(text: '2 options'),
                                  value: 2,
                                ),
                                DropdownMenuItem(
                                  child: LMFeedText(text: '3 options'),
                                  value: 3,
                                ),
                                DropdownMenuItem(
                                  child: LMFeedText(text: '4 options'),
                                  value: 4,
                                ),
                              ],
                              onChanged: (value) {
                                exactlyValue = value!;
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 24),
            LMFeedButton(
              onTap: () {
                debugPrint('ADVANCED');
              },
              text: LMFeedText(text: 'ADVANCED'),
              style: LMFeedButtonStyle(
                placement: LMFeedIconButtonPlacement.end,
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.expand_more,
                ),
              ),
            ),
            Container(
              color: theme.container,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
                child: PollAttachment(),
              ),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class OptionTile extends StatefulWidget {
  const OptionTile({
    super.key,
    required this.index,
    this.option,
    this.onDelete,
    this.onChanged,
  });
  final int index;
  final String? option;
  final VoidCallback? onDelete;
  final Function(String)? onChanged;

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
            decoration: InputDecoration(
              hintText: 'Option',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              suffixIconColor: theme.inActiveColor,
              suffixIcon: IconButton(
                isSelected: false,
                icon: Icon(Icons.close),
                onPressed: widget.onDelete,
              ),
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
