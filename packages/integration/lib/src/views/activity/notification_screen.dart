import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/typedefs.dart';
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

  var kWhiteColor = Colors.white;

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

  bool todayFlag = true;
  bool earlierFlag = true;

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    todayFlag = true;
    earlierFlag = true;
    return Scaffold(
      backgroundColor: kWhiteColor,
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
        backgroundColor: Colors.white,
        border: Border(),
        padding: EdgeInsets.zero,
      ),
      leading: BackButton(
        color: Colors.black,
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
              noItemsFoundIndicatorBuilder: (context) => Scaffold(
                backgroundColor: kWhiteColor,
                body: Center(
                  child:
                      widget.emptyNotificationFeedViewBuilder?.call(context) ??
                          _defEmptyNotificationFeedView(),
                ),
              ),
              itemBuilder: (context, item, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.timeStampBuilder?.call(context) ??
                        _defTimeStampWidget(item.createdAt),
                    widget.notificationTileBuilder
                            ?.call(context, item, _defNotificationTile(item)) ??
                        _defNotificationTile(item),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding _defEmptyNotificationFeedView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: const LMFeedText(
        text: "Opps! You don't have any notifications yet.",
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

  LMFeedNotificationTile _defNotificationTile(
      LMNotificationFeedItemViewData item) {
    return LMFeedNotificationTile(
      notificationItemViewData: item,
      style: LMFeedTileStyle.basic()
          .copyWith(crossAxisAlignment: CrossAxisAlignment.start),
      onTap: () {
        if (!item.isRead) {
          _notificationsBloc?.add(
            LMFeedMarkNotificationAsReadEvent(
              activityId: item.id,
            ),
          );
        }
      },
    );
  }

  Padding _defCustomWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
      child: LMFeedText(
          text: 'Activities',
          style: LMFeedTextStyle(
              textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ))),
    );
  }

  Widget _defTimeStampWidget(DateTime createdAt) {
    if (DateTime.now().day == createdAt.day) {
      if (todayFlag) {
        todayFlag = false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: LMFeedText(
            text: "Today",
            style: LMFeedTextStyle(
                textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
          ),
        );
      }
    } else if (earlierFlag) {
      earlierFlag = false;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: LMFeedText(
          text: "Earlier",
          style: LMFeedTextStyle(
              textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          )),
        ),
      );
    }
    return const SizedBox.shrink();
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
}
