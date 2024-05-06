part of 'profile_bloc.dart';

abstract class LMFeedProfileEvent extends Equatable {
  const LMFeedProfileEvent();

  @override
  List<Object> get props => [];
}

class LMFeedProfileEventInitEvent extends LMFeedProfileEvent {}

class LMFeedRouteToUserProfileEvent extends LMFeedProfileEvent {
  final String uuid;
  final BuildContext context;
  // Entity type defines the type of entity for which the profile is being opened
  // 1 - From Post
  // 2 - From Comment
  // 3 - From User Profile

  const LMFeedRouteToUserProfileEvent({
    required this.uuid,
    required this.context,
  });

  @override
  List<Object> get props => [uuid, identityHashCode(this)];
}

class LMFeedRouteToCompanyProfileEvent extends LMFeedProfileEvent {
  final String companyId;

  const LMFeedRouteToCompanyProfileEvent({required this.companyId});

  @override
  List<Object> get props => [companyId, identityHashCode(this)];
}

class LMFeedLoginRequiredEvent extends LMFeedProfileEvent {}

class LMFeedLogoutEvent extends LMFeedProfileEvent {}
