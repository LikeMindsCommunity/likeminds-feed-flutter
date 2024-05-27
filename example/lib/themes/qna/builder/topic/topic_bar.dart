import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';


// Topic List bar used to filter post under a topic
// on Topic Detail Page
class LMFeedChildTopicBar extends StatefulWidget {
  final List<String> parentTopicId;
  final List<LMTopicViewData> selectedTopics;
  final Function(LMTopicViewData)? onTopicTap;
  final LMFeedChildTopicBarStyle? style;

  const LMFeedChildTopicBar({
    super.key,
    required this.parentTopicId,
    this.onTopicTap,
    required this.selectedTopics,
    this.style,
  });

  copywith({
    List<String>? parentTopicId,
    List<LMTopicViewData>? selectedTopics,
    Function(LMTopicViewData)? onTopicTap,
    LMFeedChildTopicBarStyle? style,
  }) {
    return LMFeedChildTopicBar(
      parentTopicId: parentTopicId ?? this.parentTopicId,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      onTopicTap: onTopicTap ?? this.onTopicTap,
      style: style ?? this.style,
    );
  }

  @override
  State<LMFeedChildTopicBar> createState() => LMFeedChildTopicBarState();
}

class LMFeedChildTopicBarState extends State<LMFeedChildTopicBar> {
  Set<LMTopicViewData> selectedTopics = {};

  PagingController<int, LMTopicViewData> pagingController =
      PagingController<int, LMTopicViewData>(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    selectedTopics = widget.selectedTopics.toSet();

    pagingController.addPageRequestListener(addPaginationListener);
  }

  @override
  void didUpdateWidget(covariant LMFeedChildTopicBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedTopics = widget.selectedTopics.toSet();
    if (widget.parentTopicId != oldWidget.parentTopicId) {
      pagingController.refresh();
    }
  }

  void addPaginationListener(pageKey) {
    LMQnAFeedUtils.getChildTopics(widget.parentTopicId, page: pageKey)
        .then((value) {
      if (value.success) {
        if (value.childTopics != null &&
            value.childTopics!.isNotEmpty &&
            value.childTopics!.containsKey(widget.parentTopicId.first)) {
          List<LMTopicViewData> topics = value
              .childTopics![widget.parentTopicId.first]!
              .map((e) => LMTopicViewDataConvertor.fromTopic(e))
              .toList();
          if (topics.length < 20) {
            pagingController.appendLastPage(topics);
          } else {
            pagingController.appendPage(topics, pageKey);
          }
        } else {
          pagingController.appendLastPage([]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return Container(
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? feedThemeData.container,
        borderRadius: widget.style?.borderRadius,
        boxShadow: widget.style?.boxShadow,
      ),
      child: PagedListView<int, LMTopicViewData>(
        pagingController: pagingController,
        scrollDirection: Axis.horizontal,
        builderDelegate: PagedChildBuilderDelegate<LMTopicViewData>(
          noItemsFoundIndicatorBuilder: (context) => const SizedBox(),
          itemBuilder: (context, item, index) {
            bool isSelected = selectedTopics.contains(item);

            return Container(
              margin: widget.style?.margin,
              padding: widget.style?.padding,
              decoration: BoxDecoration(
                color: widget.style?.backgroundColor ?? feedThemeData.container,
                borderRadius: widget.style?.borderRadius,
                boxShadow: widget.style?.boxShadow,
              ),
              child: LMFeedTopicChip(
                topic: item,
                isSelected: isSelected,
                style: isSelected
                    ? (widget.style?.activeChipStyle ??
                        feedThemeData.topicStyle.activeChipStyle)
                    : (widget.style?.inactiveChipStyle ??
                        feedThemeData.topicStyle.inactiveChipStyle),
                onTap: (p0, p1) {
                  if (widget.onTopicTap != null) {
                    widget.onTopicTap!(item);
                  }

                  setState(() {
                    if (selectedTopics.contains(item)) {
                      selectedTopics.remove(item);
                    } else {
                      selectedTopics.add(item);
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class LMFeedChildTopicBarStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  final LMFeedTopicChipStyle? activeChipStyle;
  final LMFeedTopicChipStyle? inactiveChipStyle;

  const LMFeedChildTopicBarStyle({
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.activeChipStyle,
    this.inactiveChipStyle,
  });

  LMFeedChildTopicBarStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    LMFeedTopicChipStyle? activeChipStyle,
    LMFeedTopicChipStyle? inactiveChipStyle,
  }) {
    return LMFeedChildTopicBarStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      activeChipStyle: activeChipStyle ?? this.activeChipStyle,
      inactiveChipStyle: inactiveChipStyle ?? this.inactiveChipStyle,
    );
  }
}
