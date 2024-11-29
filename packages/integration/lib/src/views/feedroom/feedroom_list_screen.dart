import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/feedroom/feedroom_bloc.dart';

class LMFeedRoomListScreen extends StatefulWidget {
  final Widget Function()? feedroomTileBuilder;
  final LMFeedPostAppBarBuilder? appBarBuilder;
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

  const LMFeedRoomListScreen({
    super.key,
    this.appBarBuilder,
    this.feedroomTileBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
  });

  @override
  State<LMFeedRoomListScreen> createState() => _LMFeedRoomListScreenState();
}

class _LMFeedRoomListScreenState extends State<LMFeedRoomListScreen> {
  // final List<LMFeedRoomViewData> _feedRoomList = [];
  LMFeedRoomBloc? _feedRoomListBloc;
  final PagingController<int, LMFeedRoomViewData>
      _pagingControllerFeedRoomList = PagingController(firstPageKey: 1);

  LMFeedroomScreenBuilderDelegate widgetBuilder = LMFeedCore.config.feedroomScreenConfig.builder;

  void _addPaginationListener() {
    _pagingControllerFeedRoomList.addPageRequestListener((pageKey) {
      _feedRoomListBloc!.add(LMFeedGetFeedRoomListEvent(offset: pageKey));
    });
  }

  @override
  void initState() {
    super.initState();
    Bloc.observer = LMFeedBlocObserver();
    _feedRoomListBloc = LMFeedRoomBloc.instance;
    _addPaginationListener();
    _feedRoomListBloc!.add(const LMFeedGetFeedRoomListEvent(offset: 1));
  }

  @override
  void dispose() {
    _pagingControllerFeedRoomList.dispose();
    _feedRoomListBloc?.close();
    super.dispose();
  }

  void updatePagingControllers(Object? state) {
    if (state is LMFeedRoomListLoadedState) {
      if (state.size < 10) {
        _pagingControllerFeedRoomList.appendLastPage(state.feedList);
      } else {
        _pagingControllerFeedRoomList.appendPage(state.feedList, state.offset);
      }
    }
  }

  /// Clearing paging controller while changing the
  /// event to prevent duplication of list
  void clearPagingController() {
    if (_pagingControllerFeedRoomList.itemList != null) {
      _pagingControllerFeedRoomList.itemList!.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widgetBuilder.scaffold(
      appBar: widget.appBarBuilder?.call(context, _defAppBar()) ?? _defAppBar(),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          _feedRoomListBloc!.add(const LMFeedGetFeedRoomListEvent(offset: 1));
          clearPagingController();
        },
        color: LMFeedCore.theme.primaryColor,
        backgroundColor: LMFeedCore.theme.container,
        child: BlocConsumer<LMFeedRoomBloc, LMFeedRoomState>(
          bloc: _feedRoomListBloc,
          // listenWhen: (previous, current) => previous is LMFeedRoomInitialState,
          listener: (context, state) => updatePagingControllers(state),
          buildWhen: (previous, current) {
            if (current is LMFeedRoomListLoadingState &&
                _pagingControllerFeedRoomList.itemList!.isNotEmpty) {
              return false;
            }
            return true;
          },
          builder: ((context, state) {
            if (state is LMFeedRoomListLoadedState) {
              return LMFeedRoomList(
                pagingControllerFeedRoomList: _pagingControllerFeedRoomList,
                feedRoomBloc: _feedRoomListBloc!,
              );
            } else if (state is LMFeedRoomListLoadingState) {
              return getFeedRoomListLoadingView();
            } else if (state is LMFeedRoomListErrorState) {
              return getFeedRoomListErrorView(state.message);
            } else if (state is LMFeedRoomListEmptyState) {
              return getFeedRoomListEmptyView();
            }
            return widgetBuilder.scaffold(
              backgroundColor: LMFeedCore.theme.backgroundColor,
              body: LMFeedLoader(),
            );
          }),
        ),
      ),
    );
  }

  Widget getFeedRoomListEmptyView() {
    return widget.noItemsFoundIndicatorBuilder?.call(context) ??
        const Center(
          child: Text("No feedrooms found"),
        );
  }

  Widget getFeedRoomListErrorView(String message) {
    return widget.firstPageErrorIndicatorBuilder?.call(context) ??
        Center(
          child: Text(message),
        );
  }

  Widget getFeedRoomListLoadingView() {
    return widget.firstPageProgressIndicatorBuilder?.call(context) ??
        const LMFeedLoader();
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      leading: const SizedBox.shrink(),
      trailing: [const SizedBox.shrink()],
      title: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: LMFeedText(
          text: "Choose FeedRoom",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: LMFeedCore.theme.onContainer,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      style: LMFeedAppBarStyle.basic().copyWith(
        // centerTitle: true,
        height: 48,
        shadow: [
          BoxShadow(
            color: LMFeedCore.theme.primaryColor.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 4,
          )
        ],
        backgroundColor: LMFeedCore.theme.container,
      ),
    );
  }
}

class LMFeedRoomList extends StatelessWidget {
  final LMFeedRoomBloc feedRoomBloc;
  final LMFeedRoomTileBuilder? feedroomTileBuilder;
  final LMFeedPostAppBarBuilder? appBarBuilder;
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
  final PagingController<int, LMFeedRoomViewData> pagingControllerFeedRoomList;

  const LMFeedRoomList({
    super.key,
    required this.pagingControllerFeedRoomList,
    required this.feedRoomBloc,
    this.appBarBuilder,
    this.feedroomTileBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Expanded(
          child: PagedListView<int, LMFeedRoomViewData>(
            pagingController: pagingControllerFeedRoomList,
            builderDelegate: PagedChildBuilderDelegate<LMFeedRoomViewData>(
                noMoreItemsIndicatorBuilder: (context) =>
                    const SizedBox(height: 20),
                noItemsFoundIndicatorBuilder: (context) => Scaffold(
                      backgroundColor: LMFeedCore.theme.backgroundColor,
                      body: LMFeedLoader(),
                    ),
                itemBuilder: (context, item, index) {
                  return feedroomTileBuilder?.call(
                        context,
                        item,
                        _defFeedRoomTile(context, item),
                      ) ??
                      _defFeedRoomTile(context, item);
                }),
          ),
        )
      ],
    );
  }

  LMFeedTile _defFeedRoomTile(BuildContext context, LMFeedRoomViewData item) {
    return LMFeedTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LMFeedRoomScreen(
              feedroomId: item.id,
              // feedRoomTitle: item.title,
            ),
          ),
        );
        pagingControllerFeedRoomList.itemList?.clear();
      },
      leading: LMFeedProfilePicture(
        fallbackText: item.title,
        imageUrl: item.chatroomImageUrl,
        style: LMFeedProfilePictureStyle(
          size: 48,
          boxShape: BoxShape.circle,
        ),
      ),
      title: LMFeedText(
        text: item.header,
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      subtitle: LMFeedText(
        text: "${item.participantsCount} participants",
        style: LMFeedTextStyle(
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
