import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/activity/notification_tile.dart';

class LMFeedNotificationScreen extends StatefulWidget {
  const LMFeedNotificationScreen({
    super.key,
    this.appBarBuilder,
    this.customWidgetBuilder,
    this.notificationTileBuilder,
    this.emptyNotificationFeedViewBuilder,
    this.errorViewBuilder,
    this.loaderBuilder,
    this.timeStampBuilder,
  });

  final LMFeedPostAppBarBuilder? appBarBuilder;
  final LMFeedContextWidgetBuilder? customWidgetBuilder;
  final LMFeedContextWidgetBuilder? emptyNotificationFeedViewBuilder;
  final Widget Function(BuildContext, String)? errorViewBuilder;
  final LMFeedContextWidgetBuilder? loaderBuilder;
  final Widget Function(
          BuildContext, LMNotificationFeedItemViewData, LMFeedNotificationTile)?
      notificationTileBuilder;
  final LMFeedContextWidgetBuilder? timeStampBuilder;

  @override
  State<LMFeedNotificationScreen> createState() =>
      _LMFeedNotificationScreenState();
}

class _LMFeedNotificationScreenState extends State<LMFeedNotificationScreen> {
  Size? screenSize;
  PagingController<int, LMNotificationFeedItemViewData> pagingController =
      PagingController<int, LMNotificationFeedItemViewData>(
    firstPageKey: 1,
  );
  LMFeedNotificationsBloc? _notificationsBloc;

  int _page = 1;
  LMFeedThemeData _theme = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetUtility = LMFeedCore.widgetUtility;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.notificationScreen;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = LMFeedNotificationsBloc();
    addPageRequestListener();

    _notificationsBloc!.add(
      const LMFeedGetNotificationsEvent(
        offset: 1,
        pageSize: 10,
      ),
    );
  }

  void addPageRequestListener() {
    pagingController.addPageRequestListener(
      (pageKey) {
        _notificationsBloc!.add(
          LMFeedGetNotificationsEvent(
            offset: pageKey,
            pageSize: 10,
          ),
        );
      },
    );
  }

  void updatePagingControllers(LMFeedNotificationsLoadedState state) {
    if (state.response.length < 10) {
      pagingController.appendLastPage(state.response);
    } else {
      pagingController.appendPage(state.response, _page + 1);
      _page++;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return _widgetUtility.scaffold(
      source: _widgetSource,
      backgroundColor: _theme.backgroundColor,
      appBar: widget.appBarBuilder?.call(context, _defAppBar()) ?? _defAppBar(),
      body: BlocConsumer(
        bloc: _notificationsBloc,
        buildWhen: (previous, current) {
          if (current is LMFeedNotificationsPaginationLoadingState &&
              (previous is LMFeedNotificationsLoadingState ||
                  previous is LMFeedNotificationsLoadedState)) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is LMFeedNotificationsLoadedState) {
            updatePagingControllers(state);
          }
        },
        builder: (context, state) {
          if (state is LMFeedNotificationsLoadingState) {
            return widget.loaderBuilder?.call(context) ?? _defLoader();
          } else if (state is LMFeedNotificationsErrorState) {
            return widget.errorViewBuilder?.call(context, state.message) ??
                _defNotificationsErrorView(state.message);
          } else if (state is LMFeedNotificationsLoadedState) {
            return getNotificationsLoadedView(state: state);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Center _defLoader() {
    return const Center(
      child: LMFeedLoader(),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: _theme.backgroundColor,
        border: Border(),
        padding: EdgeInsets.zero,
      ),
      leading: BackButton(
        color: _theme.onContainer,
      ),
    );
  }

  Widget getNotificationsLoadedView({
    LMFeedNotificationsLoadedState? state,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.customWidgetBuilder?.call(context) ?? _defCustomWidget(),
        Expanded(
          child: PagedListView<int, LMNotificationFeedItemViewData>(
            padding: EdgeInsets.zero,
            pagingController: pagingController,
            builderDelegate:
                PagedChildBuilderDelegate<LMNotificationFeedItemViewData>(
              noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                height: 20,
              ),
              newPageProgressIndicatorBuilder: (context) =>
                  widget.loaderBuilder?.call(context) ?? _defLoader(),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: widget.emptyNotificationFeedViewBuilder?.call(context) ??
                    _defEmptyNotificationFeedView(),
              ),
              itemBuilder: (context, item, index) {
                return widget.notificationTileBuilder
                        ?.call(context, item, _defNotificationTile(item)) ??
                    _defNotificationTile(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _defEmptyNotificationFeedView() {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Icons.post_add,
            style: LMFeedIconStyle(
              size: 48,
              color: feedThemeData.onContainer,
            ),
          ),
          const SizedBox(height: 12),
          LMFeedText(
            text: 'No notifications to show',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: feedThemeData.onContainer,
              ),
            ),
          ),
          SizedBox(
            height: 48,
          )
        ],
      ),
    );
  }

  LMFeedNotificationTile _defNotificationTile(
      LMNotificationFeedItemViewData item) {
    return LMFeedNotificationTile(
      notificationItemViewData: item,
      style: LMFeedNotificationTileStyle.basic().copyWith(
        activeBackgroundColor: _theme.disabledColor.withOpacity(0.5),
        crossAxisAlignment: CrossAxisAlignment.start,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      onTap: () {
        if (!item.isRead) {
          _notificationsBloc?.add(
            LMFeedMarkNotificationAsReadEvent(
              activityId: item.id,
            ),
          );
        }
        debugPrint(item.cta ?? 'no cta');
        routeNotification(item.cta ?? '');
      },
    );
  }

  Widget _defCustomWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: LMFeedText(
          text: 'Notifications',
          style: LMFeedTextStyle(
              textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ))),
    );
  }

  Widget _defNotificationsErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LMFeedText(
        text: message,
        style: LMFeedTextStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void routeNotification(String route) async {
    Map<String, String> queryParams = {};
    String host = "";

    // If the notification is a feed notification, extract the route params
    final Uri routeUri = Uri.parse(route);
    final Map<String, String> routeParams =
        routeUri.hasQuery ? routeUri.queryParameters : {};
    final String routeHost = routeUri.host;
    host = routeHost;
    debugPrint("The route host is $routeHost");
    queryParams.addAll(routeParams);
    queryParams.forEach((key, value) {
      debugPrint("$key: $value");
    });

    // Route the notification to the appropriate screen
    // If the notification is post related, route to the post detail screen
    if (host == "post_detail") {
      final String postId = queryParams["post_id"]!;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(postId: postId)));
    }
  }
}
