part of '../feedroom_bloc.dart';

FutureOr<void> _mapLMGetFeedRoomListToState({
  required LMFeedGetFeedRoomListEvent event,
  required Emitter<LMFeedRoomState> emit,
}) async {
  try {
    GetFeedRoomResponse response = await LMFeedCore.client.getFeedRoom(
      (GetFeedRoomRequestBuilder()
            ..page(event.offset)
            ..pageSize(10))
          .build(),
    );

    if (response.success) {
      final List<LMFeedRoomViewData> feedList = response.chatrooms!
          .map((e) =>
              LMFeedRoomViewDataConvertor.fromFeedRoomModel(feedRoomModel: e))
          .toList();
      emit(
        LMFeedRoomListLoadedState(
          feedList: feedList,
          size: feedList.length,
          offset: feedList.length >= 10 ? event.offset + 1 : event.offset,
        ),
      );
    } else {
      emit(LMFeedRoomListErrorState(
          message:
              response.errorMessage ?? "An error occured, please try again"));
    }
  } catch (e) {
    emit(
      LMFeedRoomListErrorState(message: "${e.toString()} No data found"),
    );
  }
}
