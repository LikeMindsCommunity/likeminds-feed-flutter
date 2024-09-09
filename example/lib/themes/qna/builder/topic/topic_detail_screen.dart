import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_bar.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/search_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

// Topic Details Screen
// Used to show details of a topic and its posts
// Also used to filter posts under a topic
class LMFeedTopicDetailsScreen extends StatefulWidget {
  final LMTopicViewData topicViewData;

  const LMFeedTopicDetailsScreen({
    super.key,
    required this.topicViewData,
  });

  @override
  State<LMFeedTopicDetailsScreen> createState() =>
      _LMFeedTopicDetailsScreenState();
}

class _LMFeedTopicDetailsScreenState extends State<LMFeedTopicDetailsScreen> {
  LMTopicViewData? topicViewData;
  Future<List<String>>? getTopicsFuture;
  ValueNotifier<bool> rebuildActionables = ValueNotifier(false);

  List<String> updatedTopicIds = [];

  List<LMTopicViewData> selectedTopics = [];

  PagingController<int, LMPostViewData> feedPagingController =
      PagingController<int, LMPostViewData>(firstPageKey: 0);

  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  Future<bool>? isTopicFollowed;

  List<dynamic> pgc = [];

  @override
  void initState() {
    super.initState();
    topicViewData = widget.topicViewData;
    updatedTopicIds = [topicViewData!.id];
    getTopicsFuture = getFilteredTopicIds();
    isTopicFollowed = checkIfTopicFollowed();
    if (topicViewData?.widgetViewData?.metadata.containsKey("pgc") ?? false) {
      if (topicViewData?.widgetViewData?.metadata["pgc"]
              ?.containsKey("post_links") ??
          false) {
        pgc =
            topicViewData!.widgetViewData!.metadata["pgc"]["post_links"] ?? [];
      }
    }
  }

