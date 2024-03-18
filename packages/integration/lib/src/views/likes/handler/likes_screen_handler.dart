// ignore_for_file: deprecated_member_use_from_same_package

part of '../likes_screen.dart';

class LMLikesScreenHandler {
  late PagingController<int, LMLikeViewData> _pagingController;
  Map<String, LMUserViewData> userData = {};
  late String postId;
  late String? commentId;
  int? totalLikesCount;
  final ValueNotifier<int> totalLikesCountNotifier = ValueNotifier(0);
  int? pageSize;

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
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.likeListOpen,
      deprecatedEventName: LMFeedAnalyticsKeysDep.likeListOpen,
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
      if (pageKey == 1) {
        totalLikesCountNotifier.value = response.totalCount ?? 0;
      }
      if (response.likes!.isEmpty ||
          response.likes!.length < (pageSize ?? 20)) {
        _pagingController.appendLastPage(response.likes
                ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                .toList() ??
            []);
      } else {
        _pagingController.appendPage(
            response.likes
                    ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                    .toList() ??
                [],
            pageKey + 1);
      }
      Map<String, LMUserViewData>? userViewData = response.users?.map(
          (key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
      userData.addAll(userViewData ?? {});
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
      if (pageKey == 1) {
        totalLikesCountNotifier.value = response.totalCount ?? 0;
      }
      if (response.commentLikes!.isEmpty ||
          response.commentLikes!.length < (pageSize ?? 20)) {
        _pagingController.appendLastPage(response.commentLikes
                ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                .toList() ??
            []);
      } else {
        _pagingController.appendPage(
            response.commentLikes
                    ?.map((e) => LMLikeViewDataConvertor.fromLike(likeModel: e))
                    .toList() ??
                [],
            pageKey + 1);
      }
      Map<String, LMUserViewData>? userViewData = response.users?.map(
          (key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
      userData.addAll(userViewData ?? {});
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
