import 'dart:async';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/packages/flutter_typeahead/lib/flutter_typeahead.dart';

/// A widget that provides a text field with tagging functionality.
/// It allows users to tag other users by typing "@" followed by the user's name.
class LMTaggingAheadTextField extends StatefulWidget {
  /// Determines the direction of the suggestions box.
  final bool isDown;

  /// The focus node for the text field.
  final FocusNode focusNode;

  /// A list of user tags to be displayed as suggestions.
  final List<LMUserTagViewData>? userTags;

  /// Callback function when a tag is selected.
  final Function(LMUserTagViewData) onTagSelected;

  /// The controller for the text field.
  final TextEditingController controller;

  /// Callback function when the text changes.
  final Function(String)? onChange;

  /// Callback function when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Callback function when the text is submitted.
  final Function(String)? onSubmitted;

  /// Determines if the text field is enabled.
  final bool enabled;

  /// The style for the text field.
  final LMTaggingAheadTextFieldStyle style;

  /// Creates an instance of [LMTaggingAheadTextField].
  const LMTaggingAheadTextField({
    super.key,
    required this.isDown,
    required this.onTagSelected,
    required this.controller,
    required this.focusNode,
    required this.onChange,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.userTags,
    this.style = const LMTaggingAheadTextFieldStyle(),
  });

  @override
  State<LMTaggingAheadTextField> createState() => _TaggingAheadTextFieldState();

  /// Creates a copy of this widget but with the given fields replaced with the new values.
  LMTaggingAheadTextField copyWith({
    bool? isDown,
    FocusNode? focusNode,
    Function(LMUserTagViewData)? onTagSelected,
    TextEditingController? controller,
    Function(String)? onChange,
    bool? enabled,
    List<LMUserTagViewData>? userTags,
    VoidCallback? onEditingComplete,
    Function(String)? onSubmitted,
  }) {
    return LMTaggingAheadTextField(
      isDown: isDown ?? this.isDown,
      focusNode: focusNode ?? this.focusNode,
      onTagSelected: onTagSelected ?? this.onTagSelected,
      controller: controller ?? this.controller,
      onChange: onChange ?? this.onChange,
      enabled: enabled ?? this.enabled,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      userTags: userTags ?? this.userTags,
    );
  }
}

/// The state for the [LMTaggingAheadTextField] widget.
class _TaggingAheadTextFieldState extends State<LMTaggingAheadTextField> {
  /// The controller for the text field.
  late final TextEditingController _controller;

  /// The focus node for the text field.
  FocusNode? _focusNode;

  /// The scroll controller for the suggestions box.
  final ScrollController _scrollController = ScrollController();

  /// The controller for the suggestions box.
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();

  /// A list of user tags to be displayed as suggestions.
  List<LMUserTagViewData> userTags = [];

  /// The current page number for pagination.
  int page = 1;

  /// The current count of tags.
  int tagCount = 0;

  /// Indicates if tagging is complete.
  bool tagComplete = false;

  /// The current text value of the text field.
  String textValue = "";

  /// The current tag value being typed.
  String tagValue = "";

  /// The fixed size for pagination.
  static const fixedSize = 20;

