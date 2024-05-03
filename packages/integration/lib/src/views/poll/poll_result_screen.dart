import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:media_kit/media_kit.dart';

class LMFeedPollResultScreen extends StatefulWidget {
  const LMFeedPollResultScreen({
    super.key,
    required this.pollId,
    required this.pollOptions,
    this.selectedOptionId,
  });

  final String pollId;
  final List<LMPollOptionViewData> pollOptions;
  final String? selectedOptionId;

  @override
  State<LMFeedPollResultScreen> createState() => _LMFeedPollResultScreenState();
}

class _LMFeedPollResultScreenState extends State<LMFeedPollResultScreen>
    with SingleTickerProviderStateMixin {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();
  int initialIndex = 0;
  late TabController _tabController;
  late PageController _pagingController;

  @override
  initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _widgetsBuilder.scaffold(
        backgroundColor: theme.container,
        appBar: LMFeedAppBar(
          style: LMFeedAppBarStyle(
            height: 40,
            padding: EdgeInsets.only(
              right: 16,
            ),
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          leading: BackButton(),
          title: LMFeedText(
            text: 'Poll Results',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
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
              isScrollable: true,
              dividerColor: theme.primaryColor,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 4,
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
              ],
            ),
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  _tabController.animateTo(index);
                },
                controller: _pagingController,
                itemCount: widget.pollOptions.length,
                itemBuilder: (context, index) {
                  return _defListView(widget.pollOptions[index]);
                },
                // children: [
                //   for (var option in widget.pollOptions)
                //     option.voteCount < 0
                //         ? Center(
                //             child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               LMFeedIcon(
                //                 style: LMFeedIconStyle(size: 100),
                //                 type: LMFeedIconType.png,
                //                 assetPath: lmNoResponsePng,
                //               ),
                //               SizedBox(height: 8),
                //               LMFeedText(
                //                 text: 'No Responses',
                //                 style: LMFeedTextStyle(
                //                   textStyle: TextStyle(
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w500,
                //                   ),
                //                 ),
                //               )
                //             ],
                //           ))
                //         : _defListView(
                //             option,
                // ),

                // ],
              ),
            )
          ],
        ));
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
    return FutureBuilder(
        future: LMFeedCore.instance.lmFeedClient
            .getPollVotes((GetPollVotesRequestBuilder()
                  ..pollId(widget.pollId)
                  ..votes([option.id]))
                .build()),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }
          final voteResponse = snapshot.data;
          if (voteResponse == null || voteResponse.data == null) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }
          Map<String, LMWidgetViewData> widgets =
              voteResponse.data?.widgets.map((key, value) {
                    return MapEntry(
                        key, LMWidgetViewDataConvertor.fromWidgetModel(value));
                  }) ??
                  {};
          Map<String, LMTopicViewData> topics = voteResponse.data?.topics
                  .map((key, value) {
                return MapEntry(key, LMTopicViewDataConvertor.fromTopic(value));
              }) ??
              {};
          List<LMUserViewData> users =
              voteResponse.data?.users.entries.map((element) {
                    return LMUserViewDataConvertor.fromUser(
                      element.value,
                      topics: topics,
                      widgets: widgets,
                      userTopics: voteResponse.data!.userTopics,
                    );
                  }).toList() ??
                  [];
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserTile(user: users[index]);
              });
        });
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
