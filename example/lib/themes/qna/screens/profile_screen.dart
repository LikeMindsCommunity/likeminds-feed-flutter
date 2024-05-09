import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/profile_header_widget.dart';

class LMQnAProfileScreen extends StatefulWidget {
  const LMQnAProfileScreen({
    super.key,
    required this.uuid,
  });
  final String uuid;

  @override
  State<LMQnAProfileScreen> createState() => _LMQnAProfileScreenState();
}

class _LMQnAProfileScreenState extends State<LMQnAProfileScreen>
    with TickerProviderStateMixin {
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);

  late TabController _tabController;
  int currentTab = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: LMQnAProfileHeaderWidget(
              uuid: widget.uuid,
              shouldReload: false,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 5)),
          SliverToBoxAdapter(
            child: Container(
              color: feedThemeData.container,
              child: TabBar(
                  controller: _tabController,
                  labelColor: qNaPrimaryColor,
                  unselectedLabelColor: textSecondary,
                  indicator: UnderlineTabIndicator(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: qNaPrimaryColor,
                      width: 2,
                    ),
                  ),
                  onTap: (value) {
                    setState(() {
                      currentTab = value;
                    });
                  },
                  tabs: [
                    getStyledTab(postTitleFirstCap),
                    getStyledTab(commentTitleFirstCapPlural),
                  ]),
            ),
          ),
          currentTab == 0
              ? LMFeedUserCreatedPostListView(
                  uuid: widget.uuid,
                  firstPageProgressIndicatorBuilder: (context) {
                    return const LMFeedLoader();
                  },
                )
              : LMFeedUserCreatedCommentListView(
                  uuid: widget.uuid,
                ),
        ],
      ),
    );
  }

  Tab getStyledTab(String text) {
    return Tab(
      child: LMFeedText(
        text: text,
        style: LMFeedTextStyle.basic().copyWith(
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
