import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'user_created_comment_event.dart';
part 'user_created_comment_state.dart';

class LMFeedUserCreatedCommentBloc
    extends Bloc<LMFeedUserCreatedCommentEvent, LMFeedUserCreatedCommentState> {
  LMFeedUserCreatedCommentBloc() : super(UserCreatedCommentInitialState()) {
    on<LMFeedUserCreatedCommentGetEvent>((event, emit) async {
      if (event.page > 1) {
        emit(UserCreatedCommentPaginationLoadingState());
      } else {
        emit(UserCreatedCommentLoadingState());
      }
      try {
        final request = (GetUserCommentsRequestBuilder()
              ..page(event.page)
              ..pageSize(event.pageSize)
              ..uuid(event.uuid))
            .build();
        final GetUserCommentsResponse response =
            await LMFeedCore.client.getUserCreatedComments(request);
        if (response.success) {
          List<LMCommentViewData> comments = [];
          Map<String, LMUserViewData> users = response.users?.map(
                  (key, value) =>
                      MapEntry(key, LMUserViewDataConvertor.fromUser(value))) ??
              {};
          response.comments?.forEach((comment) {
            comments.add(LMCommentViewDataConvertor.fromComment(
              comment,
              users,
            ));
          });
          final posts = response.posts?.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                      post: value, users: response.users))) ??
              {};
          emit(UserCreatedCommentLoadedState(comments: comments, posts: posts));
        } else {
          emit(UserCreatedCommentErrorState(
              errorMessage: response.errorMessage ??
                  "An error occurred, Please try again"));
        }
      } catch (e) {
        emit(UserCreatedCommentErrorState(errorMessage: e.toString()));
      }
    });
  }
}
