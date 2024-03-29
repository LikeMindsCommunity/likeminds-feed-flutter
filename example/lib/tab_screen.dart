import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/activity_widget_screen.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabController.index,
        onDestinationSelected: (index) {
          tabController.animateTo(index);
          setState(() {});
        },
        elevation: 10,
        indicatorColor: lmFeedTheme.primaryColor,
        backgroundColor: lmFeedTheme.container,
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
      body: TabBarView(
        controller: tabController,
        children: [
          HomeScreen(
            feedWidget: widget.feedWidget,
          ),
          LMFeedActivityWidgetScreen(
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
