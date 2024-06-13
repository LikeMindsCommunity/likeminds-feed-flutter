import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

// This widget is used to display a topic feed bar
// A [LMFeedTopicBar] displays a list of selected topics
// The [LMFeedTopicBar] can be customized by
// passing in the required parameters
class LMFeedTopicBar extends StatefulWidget {
  final List<LMTopicViewData> selectedTopics;
  final Function(BuildContext) openTopicSelector;
  final Function(LMTopicViewData)? removeTopicFromSelection;
  final Function()? clearAllSelection;
  final LMFeedTopicBarStyle? style;
  final bool isDesktopWeb;

  const LMFeedTopicBar({
    super.key,
    required this.selectedTopics,
    required this.openTopicSelector,
    this.removeTopicFromSelection,
    this.clearAllSelection,
    this.isDesktopWeb = false,
    this.style,
  });

  LMFeedTopicBar copyWith({
    List<LMTopicViewData>? selectedTopics,
    Function(BuildContext)? openTopicSelector,
    Function(LMTopicViewData)? removeTopicFromSelection,
    Function()? clearAllSelection,
    LMFeedTopicBarStyle? style,
    bool? isDesktopWeb,
  }) {
    return LMFeedTopicBar(
      selectedTopics: selectedTopics ?? this.selectedTopics,
      openTopicSelector: openTopicSelector ?? this.openTopicSelector,
      removeTopicFromSelection:
          removeTopicFromSelection ?? this.removeTopicFromSelection,
      style: style ?? this.style,
      isDesktopWeb: isDesktopWeb ?? this.isDesktopWeb,
      clearAllSelection: clearAllSelection ?? this.clearAllSelection,
    );
  }

  @override
  State<LMFeedTopicBar> createState() => _LMFeedTopicBarState();
}

class _LMFeedTopicBarState extends State<LMFeedTopicBar> {
  late LMFeedThemeData feedThemeData;
  late Size screenSize;
  late bool isDesktopWeb;

  @override
  void initState() {
    super.initState();
    isDesktopWeb = widget.isDesktopWeb;
  }

  @override
  void didUpdateWidget(covariant LMFeedTopicBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    isDesktopWeb = widget.isDesktopWeb;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feedThemeData = LMFeedTheme.instance.theme;
    screenSize = MediaQuery.sizeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.style?.width ?? double.infinity,
      height: widget.style?.height ?? 52,
      decoration: BoxDecoration(
        color: isDesktopWeb
            ? null
            : widget.style?.backgroundColor ?? feedThemeData.container,
        border: widget.style?.border,
        borderRadius: widget.style?.borderRadius,
        boxShadow: widget.style?.boxShadow,
      ),
      margin: widget.style?.margin,
      padding: widget.style?.padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () => widget.openTopicSelector(context),
        child: widget.selectedTopics.isEmpty
            ? _buildNoTopicSelectedView()
            : _buildTopicSelectedView(),
      ),
    );
  }

  Widget _buildNoTopicSelectedView() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.style?.backgroundColor ?? feedThemeData.container,
            borderRadius:
                isDesktopWeb ? BorderRadius.circular(4.0) : BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LMFeedText(
                  text: "All Topics",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: feedThemeData.textSecondary,
                    ),
                  ),
                ),
                LikeMindsTheme.kHorizontalPaddingSmall,
                LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.arrow_downward,
                  style: LMFeedIconStyle(
                    color: feedThemeData.textSecondary,
                    size: 16,
                    boxSize: 20,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicSelectedView() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktopWeb ? 0.0 : 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedTopics.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return LMFeedTopicChip(
                  isSelected: false,
                  topic: widget.selectedTopics[index],
                  onIconTap: widget.removeTopicFromSelection,
                  style: widget.style?.topicChipStyle ??
                      feedThemeData.topicStyle.inactiveChipStyle?.copyWith(
                        icon: LMFeedIcon(
                          type: LMFeedIconType.icon,
                          icon: Icons.close,
                          style: LMFeedIconStyle(
                            color: feedThemeData.primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                  onTap: (context, topic) {
                    widget.openTopicSelector(context);
                  },
                );
              },
            ),
          ),
          LMFeedButton(
            onTap: () {
              widget.clearAllSelection?.call();
            },
            text: LMFeedText(
              text: "Clear",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                    color: feedThemeData.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LMFeedTopicBarStyle {
  final Color? backgroundColor;

  final EdgeInsets? padding;
  final EdgeInsets? margin;

  final List<BoxShadow>? boxShadow;

  final Border? border;
  final BorderRadius? borderRadius;

  final double? height;
  final double? width;
  final String? topicChipText;
  final LMFeedTopicChipStyle? topicChipStyle;

  const LMFeedTopicBarStyle({
    this.backgroundColor,
    this.padding,
    this.border,
    this.borderRadius,
    this.margin,
    this.boxShadow,
    this.height,
    this.width,
    this.topicChipText,
    this.topicChipStyle,
  });

  LMFeedTopicBarStyle copyWith({
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? boxShadow,
    Border? border,
    BorderRadius? borderRadius,
    double? height,
    double? width,
    String? topicChipText,
    LMFeedTopicChipStyle? topicChipStyle,
  }) {
    return LMFeedTopicBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      margin: margin ?? this.margin,
      height: height ?? this.height,
      width: width ?? this.width,
      topicChipText: topicChipText ?? this.topicChipText,
      topicChipStyle: topicChipStyle ?? this.topicChipStyle,
    );
  }
}
