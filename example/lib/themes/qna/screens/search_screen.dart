import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/topic_detail_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/search_post_list.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/search_screen_shimmer.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/search_topic_list.dart';

class LMQnASearchScreen extends StatefulWidget {
  const LMQnASearchScreen({super.key});

  @override
  State<LMQnASearchScreen> createState() => _LMQnASearchScreenState();
}

class _LMQnASearchScreenState extends State<LMQnASearchScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  LMFeedThemeData theme = LMFeedCore.theme;
  final searchController = TextEditingController();
  final showCancelIcon = ValueNotifier<bool>(false);
  CancelableOperation? _debounceOperation;
  LMFeedSearchBloc searchBloc = LMFeedSearchBloc();
  LMFeedTopicBloc topicBloc = LMFeedTopicBloc();
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
  }

  void _onTextChanged(String value) {
    _debounceOperation?.cancel();
    _debounceOperation = CancelableOperation.fromFuture(
      Future.delayed(const Duration(milliseconds: 500)),
    );
    _debounceOperation?.value.then((_) {
      handleCancelIcon(value);
      _fetchSearchResults(value);
    });
  }

  void handleCancelIcon(String value) {
    if (value.isNotEmpty) {
      if (!showCancelIcon.value) showCancelIcon.value = true;
    } else {
      if (showCancelIcon.value) showCancelIcon.value = false;
    }
  }

  Future<void> _fetchSearchResults(String value) async {
    searchBloc.add(
      LMFeedGetSearchEvent(
        query: value,
        page: 1,
        pageSize: 3,
        type: 'heading',
      ),
    );
    if (value.isNotEmpty) {
      topicBloc.add(LMFeedGetTopicEvent(
          getTopicFeedRequest: (GetTopicsRequestBuilder()
                ..page(1)
                ..pageSize(3)
                ..searchType("name")
                ..search(value))
              .build()));
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.container,
        foregroundColor: theme.onContainer,
        toolbarHeight: 80,
        titleSpacing: 0,
        leadingWidth: 45,
        leading: LMFeedButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          style: const LMFeedButtonStyle(
              padding: EdgeInsets.only(left: 10),
              icon: LMFeedIcon(
                type: LMFeedIconType.icon,
                icon: Icons.arrow_back,
              )),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: TextField(
            controller: searchController,
            onChanged: _onTextChanged,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Search anything in this community',
              hintMaxLines: 1,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: qNaPrimaryColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: qNaPrimaryColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: qNaPrimaryColor,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: qNaPrimaryColor,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: qNaPrimaryColor,
                  width: 1.0,
                ),
              ),
              prefixIcon: const Icon(Icons.search, color: qNaPrimaryColor),
              suffixIcon: ValueListenableBuilder(
                  valueListenable: showCancelIcon,
                  builder: (context, value, child) {
                    return value
                        ? TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: qNaPrimaryColor,
                              padding: const EdgeInsets.only(right: 10),
                            ),
                            child: const Text("Cancel"),
                            onPressed: () {
                              searchController.clear();
                              searchBloc.add(
                                LMFeedClearSearchEvent(),
                              );
                              topicBloc.add(LMFeedInitTopicEvent());
                              showCancelIcon.value = false;
                            },
                          )
                        : const SizedBox();
                  }),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: theme.backgroundColor,
            child: ValueListenableBuilder(
                valueListenable: selectedIndex,
                builder: (context, index, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          _fetchSearchResults(searchController.text);
                          selectedIndex.value = 0;
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.container,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: selectedIndex.value == 0
                                    ? qNaPrimaryColor
                                    : const Color.fromRGBO(230, 234, 233, 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color: theme.onContainer,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          _fetchSearchResults(searchController.text);
                          selectedIndex.value = 1;
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.container,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: selectedIndex.value == 1
                                    ? qNaPrimaryColor
                                    : const Color.fromRGBO(230, 234, 233, 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                postTitleFirstCap,
                                style: TextStyle(
                                  color: theme.onContainer,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          _fetchSearchResults(searchController.text);
                          selectedIndex.value = 2;
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.container,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: selectedIndex.value == 2
                                    ? qNaPrimaryColor
                                    : const Color.fromRGBO(230, 234, 233, 1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Hashtags',
                                style: TextStyle(
                                  color: theme.onContainer,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )),
                      ),
                    ],
                  );
                }),
          ),
          ValueListenableBuilder(
              valueListenable: selectedIndex,
              builder: (context, index, __) {
                switch (index) {
                  case 0:
                    return _defAllSearchView();
                  case 1:
                    return Expanded(
                        child: LMQnASearchPostListView(
                      searchController: searchController,
                    ));
                  case 2:
                    return Expanded(
                        child: LMQnASearchTopicListView(
                            searchController: searchController));
                  default:
                    return _defAllSearchView();
                }
              })
        ],
      ),
    );
  }

  Widget _defAllSearchView() {
    Size screenSize = MediaQuery.of(context).size;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // posts:
            BlocConsumer<LMFeedSearchBloc, LMFeedSearchState>(
              bloc: searchBloc,
              buildWhen: (previous, current) {
                if (previous is LMFeedSearchLoadedState &&
                    current is LMFeedSearchLoadedState) {
                  return false;
                }
                return true;
              },
              listener: (context, state) {
                if (state is LMFeedSearchErrorState) {
                  LMFeedCore.showSnackBar(
                    context,
                    state.message,
                    LMFeedWidgetSource.searchScreen,
                  );
                }
              },
              builder: (context, state) {
                if (state is LMFeedSearchLoadingState) {
                  return Container(
                    width: double.infinity,
                    color: theme.container,
                    padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: SizedBox(
                        height: screenSize.height * 0.9,
                        child: const SearchScreenShimmer()),
                  );
                } else if (state is LMFeedSearchLoadedState) {
                  return Column(
                    children: [
                      if (state.posts.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          color: theme.container,
                          width: double.infinity,
                          child: LMFeedText(
                              text: postTitleFirstCap,
                              style: LMFeedTextStyle(
                                  textAlign: TextAlign.left,
                                  textStyle: TextStyle(
                                      fontFamily: "Inter",
                                      color: theme.onContainer,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w600))),
                        ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          return _defPostTile(context, state.posts[index]);
                        },
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // hashtags:
            BlocConsumer<LMFeedTopicBloc, LMFeedTopicState>(
              bloc: topicBloc,
              buildWhen: (previous, current) {
                if (previous is LMFeedTopicLoadedState &&
                    current is LMFeedTopicLoadingState) {
                  return false;
                }
                return true;
              },
              listener: (context, state) {
                if (state is LMFeedTopicErrorState) {
                  LMFeedCore.showSnackBar(
                    context,
                    state.errorMessage,
                    LMFeedWidgetSource.searchScreen,
                  );
                }
              },
              builder: (context, state) {
                if (state is LMFeedTopicLoadingState) {
                  return const SizedBox();
                } else if (state is LMFeedTopicLoadedState) {
                  Map<String, LMWidgetViewData> widgets = state
                          .getTopicFeedResponse.widgets
                          ?.map((key, value) => MapEntry(
                              key,
                              LMWidgetViewDataConvertor.fromWidgetModel(
                                  value))) ??
                      {};

                  return Column(
                    children: [
                      if (state.getTopicFeedResponse.topics != null &&
                          state.getTopicFeedResponse.topics!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          color: theme.container,
                          width: double.infinity,
                          child: LMFeedText(
                              text: 'Hashtags',
                              style: LMFeedTextStyle(
                                  textAlign: TextAlign.left,
                                  textStyle: TextStyle(
                                      fontFamily: "Inter",
                                      color: theme.onContainer,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w600))),
                        ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            state.getTopicFeedResponse.topics?.length ?? 0,
                        itemBuilder: (context, index) {
                          final topic = state.getTopicFeedResponse.topics
                              ?.elementAt(index);
                          if (topic != null) {
                            final topicViewData =
                                LMTopicViewDataConvertor.fromTopic(topic,
                                    widgets: widgets);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: ListTile(
                                  tileColor: theme.container,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  // leading: const SizedBox.shrink(),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: LMFeedText(
                                      text: topicViewData.name,
                                      style: LMFeedTextStyle(
                                          maxLines: 2,
                                          textStyle: TextStyle(
                                              fontFamily: "Inter",
                                              color: theme.onContainer,
                                              fontSize: 14,
                                              height: 1.66,
                                              letterSpacing: 0.2,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LMFeedTopicDetailsScreen(
                                          topicViewData: topicViewData,
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding _defPostTile(BuildContext context, LMPostViewData post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        tileColor: theme.container,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        // leading: const SizedBox.shrink(),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LMFeedText(
            text: post.heading ?? "",
            style: LMFeedTextStyle(
                maxLines: 2,
                textStyle: TextStyle(
                    fontFamily: "Inter",
                    color: theme.onContainer,
                    fontSize: 14,
                    height: 1.66,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500)),
          ),
        ),

        subtitle: Row(children: [
          LMFeedText(
              text: LMFeedPostUtils.getLikeCountTextWithCount(post.likeCount),
              style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                color: textSecondary,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                height: 1.66,
                letterSpacing: 0.2,
                fontSize: 12,
              ))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: LMFeedText(
                text: "•",
                style: LMFeedTextStyle(
                    textStyle: TextStyle(
                  color: textSecondary,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  height: 1.66,
                  letterSpacing: 0.2,
                  fontSize: 12,
                ))),
          ),
          LMFeedText(
            text:
                "${post.commentCount} ${LMFeedPostUtils.getCommentCountText(post.commentCount)}",
            style: const LMFeedTextStyle(
                textStyle: TextStyle(
              color: textSecondary,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              height: 1.66,
              letterSpacing: 0.2,
              fontSize: 12,
            )),
          ),
        ]),
        onTap: () {
          // navigate to post details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
              ),
            ),
          );
        },
      ),
    );
  }
}
