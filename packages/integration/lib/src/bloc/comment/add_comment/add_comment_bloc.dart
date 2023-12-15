import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/constants/analytics/keys.dart';

part 'add_comment_event.dart';
part 'add_comment_state.dart';

class AddCommentBloc extends Bloc<AddCommentEvent, AddCommentState> {
  AddCommentBloc() : super(AddCommentInitial()) {
    LMFeedBloc lmFeedBloc = LMFeedBloc.get();

    on<AddComment>(
      (event, emit) async {
        await _mapAddCommentToState(
          addCommentRequest: event.addCommentRequest,
          emit: emit,
          lmFeedBloc: lmFeedBloc,
        );
      },
    );
  }

  FutureOr<void> _mapAddCommentToState(
      {required AddCommentRequest addCommentRequest,
      required Emitter<AddCommentState> emit,
      required LMFeedBloc lmFeedBloc}) async {
    emit(AddCommentLoading());
    AddCommentResponse? response =
        await lmFeedBloc.lmFeedClient.addComment(addCommentRequest);
    if (!response.success) {
      emit(const AddCommentError(message: "An error occurred"));
    } else {
      lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
        eventName: AnalyticsKeys.commentPosted,
        eventProperties: {
          "post_id": addCommentRequest.postId,
          "comment_id": response.reply?.id,
        },
      ));
      emit(AddCommentSuccess(addCommentResponse: response));
    }
  }
}
