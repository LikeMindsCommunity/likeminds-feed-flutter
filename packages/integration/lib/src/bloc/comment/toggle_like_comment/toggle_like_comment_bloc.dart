import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';

part 'toggle_like_comment_event.dart';
part 'toggle_like_comment_state.dart';

class ToggleLikeCommentBloc
    extends Bloc<ToggleLikeCommentEvent, ToggleLikeCommentState> {
  final LMFeedBloc lmFeedBloc = LMFeedBloc.get();

  ToggleLikeCommentBloc() : super(ToggleLikeCommentInitial()) {
    on<ToggleLikeComment>((event, emit) async {
      await _mapToggleLikeCommentToState(
        toggleLikeCommentRequest: event.toggleLikeCommentRequest,
        emit: emit,
        lmFeedBloc: lmFeedBloc,
      );
    });
  }

  Future<void> _mapToggleLikeCommentToState(
      {required ToggleLikeCommentRequest toggleLikeCommentRequest,
      required Emitter<ToggleLikeCommentState> emit,
      required LMFeedBloc lmFeedBloc}) async {
    emit(ToggleLikeCommentLoading());
    ToggleLikeCommentResponse? response = await lmFeedBloc.lmFeedClient
        .toggleLikeComment(toggleLikeCommentRequest);

    if (!response.success) {
      emit(const ToggleLikeCommentError(message: "An error occurred"));
    } else {
      emit(ToggleLikeCommentSuccess(toggleLikeCommentResponse: response));
    }
  }
}
