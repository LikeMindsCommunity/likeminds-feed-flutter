import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
part 'search_event.dart';
part 'search_state.dart';

class LMFeedSearchBloc extends Bloc<LMFeedSearchEvent, LMFeedSearchState> {
  LMFeedSearchBloc() : super(LMFeedInitialSearchState()) {
    on<LMFeedGetSearchEvent>(_mapGetSearchEventToState);
  }

  Future<void> _mapGetSearchEventToState(
      LMFeedGetSearchEvent event, Emitter<LMFeedSearchState> emit) async {
    if (event.query.isEmpty) return;
    if (event.page > 1) {
      emit(LMFeedSearchPaginationLoadingState());
    } else {
      emit(LMFeedSearchLoadingState());
    }
    try {
      final searchRequest = (SearchPostRequestBuilder()
            ..search(event.query)
            ..searchType(event.type)
            ..page(event.page)
            ..pageSize(event.pageSize))
          .build();

      final searchResponse =
          await LMFeedCore.instance.lmFeedClient.searchPosts(searchRequest);

      if (searchResponse.success && searchResponse.posts != null) {
        List<LMPostViewData> posts = [];
        for (Post post in searchResponse.posts!) {
          posts.add(LMPostViewDataConvertor.fromPost(
            post: post,
            widgets: searchResponse.widgets,
            users: searchResponse.users,
            topics: searchResponse.topics,
            repostedPosts: searchResponse.repostedPosts,
          ));
        }
        emit(LMFeedSearchLoadedState(posts: posts));
      } else {
        emit(LMFeedSearchErrorState(
            message: searchResponse.errorMessage ?? 'An error occurred.'));
      }
    } on Exception catch (e, stackTrace) {
      LMFeedLogger.instance.handleException(e, stackTrace);
      emit(LMFeedSearchErrorState(message: e.toString()));
    }
  }
}
