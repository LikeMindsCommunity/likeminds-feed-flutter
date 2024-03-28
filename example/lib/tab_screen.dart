import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class ExampleTabScreen extends StatefulWidget {
  final Widget feedWidget;
  final String uuid;
  const ExampleTabScreen({
    super.key,
    required this.feedWidget,
    required this.uuid,
  });

  @override
  State<ExampleTabScreen> createState() => _ExampleTabScreenState();
}

class _ExampleTabScreenState extends State<ExampleTabScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData lmFeedTheme = LMFeedCore.theme;
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: lmFeedTheme.onContainer.withOpacity(0.2),
            offset: Offset.fromDirection(180),
            spreadRadius: 4,
            blurRadius: 4,
          ),
        ]),
        child: NavigationBar(
          selectedIndex: tabController.index,
          onDestinationSelected: (index) {
            tabController.animateTo(index);
            setState(() {});
          },
          elevation: 30,
          indicatorColor: lmFeedTheme.primaryColor,
          backgroundColor: lmFeedTheme.container,
          shadowColor: lmFeedTheme.onContainer,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: lmFeedTheme.onContainer,
              ),
              selectedIcon: Icon(Icons.home, color: lmFeedTheme.onPrimary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_2_sharp,
                color: lmFeedTheme.onContainer,
              ),
              selectedIcon: Icon(
                Icons.person_2_sharp,
                color: lmFeedTheme.onPrimary,
              ),
              label: 'Activity',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(
            feedWidget: widget.feedWidget,
          ),
          LMFeedActivityScreen(
            uuid: widget.uuid,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Widget feedWidget;

  const HomeScreen({
    super.key,
    required this.feedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return feedWidget;
  }
}
