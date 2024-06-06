part of '../user_meta_bloc.dart';

updateUserMetaEventHandler(
    LMFeedUserMetaUpdateEvent event, Emitter<LMFeedUserMetaState> emit) async {
  emit(LMFeedUserMetaUpdateLoadingState());
  EditProfileRequestBuilder editProfileRequest = EditProfileRequestBuilder()
    ..name(event.user.name)
    ..uuid(event.user.sdkClientInfo.uuid)
    ..metadata(event.metadata);

  try {
    if (event.imagePath != null) {
      String? imageUrl = await LMFeedMediaService.instance
          .uploadFile(File(event.imagePath!), event.user.sdkClientInfo.uuid);
      if (imageUrl != null) {
        editProfileRequest..imageUrl(imageUrl);
      }
    }
    final response = await LMFeedCore.instance.lmFeedClient
        .editProfile(editProfileRequest.build());
    if (response.success) {
      emit(LMFeedUserMetaUpdatedState());
      LMFeedUserMetaBloc.instance
          .add(LMFeedUserMetaGetEvent(uuid: event.user.uuid));
    }
  } on Exception catch (e, stackTrace) {
    LMFeedPersistence.instance.handleException(e, stackTrace);
    emit(LMFeedUserMetaErrorState(
      message: e.toString(),
    ));
  }
}
