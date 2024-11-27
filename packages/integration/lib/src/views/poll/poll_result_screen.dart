import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPollResultScreen extends StatefulWidget {
  const LMFeedPollResultScreen({
    super.key,
    required this.pollId,
    required this.pollOptions,
    this.pollTitle,
    this.selectedOptionId,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.tabWidth,
  });

  final String pollId;
  final String? pollTitle;
  final List<LMPollOptionViewData> pollOptions;
  final String? selectedOptionId;
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;
  // Builder for error view while loading a new page
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;
  // Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;
  // width for the poll options tab
  final double? tabWidth;

  @override
  State<LMFeedPollResultScreen> createState() => _LMFeedPollResultScreenState();
}

class _LMFeedPollResultScreenState extends State<LMFeedPollResultScreen>
    with SingleTickerProviderStateMixin {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetBuilderDelegate _widgetsBuilder = LMFeedCore.config.widgetBuilderDelegate;
  LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  int initialIndex = 0;
  late TabController _tabController;
  late PageController _pagingController;
  int pageSize = 10;
  final _widgetUtility = LMFeedCore.config.widgetBuilderDelegate;

  @override
  initState() {
    super.initState();
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.pollAnswersViewed,
        eventProperties: {
          LMFeedStringConstants.pollId: widget.pollId,
          LMFeedStringConstants.pollTitle: widget.pollTitle ?? '',
        }));
    setTabController();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setTabController();
  }

  void setTabController() {
    _pagingController = PageController(initialPage: initialIndex);
    _tabController = TabController(
      length: widget.pollOptions.length,
      initialIndex: initialIndex,
      vsync: this,
    );
    if (widget.selectedOptionId != null) {
      int index = widget.pollOptions
          .indexWhere((element) => element.id == widget.selectedOptionId);
      if (index != -1) {
        initialIndex = index;
        if (_tabController.index != initialIndex) {
          _tabController.animateTo(initialIndex);
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (_pagingController.page != initialIndex) {
            _pagingController.jumpToPage(initialIndex);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return _widgetsBuilder.scaffold(
        backgroundColor: theme.container,
        appBar: LMFeedAppBar(
          style: LMFeedAppBarStyle(
            height: 40,
            padding: EdgeInsets.only(
              right: 16,
            ),
            backgroundColor: theme.container,
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          leading: BackButton(),
          title: LMFeedText(
            text: 'Poll Results',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: theme.onContainer,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            TabBar(
              onTap: (index) {
                _pagingController.animateToPage(index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
              controller: _tabController,
              dividerColor: theme.primaryColor,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 4,
              isScrollable: true,
              labelColor: theme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              unselectedLabelColor: theme.inActiveColor,
              tabs: [
                for (var option in widget.pollOptions)
                  Tab(
                    child: SizedBox(
                      width: widget.tabWidth ??
                          (widget.pollOptions.length == 2
                              ? width / 3
                              : width / 4),
                      child: Column(
                        children: [
                          LMFeedText(
                            text: option.voteCount.toString(),
                          ),
                          LMFeedText(
                            text: option.text,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SafeArea(
                child: PageView.builder(
                  onPageChanged: (index) {
                    triggerPollAnswersToggledEvent(index);
                    _tabController.animateTo(index);
                  },
                  controller: _pagingController,
                  itemCount: widget.pollOptions.length,
                  itemBuilder: (context, index) {
                    return _defListView(widget.pollOptions[index]);
                  },
                ),
              ),
            )
          ],
        ));
  }

  void triggerPollAnswersToggledEvent(int index) {
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.pollAnswersToggled,
        eventProperties: {
          LMFeedStringConstants.pollId: widget.pollId,
          LMFeedStringConstants.pollOptionId: widget.pollOptions[index].id,
          LMFeedStringConstants.pollOptionText: widget.pollOptions[index].text,
          LMFeedStringConstants.pollTitle: widget.pollTitle ?? '',
        }));
  }

  Widget _defListView(LMPollOptionViewData option) {
    if (option.voteCount <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMFeedIcon(
              style: LMFeedIconStyle(size: 100),
              type: LMFeedIconType.png,
              assetPath: lmNoResponsePng,
            ),
            SizedBox(height: 8),
            LMFeedText(
              text: 'No Responses',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      );
    }
    PagingController<int, LMUserViewData> pagingController =
        PagingController(firstPageKey: 1);
    _addPaginationListener(pagingController, [option.id]);

    return PagedListView<int, LMUserViewData>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return UserTile(user: item);
        },
        noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder ??
            _widgetUtility.noItemsFoundIndicatorBuilderFeed,
        firstPageProgressIndicatorBuilder:
            widget.firstPageProgressIndicatorBuilder ??
                _widgetUtility.firstPageProgressIndicatorBuilderFeed,
        newPageProgressIndicatorBuilder:
            widget.newPageProgressIndicatorBuilder ??
                _widgetUtility.newPageProgressIndicatorBuilderFeed,
        noMoreItemsIndicatorBuilder: widget.noMoreItemsIndicatorBuilder ??
            _widgetUtility.noMoreItemsIndicatorBuilderFeed,
      ),
    );
  }

  void _addPaginationListener(
      PagingController<int, LMUserViewData> _pagingController,
      List<String> votes) {
    _pagingController.addPageRequestListener(
      (pageKey) async {
        await _getUserList(_pagingController, pageKey, votes);
      },
    );
  }

  Future<void> _getUserList(
      PagingController<int, LMUserViewData> _pagingController,
      int page,
      List<String> votes) async {
    GetPollVotesRequest request = (GetPollVotesRequestBuilder()
          ..pollId(widget.pollId)
          ..votes(votes)
          ..page(page)
          ..pageSize(pageSize))
        .build();

    LMResponse<GetPollVotesResponse> response =
        await LMFeedCore.instance.lmFeedClient.getPollVotes(request);
    if (!response.success) {
      _pagingController.error = response.errorMessage;
      return;
    }

    Map<String, LMWidgetViewData> widgets =
        response.data?.widgets.map((key, value) {
              return MapEntry(
                  key, LMWidgetViewDataConvertor.fromWidgetModel(value));
            }) ??
            {};
    Map<String, LMTopicViewData> topics =
        response.data?.topics.map((key, value) {
              return MapEntry(key, LMTopicViewDataConvertor.fromTopic(value));
            }) ??
            {};

    List<LMUserViewData> users = [];
    if (response.data?.votes.isEmpty ?? true) {
      _pagingController.appendLastPage([]);
      return;
    }
    response.data?.votes.first.users.forEach((e) {
      final LMUserViewData user = LMUserViewDataConvertor.fromUser(
        response.data!.users[e]!,
        topics: topics,
        widgets: widgets,
        userTopics: response.data!.userTopics,
      );
      users.add(user);
    });

    if (users.isEmpty) {
      _pagingController.appendLastPage([]);
    } else {
      final isLastPage = users.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(users);
      } else {
        _pagingController.appendPage(users, page + 1);
      }
    }
  }
}

class UserTile extends StatelessWidget {
  final LMUserViewData? user;
  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: user!.isDeleted != null && user!.isDeleted!
          ? const DeletedLikesTile()
          : LMFeedUserTile(
              user: user!,
              subtitle: SizedBox.shrink(),
              style: const LMFeedTileStyle(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 16.0,
                  right: 8.0,
                ),
              ),
              onTap: () {
                LMFeedProfileBloc.instance.add(
                  LMFeedRouteToUserProfileEvent(
                    uuid: user?.sdkClientInfo.uuid ?? user?.uuid ?? '',
                    context: context,
                  ),
                );
              },
            ),
    );
  }
}
