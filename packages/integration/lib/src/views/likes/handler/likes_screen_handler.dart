import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/common/like_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMLikesScreenHandler {
  late PagingController<int, LMLikeViewData> _pagingController;
  late String postId;
  late String? commentId;
  int? totalLikesCount;
  late final int pageSize;

  static LMLikesScreenHandler? _likesScreenHandler;

  static LMLikesScreenHandler get instance =>
      _likesScreenHandler ??= LMLikesScreenHandler._();

  LMLikesScreenHandler._();

  PagingController<int, LMLikeViewData> get pagingController =>
      _pagingController;

  void initialise(
      {required String postId, String? commentId, int pageSize = 20}) {
    _pagingController = PagingController<int, LMLikeViewData>(firstPageKey: 1);
    this.postId = postId;
    this.commentId = commentId;
    this.pageSize = pageSize;
    getLikesPaginatedList(1);
    _addPaginationListener();
  }

  void dispose() {
    _pagingController.dispose();
  }

  void setTotalLikesCount(int? totalLikesCount) {
    this.totalLikesCount = totalLikesCount;
  }

  // Analytics event logging for Like Screen
  void logLikeListEvent(totalLikes) {
    LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
      eventName: LMAnalyticsKeys.likeListOpen,
      eventProperties: {
        "post_id": postId,
        "total_likes": totalLikes,
      },
    ));
  }

  void getLikesPaginatedList(int pageKey) {
    if (commentId != null) {
      _getCommentLikesPaginatedList(pageKey);
    } else {
      _getPostLikesPaginatedList(pageKey);
    }
  }

  void _getPostLikesPaginatedList(int pageKey) async {
    GetPostLikesRequest request = (GetPostLikesRequestBuilder()
          ..page(pageKey)
          ..pageSize(20)
          ..postId(postId))
        .build();
    GetPostLikesResponse response =
        await LMFeedCore.instance.lmFeedClient.getPostLikes(request);
    if (response.success) {
      _pagingController.appendPage(
          response.likes
                  ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                  .toList() ??
              [],
          pageKey);
    } else {
      _pagingController.error = response.errorMessage ?? "";
    }
  }

  void _getCommentLikesPaginatedList(int pageKey) async {
    GetCommentLikesRequest request = (GetCommentLikesRequestBuilder()
          ..commentId(commentId!)
          ..page(pageKey)
          ..pageSize(20)
          ..postId(postId))
        .build();

    GetCommentLikesResponse response =
        await LMFeedCore.instance.lmFeedClient.getCommentLikes(request);
    if (response.success) {
      _pagingController.appendPage(
          response.commentLikes
                  ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                  .toList() ??
              [],
          pageKey);
    } else {
      _pagingController.error = response.errorMessage ?? "";
    }
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) async {
        getLikesPaginatedList(pageKey);
      },
    );
  }
}
