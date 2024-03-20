import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'user_created_comment_event.dart';
part 'user_created_comment_state.dart';

class LMFeedUserCreatedCommentBloc
    extends Bloc<LMFeedUserCreatedCommentEvent, LMFeedUserCreatedCommentState> {
  LMFeedUserCreatedCommentBloc() : super(UserCreatedCommentInitialState()) {
    on<LMFeedUserCreatedCommentGetEvent>((event, emit) async {
      emit(UserCreatedCommentLoadingState());
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
          Map<String, LMWidgetViewData> widgets = (response.widgets ?? {}).map(
            (key, value) =>
                MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)),
          );

          Map<String, LMTopicViewData> topics = (response.topics ?? {}).map(
              (key, value) => MapEntry(key,
                  LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

          Map<String, LMUserViewData> users = response.users?.map(
                  (key, value) => MapEntry(
                      key,
                      LMUserViewDataConvertor.fromUser(value,
                          topics: topics,
                          widgets: widgets,
                          userTopics: response.userTopics))) ??
              {};
          comments = response.comments?.map((comment) {
                return LMCommentViewDataConvertor.fromComment(comment, users);
              }).toList() ??
              [];

          final posts = response.posts?.map(
                (key, value) => MapEntry(
                    key,
                    LMPostViewDataConvertor.fromPost(
                      post: value,
                      users: users,
                      topics: topics,
                      widgets: widgets,
                      userTopics: response.userTopics,
                    )),
              ) ??
              {};

          emit(UserCreatedCommentLoadedState(
              comments: comments, posts: posts, page: event.page));
        } else {
          emit(UserCreatedCommentErrorState(
              errorMessage: response.errorMessage ??
                  "An error occurred, Please try again"));
        }
      } catch (e, s) {
        debugPrint(s.toString());
        emit(UserCreatedCommentErrorState(errorMessage: e.toString()));
      }
    });
  }
}
