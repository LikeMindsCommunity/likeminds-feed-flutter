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
  final String? imagePath;

  const LMFeedUserMetaUpdateEvent({
    required this.metadata,
    required this.user,
    this.imagePath,
  });
  @override
  List<Object> get props => [metadata, user];
}
