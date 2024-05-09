import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/compose/fab_button.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/feed/lm_qna_feed.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_search_bottom_sheet.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';

class OnboardingScreen extends StatefulWidget {
  final String uuid;
  const OnboardingScreen({super.key, required this.uuid});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final LMFeedThemeData feedThemeData = LMFeedCore.theme;
  late final TabController _tabController;
  Set<String> selectedTopicIds = {};
  List<LMTopicViewData> selectedTopics = [];
  ValueNotifier<bool> chipBuilderNotifier = ValueNotifier(false);
  Future<GetTopicsResponse>? getParentTopics;
  Future<GetTopicsResponse>? getChildTopics;
  Size? screenSize;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getParentTopics = LMQnAFeedUtils.getParentTopicsFromCache()
      ..then((value) {
        if (value.success) {
          List<String> parentIds = value.topics!.map((e) => e.id).toList();

          getChildTopics = LMQnAFeedUtils.getChildTopics(parentIds)
            ..then((value) {
              if (!value.success) {
                LMFeedCore.showSnackBar(
                  context,
                  value.errorMessage ?? "",
                  LMFeedWidgetSource.searchScreen,
                );
              }
              return value;
            });
        }
        return value;
      });
  }

  @override
  void dispose() {
    chipBuilderNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 0) {
          return true;
        } else {
          _tabController.animateTo(0);
          return false;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: LMFeedButton(
            onTap: () {
              if (_tabController.index == 0) {
                Navigator.of(context).pop();
              } else {
                _tabController.animateTo(0);
              }
            },
            style: const LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.icon,
                icon: Icons.arrow_back,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: qNaOnboardingGradient,
          ),
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              entryPage(),
              topicSelectPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget entryPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          decoration: BoxDecoration(
            color: feedThemeData.container,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          width: screenSize!.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LMFeedText(
                text: "Explore QnA Community",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 20,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              const LMFeedText(
                text: "Discover, Connect, Wander",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                      height: 1.33,
                      letterSpacing: 0.15),
                ),
              ),
              const SizedBox(height: 10.0),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: onboardingTexts
                    .map(
                      (e) => LMFeedTile(
                        leading: SizedBox(
                          height: 30,
                          width: 30,
                          child: LMFeedIcon(
                            type: LMFeedIconType.svg,
                            assetPath: e["icon"],
                            style: const LMFeedIconStyle(size: 30),
                          ),
                        ),
                        title: LMFeedText(
                          text: e["text"],
                          style: const LMFeedTextStyle(
                            maxLines: 3,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                                height: 1.33,
                                letterSpacing: 0.15),
                          ),
                        ),
                        style: const LMFeedTileStyle(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: LMFeedButton(
                  onTap: () {},
                  text: LMFeedText(
                      text: "Terms & Conditions",
                      style: LMFeedTextStyle(
                          textStyle:
                              TextStyle(color: feedThemeData.primaryColor))),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: LMFeedButton(
                  onTap: () {
                    _tabController.animateTo(1);
                  },
                  text: LMFeedText(
                    text: "Get Started",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                          color: feedThemeData.onPrimary, height: 1.33),
                    ),
                  ),
                  style: const LMFeedButtonStyle(
                    borderRadius: 50,
                    backgroundColor: textPrimary,
                    padding: EdgeInsets.all(15.0),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget topicSelectPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LMFeedText(
                text: "Get started",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: feedThemeData.onPrimary,
                    fontSize: 20,
                    height: 1.25,
                  ),
                ),
              ),
              LMFeedText(
                text: "Tell us more about your trip!",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: feedThemeData.onPrimary,
                      height: 1.33,
                      letterSpacing: 0.15),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            decoration: BoxDecoration(
              color: feedThemeData.container,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            width: screenSize!.width,
            child: FutureBuilder(
                future: getParentTopics,
                builder: (context, parentTopicSnapshot) {
                  if (parentTopicSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LMFeedLoader();
                  } else if (parentTopicSnapshot.connectionState ==
                          ConnectionState.done &&
                      parentTopicSnapshot.data != null &&
                      parentTopicSnapshot.data!.success) {
                    GetTopicsResponse response = parentTopicSnapshot.data!;

                    Map<String, LMWidgetViewData> widgets = response.widgets
                            ?.map((key, value) => MapEntry(
                                key,
                                LMWidgetViewDataConvertor.fromWidgetModel(
                                    value))) ??
                        {};
                    List<LMTopicViewData> parentTopics = response.topics!
                        .map((e) => LMTopicViewDataConvertor.fromTopic(
                              e,
                              widgets: widgets,
                            ))
                        .toList();

                    if (parentTopics.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LMFeedText(
                          text: "Which countries you are planning to visit?",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        FutureBuilder(
                            future: getChildTopics,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LMFeedLoader();
                              } else if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null &&
                                  snapshot.data!.success) {
                                GetTopicsResponse response = snapshot.data!;

                                LMTopicViewData parentTopic =
                                    parentTopics.first;

                                Map<String, LMWidgetViewData> widgets =
                                    (response.widgets ?? {}).map((key, value) =>
                                        MapEntry(
                                            key,
                                            LMWidgetViewDataConvertor
                                                .fromWidgetModel(value)));

                                List<LMTopicViewData> childTopics = response
                                    .childTopics![parentTopic.id]!
                                    .map((e) =>
                                        LMTopicViewDataConvertor.fromTopic(e,
                                            widgets: widgets))
                                    .toList();

                                if (childTopics.isEmpty) {
                                  return const SizedBox();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ValueListenableBuilder<bool>(
                                        valueListenable: chipBuilderNotifier,
                                        builder: (context,
                                            changedSelectedTopics, child) {
                                          return Wrap(children: [
                                            ...childTopics
                                                .map((e) => topicChip(e))
                                                .take(7),
                                            if (parentTopic.totalChildCount! >
                                                7)
                                              loadMoreTopicsButton(
                                                  parentTopics.first.id,
                                                  "Destination",
                                                  "Search Country")
                                          ]);
                                        }),
                                  ],
                                );
                              }

                              return const SizedBox();
                            }),
                        const SizedBox(height: 15),
                        if (parentTopics.length > 1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LMFeedText(
                                text: "Select the topics that interest you",
                                style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                )),
                              ),
                              const SizedBox(height: 15),
                              FutureBuilder(
                                  future: getChildTopics,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const LMFeedLoader();
                                    } else if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null &&
                                        snapshot.data!.success) {
                                      GetTopicsResponse response =
                                          snapshot.data!;

                                      LMTopicViewData parentTopic =
                                          parentTopics.last;

                                      Map<String, LMWidgetViewData> widgets =
                                          (response.widgets ?? {}).map(
                                              (key, value) => MapEntry(
                                                  key,
                                                  LMWidgetViewDataConvertor
                                                      .fromWidgetModel(value)));

                                      List<LMTopicViewData> childTopics =
                                          response.childTopics![parentTopic.id]!
                                              .map((e) =>
                                                  LMTopicViewDataConvertor
                                                      .fromTopic(e,
                                                          widgets: widgets))
                                              .toList();

                                      if (childTopics.isEmpty) {
                                        return const SizedBox();
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ValueListenableBuilder(
                                              valueListenable:
                                                  chipBuilderNotifier,
                                              builder: (context, changedTopics,
                                                  child) {
                                                return Wrap(
                                                  children: [
                                                    ...childTopics.map((e) {
                                                      return topicChip(e);
                                                    }).take(7),
                                                    if (parentTopic
                                                            .totalChildCount! >
                                                        7)
                                                      loadMoreTopicsButton(
                                                          parentTopics.last.id,
                                                          "Interest",
                                                          "Search Interest")
                                                  ],
                                                );
                                              }),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  }),
                            ],
                          ),
                      ],
                    );
                  }
                  return const SizedBox();
                })),
        const SizedBox(height: 10),
        ValueListenableBuilder(
            valueListenable: chipBuilderNotifier,
            builder: (context, _, __) {
              return Container(
                color: feedThemeData.container,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: LMFeedButton(
                  onTap: () async {
                    if (selectedTopicIds.isEmpty) {
                      LMFeedCore.showSnackBar(
                        context,
                        "Please select at least one topic",
                        LMFeedWidgetSource.searchScreen,
                      );
                      return;
                    }

                    Map<String, bool> selectedTopicMap =
                        updateUserSelectedTopicsMap();

                    if (selectedTopicMap.isNotEmpty) {
                      UpdateUserTopicsRequestBuilder requestBuilder =
                          UpdateUserTopicsRequestBuilder();

                      requestBuilder
                        ..uuid(widget.uuid)
                        ..topicsId(selectedTopicMap);

                      UpdateUserTopicsResponse response = await LMFeedCore
                          .client
                          .updateUserTopics(requestBuilder.build());

                      if (response.success) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LMQnAFeedScreen(
                              newPageProgressIndicatorBuilder: LMFeedCore
                                  .widgetUtility
                                  .newPageProgressIndicatorBuilderFeed,
                              noMoreItemsIndicatorBuilder: LMFeedCore
                                  .widgetUtility
                                  .noMoreItemsIndicatorBuilderFeed,
                              floatingActionButtonLocation:
                                  FloatingActionButtonLocation.centerFloat,
                              floatingActionButtonBuilder:
                                  qnAFeedCreatePostFABBuilder,
                            ),
                          ),
                        );
                      } else {
                        LMFeedCore.showSnackBar(
                          context,
                          response.errorMessage ??
                              "An error occurred. Please try again.",
                          LMFeedWidgetSource.searchScreen,
                        );
                      }
                    }
                  },
                  style: LMFeedButtonStyle(
                      backgroundColor: selectedTopicIds.isEmpty
                          ? feedThemeData.disabledColor
                          : primaryCta,
                      padding: const EdgeInsets.all(15.0),
                      borderRadius: 50),
                  text: LMFeedText(
                    text: "Continue",
                    style: LMFeedTextStyle(
                      textStyle: TextStyle(
                        color: feedThemeData.onPrimary,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }

  Map<String, bool> updateUserSelectedTopicsMap() {
    Map<String, bool> selectedTopicMap = {};

    for (LMTopicViewData topic in selectedTopics) {
      selectedTopicMap[topic.id] = true;
    }

    return selectedTopicMap;
  }

  void showTopicSearchBottomSheet(
      String parentTopicId, String parentTitle, String searchTitle) async {
    List<LMTopicViewData>? topics = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      clipBehavior: Clip.hardEdge,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: LMTopicSearchBottomSheet(
            parentTopicId: parentTopicId,
            selectedTopics: selectedTopics,
            bottomSheetTitle: parentTitle,
            searchTitle: searchTitle,
          ),
        );
      },
    );

    if (topics != null) {
      selectedTopics = [...topics];
      selectedTopicIds = selectedTopics.map((e) => e.id).toSet();
    }

    chipBuilderNotifier.value = !chipBuilderNotifier.value;
  }

  // child topic chip
  Widget topicChip(LMTopicViewData topic) {
    bool isTopicSelected = checkIfTopicSelected(topic);

    EdgeInsets chipMargin = const EdgeInsets.only(bottom: 10.0, right: 5.0);
    EdgeInsets chipPadding =
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    TextStyle chipTextStyle = const TextStyle(
        color: textPrimary, fontSize: 12, fontWeight: FontWeight.w400);

    return LMFeedTopicChip(
      topic: topic,
      isSelected: isTopicSelected,
      onTap: (context, _) {
        addOrRemoveTopic(topic);
      },
      style: isTopicSelected
          ? feedThemeData.topicStyle.activeChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
              borderColor: feedThemeData.primaryColor,
              showBorder: true,
              iconPlacement: LMFeedIconButtonPlacement.start,
              icon: topic.widgetViewData != null &&
                      topic.widgetViewData!.metadata.containsKey("icon")
                  ? LMFeedImage(
                      imageUrl: topic.widgetViewData?.metadata['icon'],
                      style: const LMFeedPostImageStyle(
                          boxFit: BoxFit.contain, height: 15, width: 15),
                    )
                  : null,
            )
          : feedThemeData.topicStyle.inactiveChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
              iconPlacement: LMFeedIconButtonPlacement.start,
              icon: topic.widgetViewData != null &&
                      topic.widgetViewData!.metadata.containsKey("icon")
                  ? LMFeedImage(
                      imageUrl: topic.widgetViewData?.metadata['icon'],
                      style: const LMFeedPostImageStyle(
                          boxFit: BoxFit.contain, height: 15, width: 15),
                    )
                  : null,
            ),
    );
  }

  void addOrRemoveTopic(LMTopicViewData topic) {
    if (selectedTopicIds.contains(topic.id)) {
      selectedTopics.removeWhere((e) => e.id == topic.id);
      selectedTopicIds.remove(topic.id);
    } else {
      selectedTopics.add(topic);
      selectedTopicIds.add(topic.id);
    }

    chipBuilderNotifier.value = !chipBuilderNotifier.value;
  }

  bool checkIfTopicSelected(LMTopicViewData topic) =>
      selectedTopicIds.contains(topic.id);

  // opens the bottom sheet to select the topics
  // for a given parent topic
  Widget loadMoreTopicsButton(
      String parentTopicId, String parentTitle, String searchTitle) {
    return GestureDetector(
      onTap: () {
        showTopicSearchBottomSheet(parentTopicId, parentTitle, searchTitle);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
            border: Border.all(color: feedThemeData.disabledColor),
            borderRadius: BorderRadius.circular(50)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.add,
              style: LMFeedIconStyle(color: textPrimary, size: 16),
            ),
            LMFeedText(
              text: "Load More",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> onboardingTexts = [
    {
      "text": "Express, connect, share with over 2000 travel enthusiasts",
      "icon": qnAGift,
    },
    {
      "text":
          "Ask, discuss, make new friends and travel smarter, safer with Community",
      "icon": qnAUnlock,
    },
    {
      "text": "2334 members, 445 topics, 23 countries, 1123 replies",
      "icon": qnAMoney
    },
  ];
}
