// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedList extends StatefulWidget {
  final List<String> selectedTopicIds;
  final PagingController<int, LMPostViewData> pagingController;
  final int pageSize;
  final LMFeedWidgetSource widgetSource;

  final LMFeedPostWidgetBuilder? postBuilder;

  const LMFeedList({
    super.key,
    required this.selectedTopicIds,
    required this.pagingController,
    this.pageSize = 20,
    this.postBuilder,
    this.widgetSource = LMFeedWidgetSource.universalFeed,
  });

  @override
  State<LMFeedList> createState() => _LMFeedListState();
}

class _LMFeedListState extends State<LMFeedList> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedThemeData feedThemeData = LMFeedTheme.instance.theme;
  LMFeedUniversalBloc _feedBloc = LMFeedUniversalBloc.instance;
  final ValueNotifier postUploading = ValueNotifier(false);

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  bool right = true;
  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;

  bool userPostingRights = true;

  Widget getLoaderThumbnail(LMAttachmentViewData? media) {
    if (media != null) {
      if (media.attachmentType == LMMediaType.image) {
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMFeedImage(
            image: media,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.attachmentType == LMMediaType.document) {
        return LMFeedTheme
                .instance.theme.mediaStyle.documentStyle.documentIcon ??
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.picture_as_pdf,
              style: LMFeedIconStyle(
                color: Colors.red,
                size: 35,
                boxPadding: 0,
              ),
            );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    Bloc.observer = LMFeedBlocObserver();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    _addPaginationListener();
  }

  @override
  void didUpdateWidget(covariant LMFeedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.selectedTopicIds, oldWidget.selectedTopicIds)) {
      widget.pagingController.refresh();
    }
  }

  void _addPaginationListener() {
    widget.pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          LMFeedGetUniversalFeedEvent(
            pageKey: pageKey,
            topicsIds: widget.selectedTopicIds,
          ),
        );
      },
    );
  }

  void refresh() => widget.pagingController.refresh();

  void updatePagingControllers(_, LMFeedUniversalState? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts;

      _feedBloc.users.addAll(state.users);
      _feedBloc.topics.addAll(state.topics);
      _feedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < 10) {
        widget.pagingController.appendLastPage(listOfPosts);
      } else {
        widget.pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LMFeedUniversalBloc, LMFeedUniversalState>(
      bloc: _feedBloc,
      listener: updatePagingControllers,
      child: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return PagedSliverList<int, LMPostViewData>(
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
              itemBuilder: (context, item, index) {
                LMFeedPostWidget postWidget =
                    LMFeedDefaultWidgets.instance.defPostWidget(
                  context,
                  feedThemeData,
                  item,
                  widget.widgetSource,
                );
                return LMFeedCore.widgetUtility
                    .postWidgetBuilder(context, postWidget, item);
              },
            ),
          );
        },
      ),
    );
  }
}