  @override
  void dispose() {
    _controller.dispose();
    _suggestionsBoxController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userTags = [...widget.userTags ?? []];
    _focusNode = widget.focusNode;
    _controller = widget.controller;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final taggingData =
            await LMFeedCore.instance.lmFeedClient.getTaggingList(
          request: (GetTaggingListRequestBuilder()
                ..page(page)
                ..pageSize(fixedSize))
              .build(),
        );
        if (taggingData.success &&
            taggingData.members != null &&
            taggingData.members!.isNotEmpty) {
          page++;

          userTags.addAll(taggingData.members!
              .map((e) => LMUserTagViewDataConvertor.fromUserTag(e))
              .toList());
        }
      }
    });
  }

  /// Gets the controller for the text field.
  TextEditingController? get controller => _controller;

  /// Fetches suggestions based on the query.
  FutureOr<Iterable<LMUserTagViewData>> _getSuggestions(String query) async {
    String currentText = query;
    try {
      if (currentText.isEmpty) {
        return const Iterable.empty();
      } else if (!tagComplete && currentText.contains('@')) {
        String tag = '';
        if (tagValue.length > 1) {
          tag = tagValue.substring(1).replaceAll(' ', '');
        }
        final taggingData =
            await LMFeedCore.instance.lmFeedClient.getTaggingList(
          request: (GetTaggingListRequestBuilder()
                ..page(page)
                ..pageSize(fixedSize)
                ..searchQuery(tag))
              .build(),
        );
        if (taggingData.success &&
            taggingData.members != null &&
            taggingData.members!.isNotEmpty) {
          page += 1;
          userTags = taggingData.members!
              .map((e) => LMUserTagViewDataConvertor.fromUserTag(e))
              .toList();
          return userTags;
        }
        return const Iterable.empty();
      } else {
        return const Iterable.empty();
      }
    } on Exception catch (err, stacktrace) {
      LMFeedPersistence.instance.handleException(err, stacktrace);

      return const Iterable.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    return TypeAheadField<LMUserTagViewData>(
      onTagTap: (p) {},
      scrollController: _scrollController,
      tagColor: feedTheme.tagColor,
      scrollPhysics: widget.style.scrollPhysics,
      suggestionsBoxController: _suggestionsBoxController,
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        color: feedTheme.container,
        elevation: 4,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.22,
        ),
      ),
      noItemsFoundBuilder: (context) => const SizedBox.shrink(),
      hideOnEmpty: true,
      hideOnLoading: true,
      debounceDuration: const Duration(milliseconds: 500),
      textFieldConfiguration: TextFieldConfiguration(
        keyboardType: TextInputType.multiline,
        cursorColor: feedTheme.primaryColor,
        textCapitalization: TextCapitalization.sentences,
        controller: _controller,
        focusNode: _focusNode,
        minLines: widget.style.minLines,
        maxLines: widget.style.maxLines,
        style: widget.style.textStyle,
        decoration: widget.style.decoration ??
            const InputDecoration(
              hintText: 'Write something here...',
              border: InputBorder.none,
            ),
        textInputAction: TextInputAction.done,
        onEditingComplete: () => widget.onEditingComplete?.call(),
        onSubmitted: (String value) => widget.onSubmitted?.call(value),
        onChanged: (value) {
          page = 1;
          widget.onChange!(value);
          final int newTagCount = '@'.allMatches(value).length;
          final int completeCount = '~'.allMatches(value).length;
          if (newTagCount == completeCount) {
            textValue = _controller.value.text;
            tagComplete = true;
          } else if (newTagCount > completeCount) {
            tagComplete = false;
            tagCount = completeCount;
            tagValue = value.substring(value.lastIndexOf('@'));
            textValue = value.substring(0, value.lastIndexOf('@'));
          }
        },
      ),
      direction: widget.isDown ? AxisDirection.down : AxisDirection.up,
      suggestionsCallback: (suggestion) async {
        if (!widget.enabled) {
          return Future.value(const Iterable.empty());
        }
        return await _getSuggestions(suggestion);
      },
      keepSuggestionsOnSuggestionSelected: true,
      keepSuggestionsOnLoading: false,
      itemBuilder: (context, opt) {
        return Container(
          decoration: BoxDecoration(
            color: feedTheme.container,
            border: const Border(
              bottom: BorderSide(
                color: LikeMindsTheme.greyColor,
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AbsorbPointer(
                    absorbing: true,
                    child: LMFeedProfilePicture(
                      fallbackText: opt.name!,
                      style: LMFeedProfilePictureStyle(
                        size: 32,
                        backgroundColor: feedTheme.primaryColor,
                      ),
                      imageUrl: opt.imageUrl!,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  LMFeedText(
                    text: opt.name!,
                    style: const LMFeedTextStyle(
                        textStyle: TextStyle(
                      fontSize: 14,
                    )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onSuggestionSelected: ((suggestion) {
        debugPrint(suggestion.toString());
        widget.onTagSelected.call(suggestion);
        setState(() {
          tagComplete = true;
          tagCount = '@'.allMatches(_controller.text).length;
          if (textValue.length > 2 &&
              textValue.substring(textValue.length - 1) == '~') {
            textValue += " @${suggestion.name!}~";
          } else {
            textValue += "@${suggestion.name!}~";
          }
          _controller.text = '$textValue ';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(
              offset: _controller.text.length,
            ),
          );
          tagValue = '';
          textValue = _controller.value.text;
        });
      }),
    );
  }
}

/// Extension on [String] to find the nth occurrence of a substring.
extension NthOccurrenceOfSubstring on String {
  /// Finds the index of the nth occurrence of [stringToFind].
  int nThIndexOf(String stringToFind, int n) {
    if (indexOf(stringToFind) == -1) return -1;
    if (n == 1) return indexOf(stringToFind);
    int subIndex = -1;
    while (n > 0) {
      subIndex = indexOf(stringToFind, subIndex + 1);
      n -= 1;
    }
    return subIndex;
  }

  /// Checks if the nth occurrence of [stringToFind] exists.
  bool hasNthOccurrence(String stringToFind, int n) {
    return nThIndexOf(stringToFind, n) != -1;
  }
}

/// A style class for [LMTaggingAheadTextField].
class LMTaggingAheadTextFieldStyle {
  /// The decoration for the text field.
  final InputDecoration? decoration;

  /// The maximum number of lines for the text field.
  final int? maxLines;

  /// The minimum number of lines for the text field.
  final int minLines;

  /// The scroll physics for the suggestions box.
  final ScrollPhysics scrollPhysics;

  /// The text style for the text field.
  final TextStyle textStyle;

  /// Creates an instance of [LMTaggingAheadTextFieldStyle].
  const LMTaggingAheadTextFieldStyle({
    this.decoration,
    this.maxLines,
    this.minLines = 1,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w400),
  });
}

/// Extension on [LMTaggingAheadTextFieldStyle] to create a copy with modified fields.
extension LMTaggingAheadTextFieldStyleCopyWith on LMTaggingAheadTextFieldStyle {
  /// Creates a copy of this style but with the given fields replaced with the new values.
  LMTaggingAheadTextFieldStyle copyWith({
    InputDecoration? decoration,
    int? maxLines,
    int? minLines,
    ScrollPhysics? scrollPhysics,
    TextStyle? textStyle,
  }) {
    return LMTaggingAheadTextFieldStyle(
      decoration: decoration ?? this.decoration,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}
