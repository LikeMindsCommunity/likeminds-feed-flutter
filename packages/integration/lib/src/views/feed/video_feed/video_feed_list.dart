import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedVideoFeedListView extends StatefulWidget {
  const LMFeedVideoFeedListView({super.key});

  @override
  State<LMFeedVideoFeedListView> createState() =>
      _LMFeedVideoFeedListViewState();
}

class _LMFeedVideoFeedListViewState extends State<LMFeedVideoFeedListView> {
  final _theme = LMFeedCore.theme;
  final _pagingController = PagingController<int, LMPostViewData>(
    firstPageKey: 0,
  );

  // bloc to handle universal feed
  final LMFeedUniversalBloc _feedBloc = LMFeedUniversalBloc.instance;

  @override
  void initState() {
    super.initState();
    LMFeedVideoProvider.instance.isMuted.value = false;
    _addPaginationListener();
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          LMFeedGetUniversalFeedEvent(
            pageKey: pageKey,
            topicsIds: _feedBloc.selectedTopics.map((e) => e.id).toList(),
          ),
        );
      },
    );
  }

  // This function updates the paging controller based on the state changes
  void universalBlocListener(
      BuildContext context, LMFeedUniversalState? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts;

      _feedBloc.users.addAll(state.users);
      _feedBloc.topics.addAll(state.topics);
      _feedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }
    } else if (state is LMFeedUniversalRefreshState) {
      // getUserFeedMeta = getUserFeedMetaFuture();
      // _rebuildAppBar.value = !_rebuildAppBar.value;
      // clearPagingController();
      // refresh();
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feed screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocListener<LMFeedUniversalBloc, LMFeedUniversalState>(
      bloc: _feedBloc,
      listener: universalBlocListener,
      child: SafeArea(
        child: PagedPageView<int, LMPostViewData>(
          pagingController: _pagingController,
          scrollDirection: Axis.vertical,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              return Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    height: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: LMFeedVideo(
                        key: ObjectKey(item.id),
                        postId: item.id,
                        video: item.attachments!.first,
                        autoPlay: true,
                      ),
                    ),
                  ),
                  // user view
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: size.width - 68,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LMFeedPostHeader(
                                createdAtBuilder: (context, text) {
                                  return text.copyWith(
                                      style: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: _theme.container,
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ));
                                },
                                user: LMFeedLocalPreference.instance
                                    .fetchUserData()!,
                                isFeed: true,
                                postViewData: item,
                                postHeaderStyle:
                                    LMFeedPostHeaderStyle.basic().copyWith(
                                  titleTextStyle: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: _theme.container,
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  subTextStyle: LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: _theme.container,
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              LMFeedPostContent(
                                text: item.text,
                                style: LMFeedPostContentStyle(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  headingSeparator: const SizedBox(height: 0.0),
                                  visibleLines: 2,
                                  headingStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _theme.container,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _theme.container,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  expandTextStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _theme.container,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              LMFeedButton(
                                onTap: () {},
                                style: LMFeedButtonStyle(
                                  gap: 0,
                                  icon: LMFeedIcon(
                                    type: LMFeedIconType.svg,
                                    assetPath: lmLikeInActiveSvg,
                                    style: LMFeedIconStyle(
                                      size: 32,
                                      fit: BoxFit.contain,
                                      color: _theme.container,
                                    ),
                                  ),
                                  activeIcon: LMFeedIcon(
                                    type: LMFeedIconType.svg,
                                    assetPath: lmLikeActiveSvg,
                                    style: LMFeedIconStyle(
                                      size: 32,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  borderRadius: 100,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                        0.1,
                                      ),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              LMFeedText(
                                text: '31K',
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: _theme.container,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              LMFeedButton(
                                onTap: () {},
                                style: LMFeedButtonStyle(
                                  gap: 0,
                                  icon: LMFeedIcon(
                                    type: LMFeedIconType.svg,
                                    assetPath: lmCommentSvg,
                                    style: LMFeedIconStyle(
                                      size: 32,
                                      color: _theme.container,
                                    ),
                                  ),
                                  borderRadius: 100,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                        0.1,
                                      ),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              LMFeedText(
                                text: '3.1K',
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: _theme.container,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              LMFeedButton(
                                onTap: () {},
                                style: LMFeedButtonStyle(
                                  gap: 0,
                                  icon: LMFeedIcon(
                                    type: LMFeedIconType.icon,
                                    icon: Icons.more_horiz,
                                    style: LMFeedIconStyle(
                                      size: 32,
                                      color: _theme.container,
                                    ),
                                  ),
                                  borderRadius: 100,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                        0.1,
                                      ),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
