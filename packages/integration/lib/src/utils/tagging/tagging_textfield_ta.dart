import 'dart:async';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/packages/flutter_typeahead/lib/flutter_typeahead.dart';

class LMTaggingAheadTextField extends StatefulWidget {
  final bool isDown;
  final FocusNode focusNode;
  final Function(LMUserTagViewData) onTagSelected;
  final TextEditingController controller;
  final InputDecoration? decoration;
  final Function(String)? onChange;
  final int? maxLines;
  final int minLines;
  final bool enabled;
  final ScrollPhysics scrollPhysics;

  const LMTaggingAheadTextField({
    super.key,
    required this.isDown,
    required this.onTagSelected,
    required this.controller,
    required this.focusNode,
    this.decoration,
    required this.onChange,
    this.maxLines,
    this.minLines = 1,
    this.enabled = true,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
  });

  @override
  State<LMTaggingAheadTextField> createState() => _TaggingAheadTextFieldState();
}

class _TaggingAheadTextFieldState extends State<LMTaggingAheadTextField> {
  late final TextEditingController _controller;
  FocusNode? _focusNode;
  final ScrollController _scrollController = ScrollController();
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();

  List<UserTag> userTags = [];

  int page = 1;
  int tagCount = 0;
  bool tagComplete = false;
  String textValue = "";
  String tagValue = "";
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
    _focusNode = widget.focusNode;
    _controller = widget.controller;
    _scrollController.addListener(() async {
      // page++;
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

          userTags.addAll(taggingData.members!.map((e) => e).toList());
          // return userTags;
        }
      }
    });
  }

  TextEditingController? get controller => _controller;

  FutureOr<Iterable<LMUserTagViewData>> _getSuggestions(String query) async {
    String currentText = query;
    try {
      if (currentText.isEmpty) {
        return const Iterable.empty();
      } else if (!tagComplete && currentText.contains('@')) {
        String tag = tagValue.substring(1).replaceAll(' ', '');
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
          userTags = taggingData.members!.map((e) => e).toList();
          return userTags
              .map((e) => LMUserTagViewDataConvertor.fromUserTag(e))
              .toList();
        }
        return const Iterable.empty();
      } else {
        return const Iterable.empty();
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);

      return const Iterable.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TypeAheadField<LMUserTagViewData>(
        onTagTap: (p) {},
        scrollController: _scrollController,
        tagColor: feedTheme.tagColor,
        scrollPhysics: widget.scrollPhysics,
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
        debounceDuration: const Duration(milliseconds: 500),
        textFieldConfiguration: TextFieldConfiguration(
          keyboardType: TextInputType.multiline,
          cursorColor: feedTheme.primaryColor,
          controller: _controller,
          focusNode: _focusNode,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: widget.decoration ??
              const InputDecoration(
                hintText: 'Write something here...',
                border: InputBorder.none,
              ),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
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
            // _controller.text.substring(_controller.text.lastIndexOf('@'));
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
      ),
    );
  }
}

extension NthOccurrenceOfSubstring on String {
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

  bool hasNthOccurrence(String stringToFind, int n) {
    return nThIndexOf(stringToFind, n) != -1;
  }
}
