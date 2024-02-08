part of 'profile_bloc.dart';

abstract class LMFeedProfileEvent extends Equatable {
  const LMFeedProfileEvent();

  @override
  List<Object> get props => [];
}

class LMFeedProfileEventInitEvent extends LMFeedProfileEvent {}

class LMFeedRouteToUserProfileEvent extends LMFeedProfileEvent {
  final String userUniqueId;

  const LMFeedRouteToUserProfileEvent({required this.userUniqueId});

  @override
  List<Object> get props => [userUniqueId, identityHashCode(this)];
}

class LMFeedRouteToCompanyProfileEvent extends LMFeedProfileEvent {
  final String companyId;

  const LMFeedRouteToCompanyProfileEvent({required this.companyId});

  @override
  List<Object> get props => [companyId, identityHashCode(this)];
}

class LMFeedLoginRequiredEvent extends LMFeedProfileEvent {}

class LMFeedLogoutEvent extends LMFeedProfileEvent {}
