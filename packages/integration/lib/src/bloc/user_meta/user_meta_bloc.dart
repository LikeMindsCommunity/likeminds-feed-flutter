import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'user_meta_event.dart';
part 'user_meta_state.dart';

class LMFeedUserMetaBloc
    extends Bloc<LMFeedUserMetaEvent, LMFeedUserMetaState> {
  static LMFeedUserMetaBloc? _instance;
  static LMFeedUserMetaBloc get instance =>
      _instance ??= LMFeedUserMetaBloc._();
  LMFeedUserMetaBloc._() : super(LMFeedUserMetaInitialState()) {
    on<LMFeedUserMetaGetEvent>(_mapLMFeedUseMetaGetEventToState);
    on<LMFeedUserMetaUpdateEvent>(_mapLMFeedUserMetaUpdateEventToState);
  }

  _mapLMFeedUseMetaGetEventToState(
      LMFeedUserMetaGetEvent event, Emitter<LMFeedUserMetaState> emit) async {
    emit(LMFeedUserMetaLoadingState());
    try {
      final response = await LMFeedCore.instance.lmFeedClient.getUserFeedMeta(
          (GetUserFeedMetaRequestBuilder()..uuid(event.uuid)).build());

      final user = response.users?.entries.first.value;
      final userViewData = LMUserViewDataConvertor.fromUser(
        user!,
        widgets: response.widgets,
      );
      emit(LMFeedUserMetaLoadedState(
        user: userViewData,
        postsCount: response.postsCount,
        commentsCount: response.commentsCount,
      ));
    } catch (e) {}
  }

  _mapLMFeedUserMetaUpdateEventToState(LMFeedUserMetaUpdateEvent event,
      Emitter<LMFeedUserMetaState> emit) async {
    EditProfileRequest editProfileRequest = (EditProfileRequestBuilder()
          ..name(event.user.name)
          ..userUniqueId(event.user.sdkClientInfo!.userUniqueId)
          ..metadata(event.metadata))
        .build();
    try {
      final response = await LMFeedCore.instance.lmFeedClient
          .editProfile(editProfileRequest);
      if (response.success) {
        emit(LMFeedUserMetaUpdatedState());
        add(LMFeedUserMetaGetEvent(uuid: event.user.userUniqueId));
      }
    } on Error catch (e, stackTrace) {}
  }
}
