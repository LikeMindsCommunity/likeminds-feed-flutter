import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_search_bottom_sheet.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';

class LMQnAEditProfileScreen extends StatefulWidget {
  const LMQnAEditProfileScreen({
    super.key,
    required this.user,
  });
  final LMUserViewData user;

  @override
  State<LMQnAEditProfileScreen> createState() => _LMQnAEditProfileScreenState();
}

class _LMQnAEditProfileScreenState extends State<LMQnAEditProfileScreen> {
  late TextEditingController _userIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _bioController;
  final ValueNotifier<bool> rebuildCounterText = ValueNotifier(true);
  Set<String> selectedTopicIds = {};
  List<LMTopicViewData> selectedTopics = [];
  ValueNotifier<bool> chipBuilderNotifier = ValueNotifier(false);
  LMFeedUserMetaBloc userMetaBloc = LMFeedUserMetaBloc.instance;

  Future<GetTopicsResponse>? getParentTopics;
  Future<GetTopicsResponse>? getChildTopics;
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  LMAttachmentViewData? _image;
  final ValueNotifier<bool> _rebuildProfileImage = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    setInitialValue();
    if (widget.user.topics != null) {
      selectedTopics = [...widget.user.topics ?? []];
      selectedTopicIds = selectedTopics.map((e) => e.id).toSet();
    }
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
  void didUpdateWidget(covariant LMQnAEditProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.topics != null) {
      selectedTopics = [...widget.user.topics ?? []];
      selectedTopicIds = selectedTopics.map((e) => e.id).toSet();
    }
    getParentTopics = LMQnAFeedUtils.getParentTopics()
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