  @override
  void didUpdateWidget(covariant LMFeedTopicDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicViewData != widget.topicViewData) {
      topicViewData = widget.topicViewData;
      updatedTopicIds = [topicViewData!.id];
      getTopicsFuture = getFilteredTopicIds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        LMFeedUniversalBloc.instance.selectedTopics = [];
        return Future.value(true);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          selectedTopics.clear();
          updatedTopicIds = [topicViewData!.id];

          setState(() {});
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                collapsedHeight: 60,
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: feedThemeData.container,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: feedThemeData.onContainer),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon:
                          Icon(Icons.search, color: feedThemeData.onContainer),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMQnASearchScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: LMFeedImage(
                    image: LMAttachmentViewData.fromMediaUrl(
                        url: topicViewData!
                                .widgetViewData?.metadata["cover_image"] ??
                            "",
                        attachmentType: LMMediaType.image),
                    style: const LMFeedPostImageStyle(
                      errorWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 15),
                          LMFeedIcon(
                            type: LMFeedIconType.icon,
                            icon: Icons.error,
                            style: LMFeedIconStyle(
                                color: textSecondary, fit: BoxFit.cover),
                          ),
                          SizedBox(height: 5),
                          LMFeedText(
                            text: "Unable to fetch image",
                            style: LMFeedTextStyle(
                              textStyle: TextStyle(
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              topicDetailsWidget(),
              topicFilterBar(),
              LMFeedList(
                selectedTopicIds: updatedTopicIds,
                pagingController: feedPagingController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topicDetailsWidget() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: feedThemeData.container,
            border:
                Border(bottom: BorderSide(color: feedThemeData.disabledColor))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: feedThemeData.backgroundColor,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage(
                        topicViewData!.widgetViewData?.metadata["icon"] ?? "",
                      ),
                    ),
                  ),
                  child: LMFeedImage(
                    image: LMAttachmentViewData.fromMediaUrl(
                        url: topicViewData!.widgetViewData?.metadata["icon"] ??
                            "",
                        attachmentType: LMMediaType.image),
                    style: const LMFeedPostImageStyle(
                      errorWidget: LMFeedIcon(
                        type: LMFeedIconType.icon,
                        icon: Icons.error,
                        style: LMFeedIconStyle(color: textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LMFeedText(
                        text: topicViewData!.name,
                        style: const LMFeedTextStyle(
                          overflow: TextOverflow.ellipsis,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                            fontSize: 20,
                            height: 1.25,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ValueListenableBuilder(
                  valueListenable: rebuildActionables,
                  builder: (context, topicFollowStatus, __) {
                    return FutureBuilder(
                      future: isTopicFollowed,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          return LMFeedButton(
                            text: LMFeedText(
                                text:
                                    topicFollowStatus ? "Unfollow" : "Follow"),
                            style: LMFeedButtonStyle(
                              border:
                                  Border.all(color: textPrimary, width: 1.0),
                              borderRadius: 100,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                            ),
                            onTap: () async {
                              LMUserViewData? user = LMFeedLocalPreference
                                  .instance
                                  .fetchUserData();

                              if (user == null) {
                                return;
                              }

                              UpdateUserTopicsRequestBuilder requestBuilder =
                                  UpdateUserTopicsRequestBuilder();

                              requestBuilder
                                ..uuid(user.uuid)
                                ..topicsId(
                                  {widget.topicViewData.id: !topicFollowStatus},
                                );

                              rebuildActionables.value = !topicFollowStatus;

                              UpdateUserTopicsResponse response =
                                  await LMFeedCore.client
                                      .updateUserTopics(requestBuilder.build());

                              if (!response.success) {
                                rebuildActionables.value = topicFollowStatus;

                                LMFeedCore.showSnackBar(
                                    context,
                                    response.errorMessage ?? "",
                                    LMFeedWidgetSource.topicDetailScreen);
                              }
                            },
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                              height: 25, width: 25, child: LMFeedLoader());
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            LMFeedText(
              text: topicViewData!.widgetViewData?.metadata["description"] ??
                  "--",
              style: const LMFeedTextStyle(
                overflow: TextOverflow.visible,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  fontSize: 12,
                  height: 1.75,
                  letterSpacing: 0.2,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...(pgc
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LMFeedText(
                            text: e["text"] ?? "--",
                            style: const LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                                fontSize: 12,
                                letterSpacing: 0.2,
                                height: 1.75,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.link,
                                  size: 16, color: feedThemeData.primaryColor),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Uri? uri = Uri.tryParse(e["link"] ?? "");
                                  if (uri != null) {
                                    canLaunchUrl(uri);
                                  }
                                },
                                behavior: HitTestBehavior.translucent,
                                child: LMFeedText(
                                  text: e["link"] ?? "--",
                                  style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter",
                                      fontSize: 12,
                                      letterSpacing: 0.2,
                                      height: 1.75,
                                      color: feedThemeData.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList()),
            if (pgc.isNotEmpty) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget topicFilterBar() {
    return SliverToBoxAdapter(
      child: FutureBuilder(
        future: getTopicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Container(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              height: 60,
              decoration: BoxDecoration(color: feedThemeData.container),
              child: LMFeedChildTopicBar(
                onTopicTap: (topic) {
                  if (selectedTopics.contains(topic)) {
                    selectedTopics.remove(topic);
                  } else {
                    selectedTopics.add(topic);
                  }
                  setState(() {
                    updatedTopicIds = selectedTopics.isEmpty
                        ? [topicViewData!.id]
                        : selectedTopics.map((e) {
                            return "${topicViewData!.id}#\$AND\$#${e.id}";
                          }).toList();
                  });
                },
                parentTopicId: snapshot.data!,
                selectedTopics: selectedTopics,
                style: LMFeedChildTopicBarStyle(
                  activeChipStyle: feedThemeData.topicStyle.activeChipStyle
                      ?.copyWith(
                          borderColor: feedThemeData.primaryColor,
                          backgroundColor: primaryBackgroundDark,
                          showBorder: true,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15.0)),
                  inactiveChipStyle: feedThemeData.topicStyle.inactiveChipStyle
                      ?.copyWith(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15.0)),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<List<String>> getFilteredTopicIds() async {
    GetTopicsResponse getTopicsResponse =
        await LMQnAFeedUtils.getParentTopicsFromCache();

    if (getTopicsResponse.success) {
      List<Topic> topics = getTopicsResponse.topics!;

      topics.removeWhere((e) => e.id == widget.topicViewData.parentId);

      return topics.map((e) => e.id).toList();
    }

    return [];
  }

  Future<bool> checkIfTopicFollowed() async {
    LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();

    bool isTopicFollowed = false;

    if (user != null) {
      GetUserTopicsRequest request =
          (GetUserTopicsRequestBuilder()..uuids([user.uuid])).build();
      await LMFeedCore.client.getUserTopics(request).then((value) {
        if (value.success) {
          if (value.userTopics!.containsKey(user.uuid) &&
              value.userTopics![user.uuid]!.contains(widget.topicViewData.id)) {
            isTopicFollowed = true;
            rebuildActionables.value = true;
          }
        }

        return value;
      });
    }

    return isTopicFollowed;
  }
}
