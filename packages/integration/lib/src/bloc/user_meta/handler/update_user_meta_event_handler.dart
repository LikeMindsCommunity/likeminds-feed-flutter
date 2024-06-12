part of '../user_meta_bloc.dart';

updateUserMetaEventHandler(
    LMFeedUserMetaUpdateEvent event, Emitter<LMFeedUserMetaState> emit) async {
  emit(LMFeedUserMetaUpdateLoadingState());
  EditProfileRequestBuilder editProfileRequest = EditProfileRequestBuilder()
    ..name(event.user.name)
    ..uuid(event.user.sdkClientInfo.uuid)
    ..metadata(event.metadata);

  try {
    if (event.image != null) {
      File imageFile;

      if (event.image!.attachmentMeta.bytes != null) {
        imageFile = File.fromRawPath(event.image!.attachmentMeta.bytes!);
      } else {
        imageFile = File(event.image!.attachmentMeta.path!);
      }

      LMResponse<String> imageUrl = await LMFeedMediaService.uploadFile(
          imageFile.readAsBytesSync(), event.user.sdkClientInfo.uuid,
          fileName: event.image!.attachmentMeta.meta?['file_name']);
      if (imageUrl.success) {
        editProfileRequest..imageUrl(imageUrl.data!);
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
