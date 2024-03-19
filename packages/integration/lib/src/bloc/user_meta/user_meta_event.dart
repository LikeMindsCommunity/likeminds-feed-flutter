part of 'user_meta_bloc.dart';

class LMFeedUserMetaEvent extends Equatable {
  const LMFeedUserMetaEvent();
  @override
  List<Object> get props => [];
}

class LMFeedUserMetaGetEvent extends LMFeedUserMetaEvent {
  final String uuid;
  const LMFeedUserMetaGetEvent({required this.uuid});
  @override
  List<Object> get props => [uuid];
}

class LMFeedUserMetaUpdateEvent extends LMFeedUserMetaEvent {
  final LMUserViewData user;
  final Map<String, dynamic> metadata;

  const LMFeedUserMetaUpdateEvent({required this.metadata, required this.user});
  @override
  List<Object> get props => [metadata, user];
}