  void setInitialValue() {
    _userIdController = TextEditingController(
      text: widget.user.widget?.metadata['username'],
    );
    _descriptionController = TextEditingController(
      text: widget.user.widget?.metadata['description'],
    );
    _bioController = TextEditingController(
      text: widget.user.widget?.metadata['bio'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (userMetaBloc.state is LMFeedUserMetaUpdateLoadingState) {
          return Future.value(false);
        }
        if (FocusScope.of(context).hasPrimaryFocus) {
          FocusScope.of(context).unfocus();
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: feedTheme.onContainer,
            ),
            onPressed: () {
              if (userMetaBloc.state is LMFeedUserMetaUpdateLoadingState) {
                return;
              }

              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: const BoxDecoration(
                            gradient: qNaProfileGradient,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: const BoxDecoration(
                                gradient: qNaProfileGradient,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            )
                          ],
                        ),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(left: 20),
                              child: ValueListenableBuilder(
                                  valueListenable: _rebuildProfileImage,
                                  builder: (context, _, __) {
                                    return LMFeedProfilePicture(
                                      // TODO: replace this with attachmentviewdata
                                      filePath: _image?.attachmentMeta.path,
                                      imageUrl: widget.user.imageUrl,
                                      fallbackText: widget.user.name,
                                      style: LMFeedProfilePictureStyle.basic()
                                          .copyWith(
                                        size: 80,
                                      ),
                                    );
                                  }),
                            ),
                            InkWell(
                              onTap: () async {
                                _image =
                                    (await LMFeedMediaHandler.pickSingleImage())
                                        .data;
                                _rebuildProfileImage.value =
                                    !_rebuildProfileImage.value;
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(1, 1),
                                      ),
                                    ]),
                                child: const LMFeedIcon(
                                  type: LMFeedIconType.svg,
                                  assetPath: qnAPenIcon,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: dividerDark),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const LMFeedText(
                                  text: 'Enter User ID',
                                  style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w400,
                                  )),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: rebuildCounterText,
                                    builder: (context, _, __) {
                                      return LMFeedText(
                                        text:
                                            "${_userIdController.text.length}/20",
                                        style: const LMFeedTextStyle(
                                            textStyle: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w400,
                                        )),
                                      );
                                    })
                              ],
                            ),
                            TextField(
                              onTapOutside: (PointerDownEvent event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: _userIdController,
                              maxLength: 20,
                              onChanged: (value) {
                                rebuildCounterText.value =
                                    !rebuildCounterText.value;
                              },
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                counter: SizedBox(),
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: dividerDark),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const LMFeedText(
                                  text: 'Add a bio',
                                  style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w400,
                                  )),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: rebuildCounterText,
                                    builder: (context, _, __) {
                                      return LMFeedText(
                                        text:
                                            "${_descriptionController.text.length}/140",
                                        style: const LMFeedTextStyle(
                                            textStyle: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w400,
                                        )),
                                      );
                                    })
                              ],
                            ),
                            TextField(
                              onTapOutside: (PointerDownEvent event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: _descriptionController,
                              onChanged: (value) {
                                rebuildCounterText.value =
                                    !rebuildCounterText.value;
                              },
                              maxLength: 140,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                counter: SizedBox(),
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: dividerDark),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                LMFeedText(
                                  text: 'Add a link',
                                  style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w400,
                                  )),
                                ),
                              ],
                            ),
                            TextField(
                              onTapOutside: (PointerDownEvent event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: _bioController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                counter: SizedBox(),
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FutureBuilder(
                          future: getParentTopics,
                          builder: (context, parentTopicSnapshot) {
                            if (parentTopicSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LMFeedLoader();
                            } else if (parentTopicSnapshot.connectionState ==
                                    ConnectionState.done &&
                                parentTopicSnapshot.data != null &&
                                parentTopicSnapshot.data!.success) {
                              GetTopicsResponse response =
                                  parentTopicSnapshot.data!;

                              Map<String, LMWidgetViewData> widgets = response
                                      .widgets
                                      ?.map((key, value) => MapEntry(
                                          key,
                                          LMWidgetViewDataConvertor
                                              .fromWidgetModel(value))) ??
                                  {};
                              List<LMTopicViewData> parentTopics = response
                                  .topics!
                                  .map(
                                      (e) => LMTopicViewDataConvertor.fromTopic(
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
                                    text:
                                        "Which countries you are planning to visit?",
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
                                          GetTopicsResponse response =
                                              snapshot.data!;

                                          LMTopicViewData parentTopic =
                                              parentTopics.first;

                                          Map<String, LMWidgetViewData>
                                              widgets = (response.widgets ?? {})
                                                  .map((key, value) => MapEntry(
                                                      key,
                                                      LMWidgetViewDataConvertor
                                                          .fromWidgetModel(
                                                              value)));

                                          List<LMTopicViewData> childTopics =
                                              response
                                                  .childTopics![parentTopic.id]!
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
                                              ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      chipBuilderNotifier,
                                                  builder: (context,
                                                      changedSelectedTopics,
                                                      child) {
                                                    return Wrap(children: [
                                                      ...childTopics
                                                          .map((e) =>
                                                              topicChip(e))
                                                          .take(6),
                                                    ]);
                                                  }),
                                              if (parentTopic.totalChildCount! >
                                                  6)
                                                loadMoreTopicsButton(
                                                    parentTopics.first.id,
                                                    "Destination",
                                                    "Search Country")
                                            ],
                                          );
                                        }

                                        return const SizedBox();
                                      }),
                                  const SizedBox(height: 15),
                                  if (parentTopics.length >= 2)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const LMFeedText(
                                          text:
                                              "Select the topics that interest you",
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
                                              } else if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.data != null &&
                                                  snapshot.data!.success) {
                                                GetTopicsResponse response =
                                                    snapshot.data!;

                                                LMTopicViewData parentTopic =
                                                    parentTopics.last;

                                                Map<String, LMWidgetViewData>
                                                    widgets =
                                                    (response.widgets ?? {}).map(
                                                        (key, value) => MapEntry(
                                                            key,
                                                            LMWidgetViewDataConvertor
                                                                .fromWidgetModel(
                                                                    value)));

                                                List<LMTopicViewData>
                                                    childTopics = response
                                                        .childTopics![
                                                            parentTopic.id]!
                                                        .map((e) =>
                                                            LMTopicViewDataConvertor
                                                                .fromTopic(
                                                              e,
                                                              widgets: widgets,
                                                            ))
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
                                                        builder: (context,
                                                            changedTopics,
                                                            child) {
                                                          return Wrap(
                                                            children: [
                                                              ...childTopics
                                                                  .map((e) {
                                                                return topicChip(
                                                                    e);
                                                              }).take(6),
                                                            ],
                                                          );
                                                        }),
                                                    if (parentTopic
                                                            .totalChildCount! >
                                                        6)
                                                      loadMoreTopicsButton(
                                                          parentTopics.last.id,
                                                          "Interest",
                                                          "Search Interest")
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
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      BlocConsumer<LMFeedUserMetaBloc, LMFeedUserMetaState>(
                        bloc: userMetaBloc,
                        listener: (context, state) {
                          if (state is LMFeedUserMetaUpdatedState) {
                            LMFeedCore.showSnackBar(
                                context,
                                "Profile updated successfully",
                                LMFeedWidgetSource.userProfileScreen);
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, state) {
                          if (state is LMFeedUserMetaUpdateLoadingState) {
                            return const LMFeedLoader();
                          }
                          return SizedBox(
                            width: double.infinity,
                            child: LMFeedButton(
                              style: const LMFeedButtonStyle(
                                height: 48,
                                backgroundColor: Color(0xff0E1226),
                                borderRadius: 100,
                              ),
                              text: const LMFeedText(
                                text: 'Save',
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                      color: Color(0xffFDFDFD),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              onTap: () async {
                                Map<String, bool> selectedTopicMap =
                                    updateUserSelectedTopicsMap();

                                if (selectedTopicMap.isNotEmpty) {
                                  UpdateUserTopicsRequestBuilder
                                      requestBuilder =
                                      UpdateUserTopicsRequestBuilder();

                                  requestBuilder
                                    ..uuid(widget.user.uuid)
                                    ..topicsId(selectedTopicMap);

                                  UpdateUserTopicsResponse response =
                                      await LMFeedCore.client.updateUserTopics(
                                          requestBuilder.build());
                                }

                                userMetaBloc.add(
                                  LMFeedUserMetaUpdateEvent(
                                    user: widget.user,
                                    imagePath: _image?.attachmentMeta.path,
                                    metadata: {
                                      'username': _userIdController.text,
                                      'description':
                                          _descriptionController.text,
                                      'bio': _bioController.text,
                                      'tag':
                                          widget.user.widget?.metadata['tag'],
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, bool> updateUserSelectedTopicsMap() {
    Map<String, bool> selectedTopicMap = {};

    List<LMTopicViewData> userTopics = widget.user.topics ?? [];

    for (LMTopicViewData topic in userTopics) {
      if (!selectedTopicIds.contains(topic.id)) {
        selectedTopicMap[topic.id] = false;
      }
    }

    for (LMTopicViewData topic in selectedTopics) {
      if (userTopics.indexWhere((element) => element.id == topic.id) == -1) {
        selectedTopicMap[topic.id] = true;
      }
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
          ? feedTheme.topicStyle.activeChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
              borderColor: feedTheme.primaryColor,
              showBorder: true,
              iconPlacement: LMFeedIconButtonPlacement.start,
              icon: topic.widgetViewData != null &&
                      topic.widgetViewData!.metadata.containsKey("icon")
                  ? LMFeedImage(
                      image: LMAttachmentViewData.fromMediaUrl(
                          url: topic.widgetViewData?.metadata['icon'],
                          attachmentType: LMMediaType.image),
                      style: const LMFeedPostImageStyle(
                          boxFit: BoxFit.contain, height: 15, width: 15),
                    )
                  : null,
            )
          : feedTheme.topicStyle.inactiveChipStyle?.copyWith(
              margin: chipMargin,
              textStyle: chipTextStyle,
              padding: chipPadding,
              iconPlacement: LMFeedIconButtonPlacement.start,
              icon: topic.widgetViewData != null &&
                      topic.widgetViewData!.metadata.containsKey("icon")
                  ? LMFeedImage(
                      image: LMAttachmentViewData.fromMediaUrl(
                          url: topic.widgetViewData?.metadata['icon'],
                          attachmentType: LMMediaType.image),
                      style: const LMFeedPostImageStyle(
                          boxFit: BoxFit.contain, height: 15, width: 15),
                    )
                  : null,
            ),
    );
  }

  // opens the bottom sheet to select the topics
  // for a given parent topic
  Widget loadMoreTopicsButton(
      String parentTopicId, String parentTitle, String searchTitle) {
    return GestureDetector(
      onTap: () {
        showTopicSearchBottomSheet(parentTopicId, parentTitle, searchTitle);
      },
      behavior: HitTestBehavior.translucent,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LMFeedText(
                text: "Load More",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    color: feedTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
