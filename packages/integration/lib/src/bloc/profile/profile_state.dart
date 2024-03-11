part of 'profile_bloc.dart';

abstract class LMFeedProfileState extends Equatable {
  const LMFeedProfileState();

  @override
  List<Object> get props => [];
}

class LMFeedProfileStateInitState extends LMFeedProfileState {}

class LMFeedRouteToUserProfileState extends LMFeedProfileState {
  final String userUniqueId;
  final BuildContext context;

  const LMFeedRouteToUserProfileState(
      {required this.userUniqueId, required this.context});

  @override
  List<Object> get props => [userUniqueId, identityHashCode(this)];
}

class LMFeedLoginRequiredState extends LMFeedProfileState {}

class LMFeedLogoutState extends LMFeedProfileState {}

class LMFeedRouteToCompanyProfileState extends LMFeedProfileState {
  final String companyId;

  const LMFeedRouteToCompanyProfileState({required this.companyId});

  @override
  List<Object> get props => [companyId, identityHashCode(this)];
}
