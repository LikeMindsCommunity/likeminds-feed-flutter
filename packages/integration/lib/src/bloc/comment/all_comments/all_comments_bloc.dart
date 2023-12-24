import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';

part 'all_comments_event.dart';
part 'all_comments_state.dart';

class LMFetchCommentBloc extends Bloc<AllCommentsEvent, AllCommentsState> {
  static LMFetchCommentBloc? _lmFetchCommentBloc;

  static LMFetchCommentBloc get instance =>
      _lmFetchCommentBloc ??= LMFetchCommentBloc._();

  LMFetchCommentBloc._() : super(AllCommentsInitial()) {
    LMFeedIntegration lmFeedIntegration = LMFeedIntegration.instance;
    on<AllCommentsEvent>((event, emit) async {
      if (event is GetAllComments) {
        await _mapGetAllCommentsToState(
          postDetailRequest: event.postDetailRequest,
          forLoadMore: event.forLoadMore,
          emit: emit,
          lmFeedIntegration: lmFeedIntegration,
        );
      }
    });
  }

  FutureOr<void> _mapGetAllCommentsToState(
      {required PostDetailRequest postDetailRequest,
      required bool forLoadMore,
      required Emitter<AllCommentsState> emit,
      required LMFeedIntegration lmFeedIntegration}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User>? users = {};
    if (state is AllCommentsLoaded) {
      users = (state as AllCommentsLoaded).postDetails.users;
      emit(PaginatedAllCommentsLoading(
          prevPostDetails: (state as AllCommentsLoaded).postDetails));
    } else {
      emit(AllCommentsLoading());
    }

    PostDetailResponse response =
        await lmFeedIntegration.lmFeedClient.getPostDetails(postDetailRequest);
    if (!response.success) {
      emit(const AllCommentsError(message: "An error occurred"));
    } else {
      response.users!.addAll(users!);
      emit(AllCommentsLoaded(
        postDetails: response,
      ));
    }
  }
}
