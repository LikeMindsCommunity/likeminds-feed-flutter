part of '../user_meta_bloc.dart';

updateUserMetaEventHandler(LMFeedUserMetaUpdateEvent event,
      Emitter<LMFeedUserMetaState> emit) async {
    EditProfileRequest editProfileRequest = (EditProfileRequestBuilder()
          ..name(event.user.name)
          ..uuid(event.user.sdkClientInfo.uuid)
          ..metadata(event.metadata))
        .build();
    try {
      final response = await LMFeedCore.instance.lmFeedClient
          .editProfile(editProfileRequest);
      if (response.success) {
        emit(LMFeedUserMetaUpdatedState());
        LMFeedUserMetaBloc.instance.add(LMFeedUserMetaGetEvent(uuid: event.user.uuid));
      }
    } on Exception catch (e, stackTrace) {
      LMFeedLogger.instance.handleException(e, stackTrace);
      emit(LMFeedUserMetaErrorState(
          message: e.toString(), ));
    }
  }
